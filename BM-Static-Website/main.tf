variable aws_region {}
variable aws_plugin_version {}
variable aws_role_arn {}
variable aws_session_name {}

variable purpose {}
variable environment {}
variable team {}
variable managed_by {}

variable static_site_name {}
variable static_site_bucket_name {}
variable static_site_acl {}
variable static_site_index_document {}
variable static_site_error_document {}
variable static_site_route53_zone_name {}
variable static_site_route53_domain_name {}

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

data "aws_route53_zone" "static_site_zone" {
  name = "${var.static_site_route53_zone_name}"
}

resource "aws_s3_bucket" "static-site" {
  bucket = "${var.static_site_bucket_name}"
  region = "${var.aws_region}"

  acl = "${var.static_site_acl}"

  #policy = "${file("policy.json")}"
  policy = <<EOF
{
  "Id": "static_site_policy_${var.static_site_name}",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "static_site_policy_${var.static_site_name}_main",
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.static_site_bucket_name}/*",
      "Principal": "*"
    }
  ]
}
EOF

  website {
    index_document = "${var.static_site_index_document}"
    error_document = "${var.static_site_error_document}"
  }

  tags {
    purpose        = "${var.purpose}"
    bm-environment = "${var.environment}"
    bm-team        = "${var.team}"
    managed-by     = "${var.managed_by}"
  }
}

resource "aws_route53_record" "static_site_domain" {
  zone_id = "${data.aws_route53_zone.static_site_zone.zone_id}"
  name    = "${var.static_site_route53_domain_name}"
  type    = "A"

  alias {
    name                   = "${aws_s3_bucket.static-site.website_domain}"
    zone_id                = "${aws_s3_bucket.static-site.hosted_zone_id}"
    evaluate_target_health = true
  }
}

output "static_site_bucket_name" {
  value = "${aws_s3_bucket.static-site.bucket}"
}

output "static_site_website_endpoint" {
  value = "${aws_s3_bucket.static-site.website_endpoint}"
}

output "static_site_website_domain" {
  value = "${aws_s3_bucket.static-site.website_domain}"
}
