### This is copied from https://github.com/terraform-aws-modules/terraform-aws-vpc
### With adjustments as needed to work with terragrunt
### Modifications to how tagging has been done to conform to how I use tags
### var.tags, var.common_tags, var.region_tags, var.local_tags
### instead of just var.tags

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

variable "create_vpc" {
  description = "Controls if VPC should be created (it affects almost all resources)"
  default     = true
}

variable "cidr" {
  description = "The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overridden"
  default     = "0.0.0.0/0"
}

variable "assign_generated_ipv6_cidr_block" {
  description = "Requests an Amazon-provided IPv6 CIDR block with a /56 prefix length for the VPC. You cannot specify the range of IP addresses, or the size of the CIDR block"
  default     = false
}

variable "secondary_cidr_blocks" {
  description = "List of secondary CIDR blocks to associate with the VPC to extend the IP Address pool"
  default     = []
}

variable "instance_tenancy" {
  description = "A tenancy option for instances launched into the VPC"
  default     = "default"
}

variable "public_subnet_suffix" {
  description = "Suffix to append to public subnets name"
  default     = "public"
}

variable "private_subnet_suffix" {
  description = "Suffix to append to private subnets name"
  default     = "private"
}

variable "database_subnet_suffix" {
  description = "Suffix to append to database subnets name"
  default     = "db"
}

variable "redshift_subnet_suffix" {
  description = "Suffix to append to redshift subnets name"
  default     = "redshift"
}

variable "elasticache_subnet_suffix" {
  description = "Suffix to append to elasticache subnets name"
  default     = "elasticache"
}

variable "public_subnets" {
  description = "A list of public subnets inside the VPC"
  default     = []
}

variable "private_subnets" {
  description = "A list of private subnets inside the VPC"
  default     = []
}

variable "database_subnets" {
  type        = "list"
  description = "A list of database subnets"
  default     = []
}

variable "redshift_subnets" {
  type        = "list"
  description = "A list of redshift subnets"
  default     = []
}

variable "elasticache_subnets" {
  type        = "list"
  description = "A list of elasticache subnets"
  default     = []
}

variable "create_database_subnet_route_table" {
  description = "Controls if separate route table for database should be created"
  default     = false
}

variable "create_redshift_subnet_route_table" {
  description = "Controls if separate route table for redshift should be created"
  default     = false
}

variable "create_elasticache_subnet_route_table" {
  description = "Controls if separate route table for elasticache should be created"
  default     = false
}

variable "intra_subnets" {
  type        = "list"
  description = "A list of intra subnets"
  default     = []
}

variable "create_database_subnet_group" {
  description = "Controls if database subnet group should be created"
  default     = true
}

variable "azs" {
  description = "A list of availability zones in the region"
  default     = []
}

variable "enable_dns_hostnames" {
  description = "Should be true to enable DNS hostnames in the VPC"
  default     = true
}

variable "enable_dns_support" {
  description = "Should be true to enable DNS support in the VPC"
  default     = true
}

variable "enable_nat_gateway" {
  description = "Should be true if you want to provision NAT Gateways for each of your private networks"
  default     = false
}

variable "single_nat_gateway" {
  description = "Should be true if you want to provision a single shared NAT Gateway across all of your private networks"
  default     = false
}

variable "one_nat_gateway_per_az" {
  description = "Should be true if you want only one NAT Gateway per availability zone. Requires `var.azs` to be set, and the number of `public_subnets` created to be greater than or equal to the number of availability zones specified in `var.azs`."
  default     = false
}

variable "reuse_nat_ips" {
  description = "Should be true if you don't want EIPs to be created for your NAT Gateways and will instead pass them in via the 'external_nat_ip_ids' variable"
  default     = false
}

variable "external_nat_ip_ids" {
  description = "List of EIP IDs to be assigned to the NAT Gateways (used in combination with reuse_nat_ips)"
  type        = "list"
  default     = []
}

variable "enable_dynamodb_endpoint" {
  description = "Should be true if you want to provision a DynamoDB endpoint to the VPC"
  default     = false
}

variable "enable_s3_endpoint" {
  description = "Should be true if you want to provision an S3 endpoint to the VPC"
  default     = false
}

variable "map_public_ip_on_launch" {
  description = "Should be false if you do not want to auto-assign public IP on launch"
  default     = true
}

variable "enable_vpn_gateway" {
  description = "Should be true if you want to create a new VPN Gateway resource and attach it to the VPC"
  default     = false
}

variable "vpn_gateway_id" {
  description = "ID of VPN Gateway to attach to the VPC"
  default     = ""
}

variable "amazon_side_asn" {
  description = "The Autonomous System Number (ASN) for the Amazon side of the gateway. By default the virtual private gateway is created with the current default Amazon ASN."
  default     = "64512"
}

variable "propagate_private_route_tables_vgw" {
  description = "Should be true if you want route table propagation"
  default     = false
}

variable "propagate_public_route_tables_vgw" {
  description = "Should be true if you want route table propagation"
  default     = false
}

