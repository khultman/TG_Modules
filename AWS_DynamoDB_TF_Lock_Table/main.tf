
variable dynamodb_read_capacity {}
variable dynamodb_write_capacity {}

resource "aws_dynamodb_table" "this" {
  name           = "${var.lock_table_name}"
  read_capacity  = "${var.dynamodb_read_capacity}"
  write_capacity = "${var.dynamodb_write_capacity}"
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = "${merge(map("Name", format("%s", var.name)), var.common_tags, var.region_tags, var.local_tags)}"
}

output "BACKEND_TABLE_NAME" {
  value = "${aws_dynamodb_table.this.name}"
}
