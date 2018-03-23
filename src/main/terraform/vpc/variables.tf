
variable "environment_name" {
    description = "The name of the environment"
}

variable "aws_region" {
  description = "AWS region to create the VPC and services"
}

variable "aws_profile" {
  description = "AWS profile to use other than the default"
  default     = "default"
}

variable "aws_key_name" {
  description = "AWS key name to use, it must exist in the specified region"
}

variable "aws_public_vpc_cidr" {
  description = "VPC CIDR block range for the public VPC"
}

variable "aws_private_vpc_cidr" {
  description = "VPC CIDR block range for the private VPC"
}

variable "aws_sn_1_cidr" {
  description = "Subnet availability zone A CIDR block range for NAT gateways"
}

variable "aws_sn_2_cidr" {
  description = "Subnet availability zone B CIDR block range for NAT gateways"
}

variable "bastion_network_cidr" {
  description = "Bastion network CIDR block range, refine default to makeaccess more secure"
}
