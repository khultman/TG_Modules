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

variable provider { default = "aws" }

variable requester_auto_accept { default = false }
variable requester_backend { default = "s3" }
variable requester_state_file {}
variable requester_route_table_public_private { default = "public" }
variable requester_route_table_idx { default = 0 }

variable accepter_auto_accept { default = true }
variable accepter_backend { default = "s3" }
variable accepter_state_file {}
variable accepter_route_table_public_private { default = "private" }
variable accepter_route_table_idx { default = 0 }

data "aws_caller_identity" "caller" {
  provider = "aws"
}
data "terraform_remote_state" "requester_state" {
  backend = "${var.requester_backend}"
  config { "${ merge( "${var.ecosystem_config}", map("key", "${var.requester_state_file}") ) }" }
}

data "terraform_remote_state" "accepter_state" {
  backend = "${var.accepter_backend}"
  config { "${ merge( "${var.ecosystem_config}", map("key", "${var.accepter_state_file}") ) }" }
}

resource "aws_vpc_peering_connection" "requester" {
  //provider = "${data.terraform_remote_state.requester_state.provider ? data.terraform_remote_state.requester_state.provider : var.provider}"
  vpc_id = "${data.terraform_remote_state.requester_state.id}"
  peer_vpc_id = "${data.terraform_remote_state.accepter_state.id}"
  peer_owner_id = "${data.aws_caller_identity.caller.account_id}"
  peer_region = "${var.aws_region}"
  auto_accept = "${var.requester_auto_accept}"

  tags = "${merge(map("Name", format("%s", var.name)), var.common_tags, var.region_tags, var.local_tags)}"
}

resource "aws_vpc_peering_connection_accepter" "accepter" {
  //provider = "${data.terraform_remote_state.accepter_state.provider ? data.terraform_remote_state.accepter_state.provider : var.provider}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.requester.id}"
  auto_accept = "${var.accepter_auto_accept}"

  tags = "${merge(map("Name", format("%s", var.name)), var.common_tags, var.region_tags, var.local_tags)}"
}

resource "aws_route" "requester_to_accepter_route" {
  //provider = "${data.terraform_remote_state.requester_state.provider ? data.terraform_remote_state.requester_state.provider : var.provider}"
  route_table_id = "${var.requester_route_table_public_private == "public" ?
                      data.terraform_remote_state.requester_state.public_route_table_id[var.requester_route_table_idx] :
                      data.terraform_remote_state.requester_state.private_route_table_id[var.requester_route_table_idx]
                      }"
  destination_cidr_block = "${data.terraform_remote_state.accepter_state.vpc_cidr}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.requester.id}"
}

resource "aws_route" "appter_to_requester_route" {
  //provider = "${data.terraform_remote_state.accepter_state.provider ? data.terraform_remote_state.accepter_state.provider : var.provider}"
  route_table_id = "${var.accepter_route_table_public_private == "public" ?
                      data.terraform_remote_state.accepter_state.public_route_table_id[var.accepter_route_table_idx] :
                      data.terraform_remote_state.accepter_state.private_route_table_id[var.accepter_route_table_idx]
                      }"
  destination_cidr_block = "${data.terraform_remote_state.requester_state.vpc_cidr}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.requester.id}"
}