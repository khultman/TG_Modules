variable state_bucket_name {}

resource "aws_s3_bucket" "this" {
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

  tags = "${merge(map("Name", format("%s", var.name)), var.common_tags, var.region_tags, var.local_tags)}"
}

output "BACKEND_BUCKET_NAME" {
  value = "${aws_s3_bucket.this.bucket}"
}
