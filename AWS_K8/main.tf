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

resource "aws_iam_role" "this" {
  name = "eks-rols"

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
}

resource "aws_iam_role_policy_attachment" "ClusterPolicy" {
  policy_arn = ""
  role = "${aws_iam_role.this.name}"
}