output "vpc_id" {
  value = "${aws_vpc.main.id}"
}

output "ssh_security_group_id" {
  value = "${aws_security_group.ssh_with_gluster.id}"
}

output "public_subnets" {
  value = ["${aws_subnet.public.*.id}"]
}

# output "bastion_elasticip_id" {
#   value = "${aws_eip.bastion.id}"
# }
output "bastion_elasticip_id" {
  value =  "${element(split(",", join(",", aws_eip.bastion.*.id)), 0)}"
}
# output "bastion_elasticip" {
#   value = "${aws_eip.bastion.public_ip}"
# }
output "bastion_elasticip" {
  value = "${element(split(",", join(",", aws_eip.bastion.*.public_ip)), 0)}"
}
output "private_subnets" {
  value = ["${aws_subnet.private.*.id}"]
}
output "database_subnets" {
  value = ["${aws_subnet.private_database.*.id}"]
}
# output "database_subnet_group_id" {
#   value = "${aws_db_subnet_group.database_group.id}"
# }
output "database_subnet_group_id" {
  value = "${element(split(",", join(",", aws_db_subnet_group.database_group.*.id)), 0)}"
}
# output "database_subnet_group_name" {
#   value = "${aws_db_subnet_group.database_group.name}"
# }
output "database_subnet_group_name" {
  value = "${element(split(",", join(",", aws_db_subnet_group.database_group.*.name)), 0)}"
}
###  Deprecated - remove this 
# output "public_subnetone_id" {
#   value = "${aws_subnet.main_publicsubnet_one.id}"
# }
# output "public_subnettwo_id" {
#   value = "${aws_subnet.main_publicsubnet_two.id}"
# }

# output "private_subnetone_id" {
#   value = "${aws_subnet.main_privatesubnet_one.id}"
# }
# output "private_subnettwo_id" {
#   value = "${aws_subnet.main_privatesubnet_two.id}"
# }

# output "rds_subnetgroupone_name" {
#   value = "${aws_db_subnet_group.main_dbsubnetgroup_one.name}"
# }

