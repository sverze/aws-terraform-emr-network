
output "emr_cluster_master_public_dns" {
  value = "${aws_emr_cluster.emr_cluster.master_public_dns}"
}

output "emr_test_instance" {
  value = "${aws_instance.emr_test_instance.id}"
}

output "service_name" {
  value = "${aws_vpc_endpoint_service.emr_vpc_endpoint_service.service_name}"
}
# 
# output "emr_cluster_master_instance_type" {
#   value = "${aws_emr_cluster.emr_cluster.instance_group.0.instance_role}"
# }
#
# output "emr_cluster_master_instance_id" {
#   value = "${aws_emr_cluster.emr_cluster.instance_group.*.instance_type}"
# }
