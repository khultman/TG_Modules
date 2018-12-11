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
