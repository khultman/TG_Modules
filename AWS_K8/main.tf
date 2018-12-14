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

variable eks_role_name { default = "eks-role" }
variable eks_cluster_name {}


variable eks_worker_node_image { default = "Auto" }
variable eks_worker_node_instance_type { default = "m4.large" }
variable eks_worker_node_spot_instace { default = true }
variable eks_worker_node_spot_instance_bid_price { default = "0.045" }
variable eks_worker_node_desired_capacity {}
variable eks_worker_node_max_size {}
variable eks_worker_node_min_size {}


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

resource "aws_iam_role" "this" {
  name = "${var.eks_role_name}-${var.eks_cluster_name}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    "Effect": "Allow",
    "Principal": {
      "Service": "eks.amazonaws.com"
    },
    "Action": "sts:AssumeRole"
  ]
}
EOF
  tags = "${merge(map("Name", format("%s", var.name)), var.common_tags, var.region_tags, var.local_tags)}"
}

resource "aws_iam_role_policy_attachment" "EKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = "${aws_iam_role.this.name}"
  #tags       = "${merge(map("Name", format("%s", var.name)), var.common_tags, var.region_tags, var.local_tags)}"
}

resource "aws_iam_role_policy_attachment" "EKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = "${aws_iam_role.this.name}"
  #tags       = "${merge(map("Name", format("%s", var.name)), var.common_tags, var.region_tags, var.local_tags)}"
}

resource "aws_security_group" "this" {
  name        = "SG-${var.eks_cluster_name}"
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
  subnet_ids = "${ var.vpc_public_private_subnets == "public" ?
                    data.terraform_remote_state.vpc.public_route_table_ids :
                    data.terraform_remote_state.vpc.private_route_table_ids }"
}
resource "aws_eks_cluster" "this" {
  name     = "${var.eks_cluster_name}"
  role_arn = "${aws_iam_role.this.arn}"

  vpc_config {
    security_group_ids = [ "${aws_security_group.this.id}" ]
    subnet_ids         = [ "${local.subnet_ids}" ]
  }

  depends_on = [
    "aws_iam_role.this",
    "aws_iam_role_policy_attachment.EKSClusterPolicy",
    "aws_iam_role_policy_attachment.EKSServicePolicy"
  ]

  #tags = "${merge(map("Name", format("%s", var.name)), var.common_tags, var.region_tags, var.local_tags)}"
}

locals {
  kubeconfig = <<EOF
apiVersion: v1
clusters:
- cluster:
    server: ${aws_eks_cluster.this.endpoint}
    certificate-authority-data: ${aws_eks_cluster.this.certificate_authority.0.data}
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: aws
  name: aws
current-context: aws
kind: Config
preferences: {}
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: aws-iam-authenticator
      args:
        - "token"
        - "-i"
        - "${var.eks_cluster_name}"
EOF
}



resource "aws_iam_role" "worker_role" {
  name = "${var.eks_role_name}-${var.eks_cluster_name}-worker"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
  tags = "${merge(map("Name", format("%s", var.name)), var.common_tags, var.region_tags, var.local_tags)}"
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = "${aws_iam_role.worker_role.name}"
  #tags = "${merge(map("Name", format("%s", var.name)), var.common_tags, var.region_tags, var.local_tags)}"
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = "${aws_iam_role.worker_role.name}"
  #tags = "${merge(map("Name", format("%s", var.name)), var.common_tags, var.region_tags, var.local_tags)}"
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = "${aws_iam_role.worker_role.name}"
  #tags = "${merge(map("Name", format("%s", var.name)), var.common_tags, var.region_tags, var.local_tags)}"
}

resource "aws_iam_instance_profile" "this" {
  name = "${var.eks_cluster_name}-worker-profile"
  role = "${aws_iam_role.worker_role.name}"
  #tags = "${merge(map("Name", format("%s", var.name)), var.common_tags, var.region_tags, var.local_tags)}"
}

resource "aws_security_group" "worker-sg" {
  name = "SG-${var.eks_cluster_name}-worker_nodes"
  description = "Security group for all nodes in the EKS cluster"
  vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${merge(map("Name", format("%s", var.name)), var.common_tags, var.region_tags, var.local_tags)}"
}

