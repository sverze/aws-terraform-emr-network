output "vpc_1_id" {
  value = "${aws_vpc.vpc_1.id}"
}

output "vpc_2_id" {
  value = "${aws_vpc.vpc_2.id}"
}

output "sn_1a_id" {
  value = "${aws_subnet.sn_1a.id}"
}

output "sn_1b_id" {
  value = "${aws_subnet.sn_1b.id}"
}

output "sn_2a_id" {
  value = "${aws_subnet.sn_2a.id}"
}

output "sn_2b_id" {
  value = "${aws_subnet.sn_2b.id}"
}

output "sg_1_id" {
  value = "${aws_security_group.sg_1.id}"
}

output "sg_2_id" {
  value = "${aws_security_group.sg_2.id}"
}

output "sg_3_id" {
  value = "${aws_security_group.sg_3.id}"
}
