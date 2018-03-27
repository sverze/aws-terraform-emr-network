
output "instance_id" {
  value = "${aws_instance.emr_instance.id}"
}

output "service_name" {
  value = "${aws_vpc_endpoint_service.emr_vpc_endpoint_service.service_name}"
}