variable "tags" {
  description = "A map of tags to add to all resources"
  default     = {}
}

variable "vpc_tags" {
  description = "Additional tags for the VPC"
  default     = {}
}

variable "igw_tags" {
  description = "Additional tags for the internet gateway"
  default     = {}
}

variable "public_subnet_tags" {
  description = "Additional tags for the public subnets"
  default     = {}
}

variable "private_subnet_tags" {
  description = "Additional tags for the private subnets"
  default     = {}
}

variable "public_route_table_tags" {
  description = "Additional tags for the public route tables"
  default     = {}
}

variable "private_route_table_tags" {
  description = "Additional tags for the private route tables"
  default     = {}
}

variable "database_route_table_tags" {
  description = "Additional tags for the database route tables"
  default     = {}
}

variable "redshift_route_table_tags" {
  description = "Additional tags for the redshift route tables"
  default     = {}
}

variable "elasticache_route_table_tags" {
  description = "Additional tags for the elasticache route tables"
  default     = {}
}

variable "intra_route_table_tags" {
  description = "Additional tags for the intra route tables"
  default     = {}
}

variable "database_subnet_tags" {
  description = "Additional tags for the database subnets"
  default     = {}
}

variable "database_subnet_group_tags" {
  description = "Additional tags for the database subnet group"
  default     = {}
}

variable "redshift_subnet_tags" {
  description = "Additional tags for the redshift subnets"
  default     = {}
}

variable "redshift_subnet_group_tags" {
  description = "Additional tags for the redshift subnet group"
  default     = {}
}

variable "elasticache_subnet_tags" {
  description = "Additional tags for the elasticache subnets"
  default     = {}
}

variable "intra_subnet_tags" {
  description = "Additional tags for the intra subnets"
  default     = {}
}

variable "dhcp_options_tags" {
  description = "Additional tags for the DHCP option set"
  default     = {}
}

variable "nat_gateway_tags" {
  description = "Additional tags for the NAT gateways"
  default     = {}
}

variable "nat_eip_tags" {
  description = "Additional tags for the NAT EIP"
  default     = {}
}

variable "vpn_gateway_tags" {
  description = "Additional tags for the VPN gateway"
  default     = {}
}

variable "enable_dhcp_options" {
  description = "Should be true if you want to specify a DHCP options set with a custom domain name, DNS servers, NTP servers, netbios servers, and/or netbios server type"
  default     = false
}

variable "dhcp_options_domain_name" {
  description = "Specifies DNS name for DHCP options set"
  default     = ""
}

variable "dhcp_options_domain_name_servers" {
  description = "Specify a list of DNS server addresses for DHCP options set, default to AWS provided"
  type        = "list"
  default     = ["AmazonProvidedDNS"]
}

variable "dhcp_options_ntp_servers" {
  description = "Specify a list of NTP servers for DHCP options set"
  type        = "list"
  default     = []
}

variable "dhcp_options_netbios_name_servers" {
  description = "Specify a list of netbios servers for DHCP options set"
  type        = "list"
  default     = []
}

variable "dhcp_options_netbios_node_type" {
  description = "Specify netbios node_type for DHCP options set"
  default     = ""
}

variable "manage_default_vpc" {
  description = "Should be true to adopt and manage Default VPC"
  default     = false
}

variable "default_vpc_name" {
  description = "Name to be used on the Default VPC"
  default     = ""
}

variable "default_vpc_enable_dns_support" {
  description = "Should be true to enable DNS support in the Default VPC"
  default     = true
}

variable "default_vpc_enable_dns_hostnames" {
  description = "Should be true to enable DNS hostnames in the Default VPC"
  default     = true
}

variable "default_vpc_enable_classiclink" {
  description = "Should be true to enable ClassicLink in the Default VPC"
  default     = false
}

variable "default_vpc_tags" {
  description = "Additional tags for the Default VPC"
  default     = {}
}

locals {
  max_subnet_length = "${max(length(var.private_subnets), length(var.elasticache_subnets), length(var.database_subnets), length(var.redshift_subnets))}"
  nat_gateway_count = "${var.single_nat_gateway ? 1 : (var.one_nat_gateway_per_az ? length(var.azs) : local.max_subnet_length)}"

  # Use `local.vpc_id` to give a hint to Terraform that subnets should be deleted before secondary CIDR blocks can be free!
  vpc_id = "${element(concat(aws_vpc_ipv4_cidr_block_association.this.*.vpc_id, aws_vpc.this.*.id, list("")), 0)}"
}

######
# VPC
######
resource "aws_vpc" "this" {
  count = "${var.create_vpc ? 1 : 0}"

  cidr_block                       = "${var.cidr}"
  instance_tenancy                 = "${var.instance_tenancy}"
  enable_dns_hostnames             = "${var.enable_dns_hostnames}"
  enable_dns_support               = "${var.enable_dns_support}"
  assign_generated_ipv6_cidr_block = "${var.assign_generated_ipv6_cidr_block}"

  tags = "${merge(map("Name", format("%s", var.name)), var.tags, var.common_tags, var.region_tags, var.local_tags, var.vpc_tags)}"
}

