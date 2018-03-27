# Specify the provider and access details
provider "aws" {
  region                       = "${var.aws_region}"
  profile                      = "${var.aws_profile}"
}

################        VPC        ################


# Public VPC required bastion
resource "aws_vpc" "vpc_1" {
  cidr_block                   = "${var.aws_public_vpc_cidr}"
  enable_dns_support           = "true"
  enable_dns_hostnames         = "true"

  tags {
    Name                       = "${var.environment_name}_vpc_1"
  }
}

# Private VPC to launch our test instances into
resource "aws_vpc" "vpc_2" {
  cidr_block                   = "${var.aws_private_vpc_cidr}"
  enable_dns_support           = true
  enable_dns_hostnames         = true

  tags {
    Name                       = "${var.environment_name}_vpc_2"
  }
}


################ Internet Gateway  ################


# TODO - Consider changing to egresss only gateway
# Internet Gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "ig_1" {
  vpc_id                       = "${aws_vpc.vpc_1.id}"

  tags {
    Name                       = "${var.environment_name}_ig_1"
  }
}


################   Route Tables    ################


# Route Table for Internet access & Bastion Instance
resource "aws_route_table" "rt_1" {
  vpc_id                       = "${aws_vpc.vpc_1.id}"

  route {
    cidr_block                 = "0.0.0.0/0"
    gateway_id                 = "${aws_internet_gateway.ig_1.id}"
  }

  tags {
    Name                       = "${var.environment_name}_rt_1"
  }
}

# Route Table for EMR Instance
resource "aws_route_table" "rt_2" {
  vpc_id                       = "${aws_vpc.vpc_2.id}"

  tags {
    Name                       = "${var.environment_name}_rt_2"
  }
}


################      Subnets      ################

# Subnet 1 in Availability Zone A for Bastion Host
resource "aws_subnet" "sn_1" {
  vpc_id                       = "${aws_vpc.vpc_1.id}"
  cidr_block                   = "${var.aws_sn_1_cidr}"
  availability_zone            = "${var.aws_region}a"
  map_public_ip_on_launch      = true

  tags {
    Name                       = "${var.environment_name}_sn_1"
  }
}

resource "aws_route_table_association" "rta_1" {
  subnet_id                    = "${aws_subnet.sn_1.id}"
  route_table_id               = "${aws_route_table.rt_1.id}"
}

# Subnet 2 in Availability Zone A for Application Test Hosts
resource "aws_subnet" "sn_2" {
  vpc_id                       = "${aws_vpc.vpc_2.id}"
  cidr_block                   = "${var.aws_sn_2_cidr}"
  availability_zone            = "${var.aws_region}a"
  map_public_ip_on_launch      = false

  tags {
    Name                       = "${var.environment_name}_sn_2"
  }
}

resource "aws_route_table_association" "rta_2" {
  subnet_id                    = "${aws_subnet.sn_2.id}"
  route_table_id               = "${aws_route_table.rt_2.id}"
}


################  Security Groups  ################


# Security Group for Bastion Hosts
resource "aws_security_group" "sg_1" {
  name                         = "${var.environment_name}_sg_1"
  vpc_id                       = "${aws_vpc.vpc_1.id}"

  # SSH access only from Bastion network
  ingress {
    description                = "${var.environment_name}_sg_1 SSH from Bastion CIDR"
    from_port                  = 22
    to_port                    = 22
    protocol                   = "tcp"
    cidr_blocks                = ["${var.bastion_network_cidr}"]
  }

  ingress {
    description                = "${var.environment_name}_sg_1 All within this SG"
    from_port                  = 0
    to_port                    = 0
    protocol                   = "-1"
    self                       = true
  }

  egress {
    description                = "${var.environment_name}_sg_1 All to Anywhere"
    from_port                  = 0
    to_port                    = 0
    protocol                   = "-1"
    cidr_blocks                = ["0.0.0.0/0"]
  }

  tags {
    Name                       = "${var.environment_name}_sg_1"
  }
}

# Security Group for Test Hosts
resource "aws_security_group" "sg_2" {
  name                         = "${var.environment_name}_sg_2"
  vpc_id                       = "${aws_vpc.vpc_2.id}"

  ingress {
    description                = "${var.environment_name}_sg_2 HTTP from Subnet"
    from_port                  = 80
    to_port                    = 80
    protocol                   = "tcp"
    cidr_blocks                = ["${var.aws_sn_2_cidr}"]
  }

  ingress {
    description                = "${var.environment_name}_sg_2 All within this SG"
    from_port                  = 0
    to_port                    = 0
    protocol                   = "-1"
    self                       = true
  }

  egress {
    description                = "${var.environment_name}_sg_2 All to Anywhere"
    from_port                  = 0
    to_port                    = 0
    protocol                   = "-1"
    cidr_blocks                = ["0.0.0.0/0"]
  }

  tags {
    Name                       = "${var.environment_name}_sg_2"
  }
}


################  VPC Endpoints  ################


resource "aws_vpc_endpoint" "kinesis_streams" {
  vpc_id                       = "${aws_vpc.vpc_2.id}"
  service_name                 = "com.amazonaws.${var.aws_region}.kinesis-streams"
  vpc_endpoint_type            = "Interface"
  subnet_ids                   = ["${aws_subnet.sn_2.id}"]
  security_group_ids           = ["${aws_security_group.sg_2.id}"]
  private_dns_enabled          = true
}

resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id                       = "${aws_vpc.vpc_2.id}"
  service_name                 = "com.amazonaws.${var.aws_region}.dynamodb"
  route_table_ids              = ["${aws_route_table.rt_2.id}"]
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id                       = "${aws_vpc.vpc_2.id}"
  service_name                 = "com.amazonaws.${var.aws_region}.s3"
  route_table_ids              = ["${aws_route_table.rt_2.id}"]
}
