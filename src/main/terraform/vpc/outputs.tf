output "vpc_1_id" {
  value = "${aws_vpc.vpc_1.id}"
}

output "vpc_2_id" {
  value = "${aws_vpc.vpc_2.id}"
}

output "sn_1_id" {
  value = "${aws_subnet.sn_1.id}"
}

output "sn_2_id" {
  value = "${aws_subnet.sn_2.id}"
}

output "sg_1_id" {
  value = "${aws_security_group.sg_1.id}"
}

output "sg_2_id" {
  value = "${aws_security_group.sg_2.id}"
}