resource "aws_vpc_ipv4_cidr_block_association" "this" {
  count = "${var.create_vpc && length(var.secondary_cidr_blocks) > 0 ? length(var.secondary_cidr_blocks) : 0}"

  vpc_id = "${aws_vpc.this.id}"

  cidr_block = "${element(var.secondary_cidr_blocks, count.index)}"
}

###################
# DHCP Options Set
###################
resource "aws_vpc_dhcp_options" "this" {
  count = "${var.create_vpc && var.enable_dhcp_options ? 1 : 0}"

  domain_name          = "${var.dhcp_options_domain_name}"
  domain_name_servers  = ["${var.dhcp_options_domain_name_servers}"]
  ntp_servers          = ["${var.dhcp_options_ntp_servers}"]
  netbios_name_servers = ["${var.dhcp_options_netbios_name_servers}"]
  netbios_node_type    = "${var.dhcp_options_netbios_node_type}"

  tags = "${merge(map("Name", format("%s", var.name)), var.tags, var.common_tags, var.region_tags, var.local_tags, var.dhcp_options_tags)}"
}

###############################
# DHCP Options Set Association
###############################
resource "aws_vpc_dhcp_options_association" "this" {
  count = "${var.create_vpc && var.enable_dhcp_options ? 1 : 0}"

  vpc_id          = "${local.vpc_id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.this.id}"
}

###################
# Internet Gateway
###################
resource "aws_internet_gateway" "this" {
  count = "${var.create_vpc && length(var.public_subnets) > 0 ? 1 : 0}"

  vpc_id = "${local.vpc_id}"

  tags = "${merge(map("Name", format("%s", var.name)), var.tags, var.common_tags, var.region_tags, var.local_tags, var.igw_tags)}"
}

################
# Publiс routes
################
resource "aws_route_table" "public" {
  count = "${var.create_vpc && length(var.public_subnets) > 0 ? 1 : 0}"

  vpc_id = "${local.vpc_id}"

  tags = "${merge(map("Name", format("%s-${var.public_subnet_suffix}", var.name)), var.tags, var.common_tags, var.region_tags, var.local_tags, var.public_route_table_tags)}"
}

resource "aws_route" "public_internet_gateway" {
  count = "${var.create_vpc && length(var.public_subnets) > 0 ? 1 : 0}"

  route_table_id         = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.this.id}"

  timeouts {
    create = "5m"
  }
}

#################
# Private routes
# There are so many routing tables as the largest amount of subnets of each type (really?)
#################
resource "aws_route_table" "private" {
  count = "${var.create_vpc && local.max_subnet_length > 0 ? local.nat_gateway_count >= 1 ? local.nat_gateway_count : 1 : 0}"

  vpc_id = "${local.vpc_id}"

  tags = "${merge(map("Name", (var.single_nat_gateway ? "${var.name}-${var.private_subnet_suffix}" : format("%s-${var.private_subnet_suffix}-%s", var.name, element(var.azs, count.index)))), var.tags, var.common_tags, var.region_tags, var.local_tags, var.private_route_table_tags)}"

  lifecycle {
    # When attaching VPN gateways it is common to define aws_vpn_gateway_route_propagation
    # resources that manipulate the attributes of the routing table (typically for the private subnets)
    ignore_changes = ["propagating_vgws"]
  }
}

#################
# Database routes
#################
resource "aws_route_table" "database" {
  count = "${var.create_vpc && var.create_database_subnet_route_table && length(var.database_subnets) > 0 ? 1 : 0}"

  vpc_id = "${local.vpc_id}"

  tags = "${merge(var.tags, var.database_route_table_tags, map("Name", "${var.name}-${var.database_subnet_suffix}"), var.tags, var.common_tags, var.region_tags, var.local_tags)}"
}

#################
# Redshift routes
#################
resource "aws_route_table" "redshift" {
  count = "${var.create_vpc && var.create_redshift_subnet_route_table && length(var.redshift_subnets) > 0 ? 1 : 0}"

  vpc_id = "${local.vpc_id}"

  tags = "${merge(var.tags, var.redshift_route_table_tags, map("Name", "${var.name}-${var.redshift_subnet_suffix}"), var.tags, var.common_tags, var.region_tags, var.local_tags)}"
}

#################
# Elasticache routes
#################
resource "aws_route_table" "elasticache" {
  count = "${var.create_vpc && var.create_elasticache_subnet_route_table && length(var.elasticache_subnets) > 0 ? 1 : 0}"

  vpc_id = "${local.vpc_id}"

  tags = "${merge(var.tags, var.elasticache_route_table_tags, map("Name", "${var.name}-${var.elasticache_subnet_suffix}"), var.tags, var.common_tags, var.region_tags, var.local_tags)}"
}

#################
# Intra routes
#################
resource "aws_route_table" "intra" {
  count = "${var.create_vpc && length(var.intra_subnets) > 0 ? 1 : 0}"

  vpc_id = "${local.vpc_id}"

  tags = "${merge(map("Name", "${var.name}-intra"), var.tags, var.intra_route_table_tags)}"
}

