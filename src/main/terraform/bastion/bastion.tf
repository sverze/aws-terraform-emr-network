# Specify the provider and access details
provider "aws" {
  region                       = "${var.aws_region}"
  profile                      = "${var.aws_profile}"
}

#data "aws_iam_policy_document" "bastion_assume_role_policy" {
#  statement {
#    actions = ["sts:AssumeRole"]
#
#    principals {
#      type        = "Service"
#      identifiers = ["ec2.amazonaws.com"]
#    }
#  }
#}

#resource "aws_iam_role" "bastion_iam_role" {
#  name               = "bastion_iam_role"
#  path               = "/system/"
#  assume_role_policy = "${data.aws_iam_policy_document.bastion_assume_role_policy.json}"
#}

resource "aws_instance" "bastion_instance" {
  instance_type                = "${var.aws_instance_type}"
#  iam_instance_profile         = "${aws_iam_role.bastion_iam_role.name}"
  ami                          = "${var.aws_ami}"
  key_name                     = "${var.aws_key_name}"
  vpc_security_group_ids       = ["${var.aws_security_group_id}"]
  subnet_id                    = "${var.aws_subnet_id}"
  associate_public_ip_address  = true

  tags {
    Name                       = "${var.environment_name}_bastion"
  }
}
