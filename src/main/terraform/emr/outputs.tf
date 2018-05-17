
output "emr_cluster_master_public_dns" {
  value = "${aws_emr_cluster.emr_cluster.master_public_dns}"
}

output "emr_test_instance" {
  value = "${aws_instance.emr_test_instance.id}"
}

output "service_name" {
  value = "${aws_vpc_endpoint_service.emr_vpc_endpoint_service.service_name}"
}
