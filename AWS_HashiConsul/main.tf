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

variable consul_version { default = "1.4.1" }

variable image_ami { default = "Auto" }
variable instance_type { default = "m5.large" }

variable cluster_name {}
variable cluster_size {}
variable spot_price { default = "0.055" }

variable cluster_tag_key {}
variable cluster_tag_value {}


locals {
  consul_linux_zip_url = "https://releases.hashicorp.com/consul/consule_${var.consul_version}/consul_${var.consul_version}_linux_amd64.zip"
  consul_SHA256SUMS_url = "https://releases.hashicorp.com/consul/consule_${var.consul_version}/consul_${var.consul_version}_SHA256SUMS"
  consul_SHA256SUMS_sig_url = "https://releases.hashicorp.com/consul/consule_${var.consul_version}/consul_${var.consul_version}_SHA256SUMS.sig"
}

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

data "terraform_remote_state" "bastion" {
  backend = "${var.bastion_backend}"
  config {
    bucket = "${var.state_bucket_name}"
    region = "${var.aws_region}"
    key = "${var.bastion_state_file}"
    encrypt = true
    dynamodb_table = "${var.lock_table_name}"
    kms_key_id = "${var.kms_key_id}"
  }
}

data "aws_ami" "this" {
  most_recent = true

  owners = ["562637147889"]

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "is-public"
    values = ["true"]
  }

  filter {
    name   = "name"
    values = ["consul-ubuntu-*"]
  }
}

data "template_file" "user_data_server" {
  template = "${file("${path.module}/user-data-server.sh")}"

  vars {
    cluster_tag_key   = "${var.cluster_tag_key}"
    cluster_tag_value = "${var.cluster_name}"
  }
}

resource "aws_security_group" "consul-sg" {
  name = "SG-${var.aws_region}-${var.name}"
  description = "Security group for the Consul Nodes"
  vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${merge(map("Name", format("%s", var.name)), var.common_tags, var.region_tags, var.local_tags)}"
}

resource "aws_security_group_rule" "consul-sg-rule1" {
  description = "Allow bastion hosts to ssh into consul nodes"
  from_port = 22
  protocol = "TCP"
  security_group_id = "${aws_security_group.consul-sg.id}"
  source_security_group_id = "${data.terraform_remote_state.bastion.bastion_sg_id}"
  to_port = 22
  type = "ingress"
}

resource "aws_security_group_rule" "consul-sg-rule1" {
  description = "Allow consul agent traffic"
  from_port = 8300
  protocol = "TCP"
  security_group_id = "${aws_security_group.consul-sg.id}"
  to_port = 8300
  cidr_blocks = ["0.0.0.0/0"]
  type = "ingress"
}

resource "aws_security_group_rule" "consul-sg-rule2" {
  description = "Allow consul gossip traffic"
  from_port = 8301
  protocol = "TCP"
  security_group_id = "${aws_security_group.consul-sg.id}"
  to_port = 8301
  cidr_blocks = ["0.0.0.0/0"]
  type = "ingress"
}

resource "aws_security_group_rule" "consul-sg-rule3" {
  description = "Allow consul gossip traffic"
  from_port = 8301
  protocol = "UDP"
  security_group_id = "${aws_security_group.consul-sg.id}"
  to_port = 8301
  cidr_blocks = ["0.0.0.0/0"]
  type = "ingress"
}

resource "aws_security_group_rule" "consul-sg-rule4" {
  description = "Allow consul gossip traffic"
  from_port = 8302
  protocol = "TCP"
  security_group_id = "${aws_security_group.consul-sg.id}"
  to_port = 8302
  cidr_blocks = ["0.0.0.0/0"]
  type = "ingress"
}

resource "aws_security_group_rule" "consul-sg-rule5" {
  description = "Allow consul gossip traffic"
  from_port = 8302
  protocol = "UDP"
  security_group_id = "${aws_security_group.consul-sg.id}"
  to_port = 8302
  cidr_blocks = ["0.0.0.0/0"]
  type = "ingress"
}

resource "aws_security_group_rule" "consul-sg-rule6" {
  description = "Allow consul HTTP API traffic"
  from_port = 8500
  protocol = "TCP"
  security_group_id = "${aws_security_group.consul-sg.id}"
  to_port = 8500
  cidr_blocks = ["0.0.0.0/0"]
  type = "ingress"
}

resource "aws_security_group_rule" "consul-sg-rule7" {
  description = "Allow consul DNS traffic"
  from_port = 8600
  protocol = "TCP"
  security_group_id = "${aws_security_group.consul-sg.id}"
  to_port = 8600
  cidr_blocks = ["0.0.0.0/0"]
  type = "ingress"
}

resource "aws_security_group_rule" "consul-sg-rule8" {
  description = "Allow consul DNS traffic"
  from_port = 8600
  protocol = "UDP"
  security_group_id = "${aws_security_group.consul-sg.id}"
  to_port = 8600
  cidr_blocks = ["0.0.0.0/0"]
  type = "ingress"
}