################
# Public subnet
################
resource "aws_subnet" "public" {
  count = "${var.create_vpc && length(var.public_subnets) > 0 && (!var.one_nat_gateway_per_az || length(var.public_subnets) >= length(var.azs)) ? length(var.public_subnets) : 0}"

  vpc_id                  = "${local.vpc_id}"
  cidr_block              = "${element(concat(var.public_subnets, list("")), count.index)}"
  availability_zone       = "${element(var.azs, count.index)}"
  map_public_ip_on_launch = "${var.map_public_ip_on_launch}"

  tags = "${merge(map("Name", format("%s-${var.public_subnet_suffix}-%s", var.name, element(var.azs, count.index))), var.tags, var.public_subnet_tags)}"
}

#################
# Private subnet
#################
resource "aws_subnet" "private" {
  count = "${var.create_vpc && length(var.private_subnets) > 0 ? length(var.private_subnets) : 0}"

  vpc_id            = "${local.vpc_id}"
  cidr_block        = "${var.private_subnets[count.index]}"
  availability_zone = "${element(var.azs, count.index)}"

  tags = "${merge(map("Name", format("%s-${var.private_subnet_suffix}-%s", var.name, element(var.azs, count.index))), var.tags, var.common_tags, var.region_tags, var.local_tags, var.private_subnet_tags)}"
}

##################
# Database subnet
##################
resource "aws_subnet" "database" {
  count = "${var.create_vpc && length(var.database_subnets) > 0 ? length(var.database_subnets) : 0}"

  vpc_id            = "${local.vpc_id}"
  cidr_block        = "${var.database_subnets[count.index]}"
  availability_zone = "${element(var.azs, count.index)}"

  tags = "${merge(map("Name", format("%s-${var.database_subnet_suffix}-%s", var.name, element(var.azs, count.index))), var.tags, var.common_tags, var.region_tags, var.local_tags, var.database_subnet_tags)}"
}

resource "aws_db_subnet_group" "database" {
  count = "${var.create_vpc && length(var.database_subnets) > 0 && var.create_database_subnet_group ? 1 : 0}"

  name        = "${lower(var.name)}"
  description = "Database subnet group for ${var.name}"
  subnet_ids  = ["${aws_subnet.database.*.id}"]

  tags = "${merge(map("Name", format("%s", var.name)), var.tags, var.common_tags, var.region_tags, var.local_tags, var.database_subnet_group_tags)}"
}

##################
# Redshift subnet
##################
resource "aws_subnet" "redshift" {
  count = "${var.create_vpc && length(var.redshift_subnets) > 0 ? length(var.redshift_subnets) : 0}"

  vpc_id            = "${local.vpc_id}"
  cidr_block        = "${var.redshift_subnets[count.index]}"
  availability_zone = "${element(var.azs, count.index)}"

  tags = "${merge(map("Name", format("%s-${var.redshift_subnet_suffix}-%s", var.name, element(var.azs, count.index))), var.tags, var.common_tags, var.region_tags, var.local_tags, var.redshift_subnet_tags)}"
}

resource "aws_redshift_subnet_group" "redshift" {
  count = "${var.create_vpc && length(var.redshift_subnets) > 0 ? 1 : 0}"

  name        = "${lower(var.name)}"
  description = "Redshift subnet group for ${var.name}"
  subnet_ids  = ["${aws_subnet.redshift.*.id}"]

  tags = "${merge(map("Name", format("%s", var.name)), var.tags, var.common_tags, var.region_tags, var.local_tags, var.redshift_subnet_group_tags)}"
}

#####################
# ElastiCache subnet
#####################
resource "aws_subnet" "elasticache" {
  count = "${var.create_vpc && length(var.elasticache_subnets) > 0 ? length(var.elasticache_subnets) : 0}"

  vpc_id            = "${local.vpc_id}"
  cidr_block        = "${var.elasticache_subnets[count.index]}"
  availability_zone = "${element(var.azs, count.index)}"

  tags = "${merge(map("Name", format("%s-${var.elasticache_subnet_suffix}-%s", var.name, element(var.azs, count.index))), var.tags, var.common_tags, var.region_tags, var.local_tags, var.elasticache_subnet_tags)}"
}

resource "aws_elasticache_subnet_group" "elasticache" {
  count = "${var.create_vpc && length(var.elasticache_subnets) > 0 ? 1 : 0}"

  name        = "${var.name}"
  description = "ElastiCache subnet group for ${var.name}"
  subnet_ids  = ["${aws_subnet.elasticache.*.id}"]
}

#####################################################
# intra subnets - private subnet without NAT gateway
#####################################################
resource "aws_subnet" "intra" {
  count = "${var.create_vpc && length(var.intra_subnets) > 0 ? length(var.intra_subnets) : 0}"

  vpc_id            = "${local.vpc_id}"
  cidr_block        = "${var.intra_subnets[count.index]}"
  availability_zone = "${element(var.azs, count.index)}"

  tags = "${merge(map("Name", format("%s-intra-%s", var.name, element(var.azs, count.index))), var.tags, var.common_tags, var.region_tags, var.local_tags, var.intra_subnet_tags)}"
}

