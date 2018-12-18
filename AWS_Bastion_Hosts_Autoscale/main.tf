/* declared in ../aws-common-configuration.tf
variable aws_region {}
variable state_bucket_name {}
variable lock_table_name {}
variable kms_key_id {}
variable ecosystem_config { default = {} }

variable aws_plugin_version {}
variable aws_role_arn {}
variable aws_session_name {}

variable name {}
variable common_tags { default = {} }
variable region_tags { default = {} }
variable local_tags  { default = {} }
*/

variable vpc_backend { default = "s3" }
variable vpc_state_file {}
variable vpc_public_private_subnets { default = "public" }

variable image_ami { default = "Auto" }
variable instance_type { default = "t2.micro" }

variable bastion_host_as_min { default = 1 }
variable bastion_host_as_max { default = 3 }
variable bastion_host_as_des { default = 1 }
variable bastion_host_ssh_port { default = 22 }


data "terraform_remote_state" "vpc" {
  backend = "${var.vpc_backend}"
  config {
    bucket = "${var.state_bucket_name}"
    region = "${var.aws_region}"
    key = "${var.vpc_state_file}"
    encrypt = true
    dynamodb_table = "${var.lock_table_name}"
    kms_key_id = "${var.kms_key_id}"
  }
}

resource "aws_security_group" "bastion_sg" {
  name        = "SG-bastionhosts-${var.name}"
  description = "EKS cluster communication with worker nodes"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${merge(map("Name", format("%s", var.name)), var.common_tags, var.region_tags, var.local_tags)}"
}

resource "aws_security_group_rule" "bastion_sg_rule_ssh" {
  description = "Allow worker nodes to communicate with each other"
  from_port = "${var.bastion_host_ssh_port}"
  protocol = "tcp"
  security_group_id = "${aws_security_group.bastion_sg.id}"
  cidr_blocks  = ["0.0.0.0/0"]
  to_port = "${var.bastion_host_ssh_port}"
  type = "ingress"

  #tags = "${merge(map("Name", format("%s", var.name)), var.common_tags, var.region_tags, var.local_tags)}"
}

data "aws_ami" "this" {
  filter {
    name = "name"
    values = ["CentOS Linux 7 x86_64 HVM EBS *"]
  }

  most_recent = true
  owners      = ["679593333241"]
}

data "aws_region" "current" {}

locals {
  subnet_ids = "${data.terraform_remote_state.vpc.public_subnets}"
}

locals {
  bastion_host_userdata = <<EOF
#!/bin/bash
set -o xtrace
EOF
}

resource "aws_launch_configuration" "this" {
  associate_public_ip_address = true
  image_id = "${var.image_ami != "Auto" ? var.image_ami : data.aws_ami.this.id}"
  instance_type = "${var.instance_type}"
  name_prefix = "bastionhosts-${var.name}-"
  security_groups = ["${aws_security_group.bastion_sg.id}"]
  user_data_base64 = "${base64encode(local.bastion_host_userdata)}"
  key_name = "${var.ssh_key_name}"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "bastion-asg" {
  name = "bastion_host_asg-${var.name}"
  launch_configuration = "${aws_launch_configuration.this.id}"
  desired_capacity = "${var.bastion_host_as_des}"
  max_size = "${var.bastion_host_as_max}"
  min_size = "${var.bastion_host_as_min}"
  vpc_zone_identifier = ["${local.subnet_ids}"]
  target_group_arns = ["${aws_lb_target_group.bastion_lb_tg.arn}"]
  //tags = ["${merge(map("Name", format("%s", var.name)), map("${format("kubrenetes.io/cluster/%s", var.eks_cluster_name)}", "owned"), var.common_tags, var.region_tags, var.local_tags)}"]
  tag {
    key = "${format("bastion-host/%s", var.name)}"
    value = "owned"
    propagate_at_launch = true
   }
  tag {
    key = "Name"
    value = "${var.name}"
    propagate_at_launch = true
  }
  depends_on = [ "aws_launch_configuration.this"]
}

resource "aws_security_group" "bastion_lb_sg" {
  name        = "SG-bastionhosts-${var.name}"
  description = "EKS cluster communication with worker nodes"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${merge(map("Name", format("%s", var.name)), var.common_tags, var.region_tags, var.local_tags)}"
}

locals {
  lbidt = "${format("%s", join("-", split(".", var.name)))}"
}

locals {
  lbid = "${substr(format("%s", join("-", split("_", local.lbidt))), 0, length(var.name) <= 27 ? length(var.name) : 27 )}"
}

resource "aws_lb" "bastion_lb" {
  name = "lb-${local.lbid}"
  internal = false
  load_balancer_type = "application"
  security_groups = ["${aws_security_group.bastion_lb_sg.id}"]
  subnets = ["${local.subnet_ids}"]
  enable_deletion_protection = false
  tags = "${merge(map("Name", format("%s", var.name)), var.common_tags, var.region_tags, var.local_tags)}"
}

resource "aws_lb_target_group" "bastion_lb_tg" {
  name = "tg-${local.lbid}"
  port = "${var.bastion_host_ssh_port}"
  protocol = "TCP"
  vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"
}

resource "aws_lb_listener" "bastion_lb_listener" {
  load_balancer_arn = "${aws_lb.bastion_lb.arn}"
  port = "${var.bastion_host_ssh_port}"
  protocol = "tcp"
  default_action {
    type = "forward"
    target_group_arn = "${aws_lb_target_group.bastion_lb_tg.arn}"
  }
}


output "lb_dns_name" {
  value = "${aws_lb.bastion_lb.dns_name}"
}

output "bastion_sg_arn" {
  value = "${aws_security_group.bastion_sg.arn}"
}