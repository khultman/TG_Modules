variable aws_region {}
variable state_bucket_name {}
variable lock_table_name {}
variable kms_key_id {}
variable ecosystem_config { type = "map" }

variable aws_plugin_version {}
variable aws_role_arn {}
variable aws_session_name {}

variable name {}
variable common_tags { default = {} }
variable region_tags { default = {} }
variable local_tags  { default = {} }

variable ssh_key_name { default = "" }

variable bastion_backend { default = "s3" }
variable bastion_state_file {}

provider "aws" {
  version = "=1.50.0"
  region  = "${var.aws_region}"

  assume_role {
    role_arn     = "${var.aws_role_arn}"
    session_name = "${var.aws_session_name}"
  }
}

terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}