##############
# NAT Gateway
##############
# Workaround for interpolation not being able to "short-circuit" the evaluation of the conditional branch that doesn't end up being used
# Source: https://github.com/hashicorp/terraform/issues/11566#issuecomment-289417805
#
# The logical expression would be
#
#    nat_gateway_ips = var.reuse_nat_ips ? var.external_nat_ip_ids : aws_eip.nat.*.id
#
# but then when count of aws_eip.nat.*.id is zero, this would throw a resource not found error on aws_eip.nat.*.id.
locals {
  nat_gateway_ips = "${split(",", (var.reuse_nat_ips ? join(",", var.external_nat_ip_ids) : join(",", aws_eip.nat.*.id)))}"
}

resource "aws_eip" "nat" {
  count = "${var.create_vpc && (var.enable_nat_gateway && !var.reuse_nat_ips) ? local.nat_gateway_count : 0}"

  vpc = true

  tags = "${merge(map("Name", format("%s-%s", var.name, element(var.azs, (var.single_nat_gateway ? 0 : count.index)))), var.tags, var.common_tags, var.region_tags, var.local_tags, var.nat_eip_tags)}"
}

resource "aws_nat_gateway" "this" {
  count = "${var.create_vpc && var.enable_nat_gateway ? local.nat_gateway_count : 0}"

  allocation_id = "${element(local.nat_gateway_ips, (var.single_nat_gateway ? 0 : count.index))}"
  subnet_id     = "${element(aws_subnet.public.*.id, (var.single_nat_gateway ? 0 : count.index))}"

  tags = "${merge(map("Name", format("%s-%s", var.name, element(var.azs, (var.single_nat_gateway ? 0 : count.index)))), var.tags, var.common_tags, var.region_tags, var.local_tags, var.nat_gateway_tags)}"

  depends_on = ["aws_internet_gateway.this"]
}

resource "aws_route" "private_nat_gateway" {
  count = "${var.create_vpc && var.enable_nat_gateway ? local.nat_gateway_count : 0}"

  route_table_id         = "${element(aws_route_table.private.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${element(aws_nat_gateway.this.*.id, count.index)}"

  timeouts {
    create = "5m"
  }
}

######################
# VPC Endpoint for S3
######################
data "aws_vpc_endpoint_service" "s3" {
  count = "${var.create_vpc && var.enable_s3_endpoint ? 1 : 0}"

  service = "s3"
}

resource "aws_vpc_endpoint" "s3" {
  count = "${var.create_vpc && var.enable_s3_endpoint ? 1 : 0}"

  vpc_id       = "${local.vpc_id}"
  service_name = "${data.aws_vpc_endpoint_service.s3.service_name}"
}

resource "aws_vpc_endpoint_route_table_association" "private_s3" {
  count = "${var.create_vpc && var.enable_s3_endpoint ? local.nat_gateway_count : 0}"

  vpc_endpoint_id = "${aws_vpc_endpoint.s3.id}"
  route_table_id  = "${element(aws_route_table.private.*.id, count.index)}"
}

resource "aws_vpc_endpoint_route_table_association" "intra_s3" {
  count = "${var.create_vpc && var.enable_s3_endpoint && length(var.intra_subnets) > 0 ? 1 : 0}"

  vpc_endpoint_id = "${aws_vpc_endpoint.s3.id}"
  route_table_id  = "${element(aws_route_table.intra.*.id, 0)}"
}

resource "aws_vpc_endpoint_route_table_association" "public_s3" {
  count = "${var.create_vpc && var.enable_s3_endpoint && length(var.public_subnets) > 0 ? 1 : 0}"

  vpc_endpoint_id = "${aws_vpc_endpoint.s3.id}"
  route_table_id  = "${aws_route_table.public.id}"
}

############################
# VPC Endpoint for DynamoDB
############################
data "aws_vpc_endpoint_service" "dynamodb" {
  count = "${var.create_vpc && var.enable_dynamodb_endpoint ? 1 : 0}"

  service = "dynamodb"
}

resource "aws_vpc_endpoint" "dynamodb" {
  count = "${var.create_vpc && var.enable_dynamodb_endpoint ? 1 : 0}"

  vpc_id       = "${local.vpc_id}"
  service_name = "${data.aws_vpc_endpoint_service.dynamodb.service_name}"
}

resource "aws_vpc_endpoint_route_table_association" "private_dynamodb" {
  count = "${var.create_vpc && var.enable_dynamodb_endpoint ? local.nat_gateway_count : 0}"

  vpc_endpoint_id = "${aws_vpc_endpoint.dynamodb.id}"
  route_table_id  = "${element(aws_route_table.private.*.id, count.index)}"
}

