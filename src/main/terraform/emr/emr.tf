# Specify the provider and access details
provider "aws" {
  region                              = "${var.aws_region}"
  profile                             = "${var.aws_profile}"
}


################  EMR Roles & Policies ################


data "template_file" "user_data" {
  template                            = "${file("${path.module}/user-data.sh")}"
}

resource "aws_iam_role" "emr_iam_role" {
  name                                = "emr_iam_role"

  assume_role_policy                  =
<<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "elasticmapreduce.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}
resource "aws_iam_instance_profile" "emr_iam_instance_profile" {
  name                                = "emr_iam_instance_profile"
  role                                = "${aws_iam_role.emr_iam_role.name}"
}

resource "aws_iam_role_policy" "iam_emr_service_policy" {
  name                                = "iam_emr_service_policy"
  role                                = "${aws_iam_role.emr_iam_role.id}"

  policy                              = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [{
        "Effect": "Allow",
        "Resource": "*",
        "Action": [
            "ec2:*",
            "iam:GetRole",
            "iam:GetRolePolicy",
            "iam:ListInstanceProfiles",
            "iam:ListRolePolicies",
            "iam:PassRole",
            "s3:CreateBucket",
            "s3:Get*",
            "s3:List*",
            "sdb:BatchPutAttributes",
            "sdb:Select",
            "sqs:CreateQueue",
            "sqs:*"
        ]
    }]
}
EOF
}

################  EMR Spark Cluster  ################


resource "aws_emr_cluster" "emr_cluster" {
  name                                = "${var.environment_name}_cluster"
  release_label                       = "emr-4.6.0"
  applications                        = ["Spark"]
  termination_protection              = false
  keep_job_flow_alive_when_no_steps   = true

  ec2_attributes {
    subnet_id                         = "${var.aws_subnet_id}"
    service_access_security_group     = "${var.aws_service_security_group_id}"
    emr_managed_master_security_group = "${var.aws_private_security_group_id}"
    emr_managed_slave_security_group  = "${var.aws_private_security_group_id}"
    instance_profile                  = "${aws_iam_instance_profile.emr_iam_instance_profile.arn}"
  }

  master_instance_type                = "m3.xlarge"
  core_instance_type                  = "m3.xlarge"
  core_instance_count                 = 1

  tags {
    role                              = "${aws_iam_role.emr_iam_role.name}"
    env                               = "${var.environment_name}"
    name                              = "${var.environment_name}_cluster"
  }

  # bootstrap_action {
  #   path = "s3://elasticmapreduce/bootstrap-actions/run-if"
  #   name = "runif"
  #   args = ["instance.isMaster=true", "echo running on master node"]
  # }
  #
  # configurations = "test-fixtures/emr_configurations.json"

  service_role                       = "${aws_iam_role.emr_iam_role.arn}"
}


################  Test Instance  ################


resource "aws_instance" "emr_test_instance" {
  instance_type                       = "${var.aws_instance_type}"
  ami                                 = "${var.aws_ami}"
  key_name                            = "${var.aws_key_name}"
  vpc_security_group_ids              = ["${var.aws_service_security_group_id}"]
  subnet_id                           = "${var.aws_subnet_id}"
  associate_public_ip_address         = false
  iam_instance_profile                = "${aws_iam_instance_profile.emr_iam_instance_profile.name}"
  user_data                           = "${data.template_file.user_data.rendered}"

  tags {
    Name                              = "${var.environment_name}_application"
  }
}


################  VPC Endpoint Services  ################

## Service Endpoint Facets

resource "aws_vpc_endpoint_service" "emr_vpc_endpoint_service" {
  acceptance_required                 = false
  network_load_balancer_arns          = ["${aws_lb.emr_lb.arn}"]
}

resource "aws_lb" "emr_lb" {
  internal                            = true
  subnets                             = ["${var.aws_subnet_id}"]
  load_balancer_type                  = "network"
  enable_deletion_protection          = false

  tags {
    Name                              = "${var.environment_name}_emr_lb"
  }
}

## EMR HDFS Access (HTTP/50070)

# resource "aws_lb_target_group" "emr_hdfs_lb_target_group" {
#   port                                = 50070
#   protocol                            = "TCP"
#   target_type                         = "instance"
#   vpc_id                              = "${var.aws_vpc_id}"
#
#   health_check {
#     protocol                          = "HTTP"
#     path                              = "/"
#     port                              = 50070
#     healthy_threshold                 = 3
#     unhealthy_threshold               = 3
#     interval                          = 30
#   }
#
#   stickiness {
#     type                              = "lb_cookie"
#     enabled                           = "false"
#   }
#
#   tags {
#     Name                              = "${var.environment_name}_emr_hdfs_lb_target_group"
#   }
# }
#
# resource "aws_lb_listener" "emr_hdfs_lb_listener" {
#   load_balancer_arn                   = "${aws_lb.emr_lb.arn}"
#   port                                = 50070
#   protocol                            = "TCP"
#
#   default_action {
#     target_group_arn                  = "${aws_lb_target_group.emr_hdfs_lb_target_group.arn}"
#     type                              = "forward"
#   }
# }
#
# resource "aws_lb_target_group_attachment" "emr_hdfs_lb_target_group_attachment" {
#   target_group_arn                    = "${aws_lb_target_group.emr_hdfs_lb_target_group.arn}"
#   target_id                           = "${aws_emr_cluster.emr_cluster.master_public_dns}"
#   port                                = 50070
# }

## EMR Test Instance Access (HTTP/80)

resource "aws_lb_target_group" "emr_test_lb_target_group" {
  port                                = 80
  protocol                            = "TCP"
  target_type                         = "instance"
  vpc_id                              = "${var.aws_vpc_id}"

  health_check {
    protocol                          = "HTTP"
    path                              = "/"
    port                              = 80
    healthy_threshold                 = 3
    unhealthy_threshold               = 3
    interval                          = 30
  }

  stickiness {
    type                              = "lb_cookie"
    enabled                           = "false"
  }

  tags {
    Name                              = "${var.environment_name}_emr_test_lb_target_group"
  }
}

resource "aws_lb_listener" "emr_test_lb_listener" {
  load_balancer_arn                   = "${aws_lb.emr_lb.arn}"
  port                                = 80
  protocol                            = "TCP"

  default_action {
    target_group_arn                  = "${aws_lb_target_group.emr_test_lb_target_group.arn}"
    type                              = "forward"
  }
}

resource "aws_lb_target_group_attachment" "emr_test_lb_target_group_attachment" {
  target_group_arn                    = "${aws_lb_target_group.emr_test_lb_target_group.arn}"
  target_id                           = "${aws_instance.emr_test_instance.id}"
  port                                = 80
}
