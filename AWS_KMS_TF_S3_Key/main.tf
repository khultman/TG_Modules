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
variable kms_key_deletion_days {}
variable kms_key_alias {}

resource "aws_kms_key" "this" {
  description             = "Key used for terraform state encryption"
  deletion_window_in_days = "${var.kms_key_deletion_days}"
  enable_key_rotation     = "True"

  tags = "${merge(map("Name", format("%s", var.name)), var.common_tags, var.region_tags, var.local_tags)}"
}

resource "aws_kms_alias" "this" {
  name          = "${var.kms_key_alias}"
  target_key_id = "${aws_kms_key.this.key_id}"
}

output "terraform_state_key_arn" {
  value = "${aws_kms_key.this.arn}"
}

output "terraform_state_key_id" {
  value = "${aws_kms_key.this.key_id}"
}

output "terraform_state_key_alias" {
  value = "${aws_kms_alias.this.name}"
}
