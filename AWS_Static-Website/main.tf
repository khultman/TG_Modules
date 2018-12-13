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

variable static_site_name {}
variable static_site_bucket_name {}
variable static_site_acl {}
variable static_site_index_document {}
variable static_site_error_document {}
variable static_site_route53_zone_name {}
variable static_site_route53_domain_name {}

data "aws_route53_zone" "this" {
  name = "${var.static_site_route53_zone_name}"
}

resource "aws_s3_bucket" "this" {
  bucket = "${var.static_site_bucket_name}"
  region = "${var.aws_region}"

  acl = "${var.static_site_acl}"

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

  tags = "${merge(map("Name", format("%s", var.name)), var.common_tags, var.region_tags, var.local_tags)}"
}

resource "aws_route53_record" "this" {
  zone_id = "${data.aws_route53_zone.this.zone_id}"
  name    = "${var.static_site_route53_domain_name}"
  type    = "A"

  alias {
    name                   = "${aws_s3_bucket.this.website_domain}"
    zone_id                = "${aws_s3_bucket.this.hosted_zone_id}"
    evaluate_target_health = true
  }
}

output "static_site_bucket_name" {
  value = "${aws_s3_bucket.this.bucket}"
}

output "static_site_website_endpoint" {
  value = "${aws_s3_bucket.this.website_endpoint}"
}

output "static_site_website_domain" {
  value = "${aws_s3_bucket.this.website_domain}"
}
