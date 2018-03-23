# Specify the provider and access details
provider "aws" {
  region                       = "${var.aws_region}"
  profile                      = "${var.aws_profile}"

}

# TODO - test service endpoint with HTTPD installed
# resource "aws_instance" "emr_instance" {
#   instance_type                = "${var.aws_instance_type}"
#   ami                          = "${var.aws_ami}"
#   key_name                     = "${var.aws_key_name}"
#   vpc_security_group_ids       = ["${var.aws_security_group_id}"]
#   subnet_id                    = "${var.aws_subnet_id}"
#   associate_public_ip_address  = false
#
#   tags {
#     Name                       = "${var.environment_name}_application"
#   }
# }

################  VPC Endpoint Services  ################


resource "aws_lb" "emr_lb" {
  internal                     = true
  subnets                      = ["${var.aws_subnet_id}"]
  load_balancer_type           = "network"
  enable_deletion_protection   = false

  tags {
    Name                       = "${var.environment_name}_emr_lb"
  }
}

resource "aws_lb_target_group" "emr_lb_target_group" {
  port                         = 80
  protocol                     = "TCP"
  target_type                  = "instance"
  vpc_id                       = "${var.aws_vpc_id}"

  stickiness {
    type                       = "lb_cookie"
    enabled                    = "false"
  }

  tags {
    Name                       = "${var.environment_name}_emr_lb_target_group"
  }
}

resource "aws_lb_listener" "emr_lb_listener" {
  load_balancer_arn            = "${aws_lb.emr_lb.arn}"
  port                         = "80"
  protocol                     = "TCP"

  default_action {
    target_group_arn           = "${aws_lb_target_group.emr_lb_target_group.arn}"
    type                       = "forward"
  }
}

# resource "aws_lb_target_group_attachment" "emr_lb_target_group_attachment" {
#   target_group_arn             = "${aws_lb_target_group.emr_lb_target_group.arn}"
#   target_id                    = "${aws_instance.test.id}"
#   port                         = 80
# }

resource "aws_vpc_endpoint_service" "emr_vpc_endpoint_service" {
  acceptance_required          = false
  network_load_balancer_arns   = ["${aws_lb.emr_lb.arn}"]
}
