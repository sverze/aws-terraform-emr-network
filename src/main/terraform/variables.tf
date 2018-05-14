
variable "environment_name" {
  description = "The name of the environment"
  default     = "emr_dev"
}

variable "aws_region" {
  description = "AWS region to create the VPC and services"
  default     = "eu-west-1"
}

variable "aws_profile" {
  description = "AWS profile to use other during provisioning"
}

# NOTE: The key should be available via your SSH agent, use ssh-add to add this key
variable "aws_key_name" {
  description = "AWS key name to use, it must exist in the specified region"
}

variable "aws_public_vpc_cidr" {
  description = "VPC CIDR block range for the public VPC"
  default     = "10.1.0.0/16"
}

variable "aws_private_vpc_cidr" {
  description = "VPC CIDR block range for the private VPC"
  default     = "10.2.0.0/16"
}

variable "aws_sn_1_cidr" {
  description = "Subnet availability zone A CIDR block range for bastion instance"
  default     = "10.1.1.0/24"
}

variable "aws_sn_2_cidr" {
  description = "Subnet availability zone A CIDR block range for test instance"
  default     = "10.2.1.0/24"
}

variable "bastion_network_cidr" {
  description = "Bastion network CIDR block range, refine default to makeaccess more secure"
  default     = "0.0.0.0/0"
}

# Amazon Linux (x64)
variable "aws_amis" {
  type        = "map"
  default = {
    us-east-1 = "ami-8c1be5f6"
    us-east-2 = "ami-c5062ba0"
    eu-west-1 = "ami-23fbb85a"
    eu-west-2 = "ami-1a7f6d7e"
  }
}
