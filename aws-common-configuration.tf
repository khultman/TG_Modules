variable aws_region {}
variable aws_plugin_version {}
variable aws_role_arn {}
variable aws_session_name {}

variable name {}
variable common_tags { default = {} }
variable region_tags { default = {} }
variable local_tags  { default = {} }

provider "aws" {
  version = "~> 1.50.0"
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