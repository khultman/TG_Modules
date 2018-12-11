variable aws_region {}
variable aws_plugin_version {}
variable aws_role_arn {}
variable aws_session_name {}

variable purpose {}
variable environment {}
variable team {}
variable managed_by {}

variable lock_table_name {}
variable dynamodb_read_capacity {}
variable dynamodb_write_capacity {}

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

resource "aws_dynamodb_table" "locking" {
  name           = "${var.lock_table_name}"
  read_capacity  = "${var.dynamodb_read_capacity}"
  write_capacity = "${var.dynamodb_write_capacity}"
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags {
    purpose        = "${var.purpose}"
    bm-environment = "${var.environment}"
    bm-team        = "${var.team}"
    managed-by     = "${var.managed_by}"
  }
}

output "BACKEND_TABLE_NAME" {
  value = "${aws_dynamodb_table.locking.name}"
}
