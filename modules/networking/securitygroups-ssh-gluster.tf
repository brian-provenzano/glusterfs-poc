# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE SSH / GLUSTER SECURITY GROUP
# ---------------------------------------------------------------------------------------------------------------------
# 1 - Security group for instance with SSH / glusterfs
resource "aws_security_group" "ssh_with_gluster" {
  name = "${var.environment}-sshonly"
  vpc_id = "${aws_vpc.main.id}"
  
  # Inbound SSH
  ingress {
    from_port = "${var.ssh_port}"
    to_port = "${var.ssh_port}"
    protocol = "tcp"
    cidr_blocks = ["${var.home_publicaddress}"]
  }

  # Inbound ICMP
  ingress {
    from_port = "${var.icmp_typenumber_ping}"
    to_port = "${var.icmp_code_ping}"
    protocol = "icmp"
    cidr_blocks = ["${var.home_publicaddress}"]
  }

  # allow all instances to communicate (for gluster)
  #TODO - create another SG for gluster ports only
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  # All out ALL explicitly b/c TF doesnt do this like AWS console does... ARGH!
  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }

  # aws_launch_configuration.launch_configuration in this module sets create_before_destroy to true, which means
  # everything it depends on, including this resource, must set it as well, or you'll get cyclic dependency errors
  # when you try to do a terraform destroy.
  lifecycle {
    create_before_destroy = true
  }

  tags {
    Name = "${var.environment}-ssh-with-gluster"
    Terraform = "true"
    Environment = "${var.environment}"
  }

}