resource "aws_vpc_endpoint_route_table_association" "intra_dynamodb" {
  count = "${var.create_vpc && var.enable_dynamodb_endpoint && length(var.intra_subnets) > 0 ? 1 : 0}"

  vpc_endpoint_id = "${aws_vpc_endpoint.dynamodb.id}"
  route_table_id  = "${element(aws_route_table.intra.*.id, 0)}"
}

resource "aws_vpc_endpoint_route_table_association" "public_dynamodb" {
  count = "${var.create_vpc && var.enable_dynamodb_endpoint && length(var.public_subnets) > 0 ? 1 : 0}"

  vpc_endpoint_id = "${aws_vpc_endpoint.dynamodb.id}"
  route_table_id  = "${aws_route_table.public.id}"
}

##########################
# Route table association
##########################
resource "aws_route_table_association" "private" {
  count = "${var.create_vpc && length(var.private_subnets) > 0 ? length(var.private_subnets) : 0}"

  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, (var.single_nat_gateway ? 0 : count.index))}"
}

resource "aws_route_table_association" "database" {
  count = "${var.create_vpc && length(var.database_subnets) > 0 ? length(var.database_subnets) : 0}"

  subnet_id      = "${element(aws_subnet.database.*.id, count.index)}"
  route_table_id = "${element(coalescelist(aws_route_table.database.*.id, aws_route_table.private.*.id), (var.single_nat_gateway || var.create_database_subnet_route_table ? 0 : count.index))}"
}

resource "aws_route_table_association" "redshift" {
  count = "${var.create_vpc && length(var.redshift_subnets) > 0 ? length(var.redshift_subnets) : 0}"

  subnet_id      = "${element(aws_subnet.redshift.*.id, count.index)}"
  route_table_id = "${element(coalescelist(aws_route_table.redshift.*.id, aws_route_table.private.*.id), (var.single_nat_gateway || var.create_redshift_subnet_route_table ? 0 : count.index))}"
}

resource "aws_route_table_association" "elasticache" {
  count = "${var.create_vpc && length(var.elasticache_subnets) > 0 ? length(var.elasticache_subnets) : 0}"

  subnet_id      = "${element(aws_subnet.elasticache.*.id, count.index)}"
  route_table_id = "${element(coalescelist(aws_route_table.elasticache.*.id, aws_route_table.private.*.id), (var.single_nat_gateway || var.create_elasticache_subnet_route_table ? 0 : count.index))}"
}

resource "aws_route_table_association" "intra" {
  count = "${var.create_vpc && length(var.intra_subnets) > 0 ? length(var.intra_subnets) : 0}"

  subnet_id      = "${element(aws_subnet.intra.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.intra.*.id, 0)}"
}

resource "aws_route_table_association" "public" {
  count = "${var.create_vpc && length(var.public_subnets) > 0 ? length(var.public_subnets) : 0}"

  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}

##############
# VPN Gateway
##############
resource "aws_vpn_gateway" "this" {
  count = "${var.create_vpc && var.enable_vpn_gateway ? 1 : 0}"

  vpc_id          = "${local.vpc_id}"
  amazon_side_asn = "${var.amazon_side_asn}"

  tags = "${merge(map("Name", format("%s", var.name)), var.tags, var.common_tags, var.region_tags, var.local_tags, var.vpn_gateway_tags)}"
}

resource "aws_vpn_gateway_attachment" "this" {
  count = "${var.vpn_gateway_id != "" ? 1 : 0}"

  vpc_id         = "${local.vpc_id}"
  vpn_gateway_id = "${var.vpn_gateway_id}"
}

resource "aws_vpn_gateway_route_propagation" "public" {
  count = "${var.create_vpc && var.propagate_public_route_tables_vgw && (var.enable_vpn_gateway || var.vpn_gateway_id != "") ? 1 : 0}"

  route_table_id = "${element(aws_route_table.public.*.id, count.index)}"
  vpn_gateway_id = "${element(concat(aws_vpn_gateway.this.*.id, aws_vpn_gateway_attachment.this.*.vpn_gateway_id), count.index)}"
}

resource "aws_vpn_gateway_route_propagation" "private" {
  count = "${var.create_vpc && var.propagate_private_route_tables_vgw && (var.enable_vpn_gateway || var.vpn_gateway_id != "") ? length(var.private_subnets) : 0}"

  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
  vpn_gateway_id = "${element(concat(aws_vpn_gateway.this.*.id, aws_vpn_gateway_attachment.this.*.vpn_gateway_id), count.index)}"
}

###########
# Defaults
###########
resource "aws_default_vpc" "this" {
  count = "${var.manage_default_vpc ? 1 : 0}"

  enable_dns_support   = "${var.default_vpc_enable_dns_support}"
  enable_dns_hostnames = "${var.default_vpc_enable_dns_hostnames}"
  enable_classiclink   = "${var.default_vpc_enable_classiclink}"

  tags = "${merge(map("Name", format("%s", var.default_vpc_name)), var.tags, var.common_tags, var.region_tags, var.local_tags, var.default_vpc_tags)}"
}



