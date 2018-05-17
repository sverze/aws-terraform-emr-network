
output "instance_id" {
  value = "${aws_instance.bastion_instance.id}"
}

output "emr_endpoint_dns_entry" {
  value = "${aws_vpc_endpoint.emr_vpc_endpoint.dns_entry}"
}
