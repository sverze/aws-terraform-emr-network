# Specify the provider and access details
# provider "aws" {
#   region                       = "${var.aws_region}"
#   profile                      = "${var.aws_profile}"
# }

data "aws_iam_policy_document" "bastion_iam_policy_document" {
  statement {
    actions                    = ["sts:AssumeRole"]

    principals {
      type                     = "Service"
      identifiers              = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "bastion_iam_role" {
  name                         = "${var.environment_name}_bastion_instance_role"
  path                         = "/system/"
  assume_role_policy           = "${data.aws_iam_policy_document.bastion_iam_policy_document.json}"
}

resource "aws_iam_instance_profile" "bastion_iam_instance_profile" {
  name                         = "${var.environment_name}_bastion_iam_instance_profile"
  role                         = "${aws_iam_role.bastion_iam_role.name}"
}

resource "aws_instance" "bastion_instance" {
  instance_type                = "${var.aws_instance_type}"
  ami                          = "${var.aws_ami}"
  key_name                     = "${var.aws_key_name}"
  vpc_security_group_ids       = ["${var.aws_security_group_id}"]
  subnet_id                    = "${var.aws_subnet_id}"
  associate_public_ip_address  = true
  iam_instance_profile         = "${aws_iam_instance_profile.bastion_iam_instance_profile.name}"

  tags {
    Name                       = "${var.environment_name}_bastion"
  }
}

resource "aws_vpc_endpoint" "emr_vpc_endpoint" {
  vpc_id                       = "${var.aws_vpc_id}"
  vpc_endpoint_type            = "Interface"
  service_name                 = "${var.emr_service_name}"
  subnet_ids                   = ["${var.aws_subnet_id}"]
  security_group_ids           = ["${var.aws_security_group_id}"]
  private_dns_enabled          = false
}
