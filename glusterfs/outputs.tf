
output "glustercluster_publicips" {
  value = ["${aws_instance.glusterfs.*.public_ip}"]
}

output "glustercluster_privateips" {
  value = ["${aws_instance.glusterfs.*.private_ip}"]
}