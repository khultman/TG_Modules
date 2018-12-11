variable aws_region {}
variable aws_plugin_version {}
variable aws_role_arn {}
variable aws_session_name {}

variable purpose {}
variable environment {}
variable team {}
variable managed_by {}

variable kms_key_deletion_days {}
variable kms_key_alias {}

provider "aws" {
  version = "~> 1.50"
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

resource "aws_kms_key" "terraform_state_key" {
  description             = "Key used for terraform state encryption"
  deletion_window_in_days = "${var.kms_key_deletion_days}"
  enable_key_rotation     = "True"

  tags {
    purpose        = "${var.purpose}"
    bm-environment = "${var.environment}"
    bm-team        = "${var.team}"
    managed-by     = "${var.managed_by}"
  }
}

resource "aws_kms_alias" "terraform_state_key" {
  name          = "${var.kms_key_alias}"
  target_key_id = "${aws_kms_key.terraform_state_key.key_id}"
}

output "terraform_state_key_arn" {
  value = "${aws_kms_key.terraform_state_key.arn}"
}

output "terraform_state_key_id" {
  value = "${aws_kms_key.terraform_state_key.key_id}"
}

output "terraform_state_key_alias" {
  value = "${aws_kms_alias.terraform_state_key.name}"
}
