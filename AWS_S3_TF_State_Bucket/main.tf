variable aws_region {}
variable aws_plugin_version {}
variable aws_role_arn {}
variable aws_session_name {}

variable purpose {}
variable environment {}
variable team {}
variable managed_by {}

variable state_bucket_name {}

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

resource "aws_s3_bucket" "state" {
  bucket = "${var.state_bucket_name}"
  region = "${var.aws_region}"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    "rule" {
      "apply_server_side_encryption_by_default" {
        sse_algorithm = "AES256"
      }
    }
  }

  tags {
    purpose        = "${var.purpose}"
    bm-environment = "${var.environment}"
    bm-team        = "${var.team}"
    managed-by     = "${var.managed_by}"
  }
}

output "BACKEND_BUCKET_NAME" {
  value = "${aws_s3_bucket.state.bucket}"
}