resource "aws_security_group_rule" "worker-node-ingress-self" {
  description = "Allow worker nodes to communicate with each other"
  from_port = 0
  protocol = "-1"
  security_group_id = "${aws_security_group.worker-sg.id}"
  source_security_group_id = "${aws_security_group.worker-sg.id}"
  to_port = 65535
  type = "ingress"

  tags = "${merge(map("Name", format("%s", var.name)), var.common_tags, var.region_tags, var.local_tags)}"
}

resource "aws_security_group_rule" "worker-node-ingress-cluster" {
  description = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port = 1024
  protocol = "tcp"
  security_group_id = "${aws_security_group.worker-sg.id}"
  source_security_group_id = "${aws_security_group.worker-sg.id}"
  to_port = 65535
  type = "ingress"

  tags = "${merge(map("Name", format("%s", var.name)), var.common_tags, var.region_tags, var.local_tags)}"
}

resource "aws_security_group_rule" "worker-node-ingress-https" {
  description = "Allow pods to communicate with the cluster API Server"
  from_port = 443
  protocol = "tcp"
  security_group_id = "${aws_security_group.worker-sg.id}"
  source_security_group_id = "${aws_security_group.worker-sg.id}"
  to_port = 443
  type = "ingress"

  tags = "${merge(map("Name", format("%s", var.name)), var.common_tags, var.region_tags, var.local_tags)}"
}

data "aws_ami" "eks-worker-ami" {
  filter {
    name = "name"
    values = ["amazon-eks-node-v*"]
  }

  most_recent = true
  owners      = ["602401143452"] # Amazon EKS AMI Account ID
}

data "aws_region" "current" {}

locals {
  eks_worker_node_userdata = <<EOF
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.this.endpoint}' --b64-cluster-ca '${aws_eks_cluster.this.certificate_authority.0.data}' '${var.eks_cluster_name}'
EOF
}

resource "aws_launch_configuration" "this" {
  associate_public_ip_address = "${var.vpc_public_private_subnets == "public" ? true : false}"
  iam_instance_profile = "${aws_iam_instance_profile.this.name}"
  image_id = "${var.eks_worker_node_image != "Auto" ? var.eks_worker_node_image : data.aws_ami.eks-worker-ami.id}"
  instance_type = "${var.eks_worker_node_instance_type}"
  spot_price = "${var.eks_worker_node_spot_instance_bid_price}"
  name_prefix = "worker-${var.eks_cluster_name}-"
  security_groups = ["${aws_security_group.worker-sg.id}"]
  user_data_base64 = "${base64encode(local.eks_worker_node_userdata)}"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "this" {
  name = "eks_worker_asg-${var.eks_cluster_name}"
  desired_capacity = "${var.eks_worker_node_desired_capacity}"
  max_size = "${var.eks_worker_node_max_size}"
  min_size = "${var.eks_worker_node_min_size}"
  vpc_zone_identifier = ["${local.subnet_ids}"]
  tags = "${merge(  map("Name", format("%s", var.name)),
                    var.common_tags,
                    var.region_tags,
                    var.local_tags,
                    map( format("kubrenetes.io/cluster/%s", var.eks_cluster_name), "owned")
   )}"
}

locals {
  config_map_aws_auth = <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${aws_iam_role.worker_role.arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
EOF
}



output "arn" {
  value = "${aws_eks_cluster.this.arn}"
}

output "endpoint" {
  value = "${aws_eks_cluster.this.endpoint}"
}

output "kubeconfig-certificate-authority-data" {
  value = "${aws_eks_cluster.this.certificate_authority.0.data}"
}

output "vpc_id" {
  value = "${aws_eks_cluster.this.vpc_config.vpc_id}"
}

output "version" {
  value = "${aws_eks_cluster.this.version}"
}

output "launch_configuration_id" {
  value = "${aws_launch_configuration.this.id}"
}

output "image_id" {
  value = "${aws_launch_configuration.this.image_id}"
}

output "instance_type" {
  value = "${aws_launch_configuration.this.instance_type}"
}

output "autoscaling_arn" {
  value = "${aws_autoscaling_group.this.arn}"
}

output "kubeconfig" {
  value = "${local.kubeconfig}"
}

output "config_map_aws_auth" {
  value = "${local.config_map_aws_auth}"
}