output "vpc_id" {
  description = "The ID of the VPC"
  value       = "${element(concat(aws_vpc.this.*.id, list("")), 0)}"
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = "${element(concat(aws_vpc.this.*.cidr_block, list("")), 0)}"
}

output "default_security_group_id" {
  description = "The ID of the security group created by default on VPC creation"
  value       = "${element(concat(aws_vpc.this.*.default_security_group_id, list("")), 0)}"
}

output "default_network_acl_id" {
  description = "The ID of the default network ACL"
  value       = "${element(concat(aws_vpc.this.*.default_network_acl_id, list("")), 0)}"
}

output "default_route_table_id" {
  description = "The ID of the default route table"
  value       = "${element(concat(aws_vpc.this.*.default_route_table_id, list("")), 0)}"
}

output "vpc_instance_tenancy" {
  description = "Tenancy of instances spin up within VPC"
  value       = "${element(concat(aws_vpc.this.*.instance_tenancy, list("")), 0)}"
}

output "vpc_enable_dns_support" {
  description = "Whether or not the VPC has DNS support"
  value       = "${element(concat(aws_vpc.this.*.enable_dns_support, list("")), 0)}"
}

output "vpc_enable_dns_hostnames" {
  description = "Whether or not the VPC has DNS hostname support"
  value       = "${element(concat(aws_vpc.this.*.enable_dns_hostnames, list("")), 0)}"
}

//output "vpc_enable_classiclink" {
//  description = "Whether or not the VPC has Classiclink enabled"
//  value       = "${element(concat(aws_vpc.this.*.enable_classiclink, list("")), 0)}"
//}

output "vpc_main_route_table_id" {
  description = "The ID of the main route table associated with this VPC"
  value       = "${element(concat(aws_vpc.this.*.main_route_table_id, list("")), 0)}"
}

//output "vpc_ipv6_association_id" {
//  description = "The association ID for the IPv6 CIDR block"
//  value       = "${element(concat(aws_vpc.this.*.ipv6_association_id, list("")), 0)}"
//}
//
//output "vpc_ipv6_cidr_block" {
//  description = "The IPv6 CIDR block"
//  value       = "${element(concat(aws_vpc.this.*.ipv6_cidr_block, list("")), 0)}"
//}

output "vpc_secondary_cidr_blocks" {
  description = "List of secondary CIDR blocks of the VPC"
  value       = ["${aws_vpc_ipv4_cidr_block_association.this.*.cidr_block}"]
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = ["${aws_subnet.private.*.id}"]
}

output "private_subnets_cidr_blocks" {
  description = "List of cidr_blocks of private subnets"
  value       = ["${aws_subnet.private.*.cidr_block}"]
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = ["${aws_subnet.public.*.id}"]
}

output "public_subnets_cidr_blocks" {
  description = "List of cidr_blocks of public subnets"
  value       = ["${aws_subnet.public.*.cidr_block}"]
}

output "database_subnets" {
  description = "List of IDs of database subnets"
  value       = ["${aws_subnet.database.*.id}"]
}

output "database_subnets_cidr_blocks" {
  description = "List of cidr_blocks of database subnets"
  value       = ["${aws_subnet.database.*.cidr_block}"]
}

output "database_subnet_group" {
  description = "ID of database subnet group"
  value       = "${element(concat(aws_db_subnet_group.database.*.id, list("")), 0)}"
}

output "redshift_subnets" {
  description = "List of IDs of redshift subnets"
  value       = ["${aws_subnet.redshift.*.id}"]
}

output "redshift_subnets_cidr_blocks" {
  description = "List of cidr_blocks of redshift subnets"
  value       = ["${aws_subnet.redshift.*.cidr_block}"]
}

output "redshift_subnet_group" {
  description = "ID of redshift subnet group"
  value       = "${element(concat(aws_redshift_subnet_group.redshift.*.id, list("")), 0)}"
}

output "elasticache_subnets" {
  description = "List of IDs of elasticache subnets"
  value       = ["${aws_subnet.elasticache.*.id}"]
}

output "elasticache_subnets_cidr_blocks" {
  description = "List of cidr_blocks of elasticache subnets"
  value       = ["${aws_subnet.elasticache.*.cidr_block}"]
}

output "intra_subnets" {
  description = "List of IDs of intra subnets"
  value       = ["${aws_subnet.intra.*.id}"]
}

output "intra_subnets_cidr_blocks" {
  description = "List of cidr_blocks of intra subnets"
  value       = ["${aws_subnet.intra.*.cidr_block}"]
}

output "elasticache_subnet_group" {
  description = "ID of elasticache subnet group"
  value       = "${element(concat(aws_elasticache_subnet_group.elasticache.*.id, list("")), 0)}"
}

output "elasticache_subnet_group_name" {
  description = "Name of elasticache subnet group"
  value       = "${element(concat(aws_elasticache_subnet_group.elasticache.*.name, list("")), 0)}"
}

output "public_route_table_ids" {
  description = "List of IDs of public route tables"
  value       = ["${aws_route_table.public.*.id}"]
}

