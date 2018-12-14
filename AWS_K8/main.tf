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
variable vpc_state_file { }
variable vpc_public_private_subnets { default = "public" }

variable eks_role_name { default = "eks-role" }
variable eks_cluster_name { }


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

resource "aws_iam_role_policy_attachment" "this.EKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = "${aws_iam_role.this.name}"
  tags       = "${merge(map("Name", format("%s", var.name)), var.common_tags, var.region_tags, var.local_tags)}"
}

resource "aws_iam_role_policy_attachment" "this.EKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = "${aws_iam_role.this.name}"
  tags       = "${merge(map("Name", format("%s", var.name)), var.common_tags, var.region_tags, var.local_tags)}"
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
    "aws_iam_role_policy_attachment.this.EKSClusterPolicy",
    "aws_iam_role_policy_attachment.this.EKSServicePolicy"
  ]

  tags = "${merge(map("Name", format("%s", var.name)), var.common_tags, var.region_tags, var.local_tags)}"
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

output "kubeconfig" {
  value = "${local.kubeconfig}"
}