output "private_route_table_ids" {
  description = "List of IDs of private route tables"
  value       = ["${aws_route_table.private.*.id}"]
}

output "database_route_table_ids" {
  description = "List of IDs of database route tables"
  value       = ["${coalescelist(aws_route_table.database.*.id, aws_route_table.private.*.id)}"]
}

output "redshift_route_table_ids" {
  description = "List of IDs of redshift route tables"
  value       = ["${coalescelist(aws_route_table.redshift.*.id, aws_route_table.private.*.id)}"]
}

output "elasticache_route_table_ids" {
  description = "List of IDs of elasticache route tables"
  value       = ["${coalescelist(aws_route_table.elasticache.*.id, aws_route_table.private.*.id)}"]
}

output "intra_route_table_ids" {
  description = "List of IDs of intra route tables"
  value       = ["${aws_route_table.intra.*.id}"]
}

output "nat_ids" {
  description = "List of allocation ID of Elastic IPs created for AWS NAT Gateway"
  value       = ["${aws_eip.nat.*.id}"]
}

output "nat_public_ips" {
  description = "List of public Elastic IPs created for AWS NAT Gateway"
  value       = ["${aws_eip.nat.*.public_ip}"]
}

output "natgw_ids" {
  description = "List of NAT Gateway IDs"
  value       = ["${aws_nat_gateway.this.*.id}"]
}

output "igw_id" {
  description = "The ID of the Internet Gateway"
  value       = "${element(concat(aws_internet_gateway.this.*.id, list("")), 0)}"
}

output "vpc_endpoint_s3_id" {
  description = "The ID of VPC endpoint for S3"
  value       = "${element(concat(aws_vpc_endpoint.s3.*.id, list("")), 0)}"
}

output "vpc_endpoint_s3_pl_id" {
  description = "The prefix list for the S3 VPC endpoint."
  value       = "${element(concat(aws_vpc_endpoint.s3.*.prefix_list_id, list("")), 0)}"
}

output "vpc_endpoint_dynamodb_id" {
  description = "The ID of VPC endpoint for DynamoDB"
  value       = "${element(concat(aws_vpc_endpoint.dynamodb.*.id, list("")), 0)}"
}

output "vgw_id" {
  description = "The ID of the VPN Gateway"
  value       = "${element(concat(aws_vpn_gateway.this.*.id, aws_vpn_gateway_attachment.this.*.vpn_gateway_id, list("")), 0)}"
}

output "vpc_endpoint_dynamodb_pl_id" {
  description = "The prefix list for the DynamoDB VPC endpoint."
  value       = "${element(concat(aws_vpc_endpoint.dynamodb.*.prefix_list_id, list("")), 0)}"
}

output "default_vpc_id" {
  description = "The ID of the VPC"
  value       = "${element(concat(aws_default_vpc.this.*.id, list("")), 0)}"
}

output "default_vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = "${element(concat(aws_default_vpc.this.*.cidr_block, list("")), 0)}"
}

output "default_vpc_default_security_group_id" {
  description = "The ID of the security group created by default on VPC creation"
  value       = "${element(concat(aws_default_vpc.this.*.default_security_group_id, list("")), 0)}"
}

output "default_vpc_default_network_acl_id" {
  description = "The ID of the default network ACL"
  value       = "${element(concat(aws_default_vpc.this.*.default_network_acl_id, list("")), 0)}"
}

output "default_vpc_default_route_table_id" {
  description = "The ID of the default route table"
  value       = "${element(concat(aws_default_vpc.this.*.default_route_table_id, list("")), 0)}"
}

output "default_vpc_instance_tenancy" {
  description = "Tenancy of instances spin up within VPC"
  value       = "${element(concat(aws_default_vpc.this.*.instance_tenancy, list("")), 0)}"
}

output "default_vpc_enable_dns_support" {
  description = "Whether or not the VPC has DNS support"
  value       = "${element(concat(aws_default_vpc.this.*.enable_dns_support, list("")), 0)}"
}

output "default_vpc_enable_dns_hostnames" {
  description = "Whether or not the VPC has DNS hostname support"
  value       = "${element(concat(aws_default_vpc.this.*.enable_dns_hostnames, list("")), 0)}"
}

//output "default_vpc_enable_classiclink" {
//  description = "Whether or not the VPC has Classiclink enabled"
//  value       = "${element(concat(aws_default_vpc.this.*.enable_classiclink, list("")), 0)}"
//}

output "default_vpc_main_route_table_id" {
  description = "The ID of the main route table associated with this VPC"
  value       = "${element(concat(aws_default_vpc.this.*.main_route_table_id, list("")), 0)}"
}

//output "default_vpc_ipv6_association_id" {
//  description = "The association ID for the IPv6 CIDR block"
//  value       = "${element(concat(aws_default_vpc.this.*.ipv6_association_id, list("")), 0)}"
//}
//
//output "default_vpc_ipv6_cidr_block" {
//  description = "The IPv6 CIDR block"
//  value       = "${element(concat(aws_default_vpc.this.*.ipv6_cidr_block, list("")), 0)}"
//}