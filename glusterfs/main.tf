# https://www.terraform.io/docs/configuration/terraform.html
terraform {
  required_version = "~> 0.9"
}

# ------------------------------------------------------------------------------
# CONFIGURE AWS CONNECTION (PROVIDER)
# ------------------------------------------------------------------------------
provider "aws" {
  version = "~> 1.9"
  region = "${var.region}"
  #shared_credentials_file = "${var.aws_keyfile}"
  profile = "${var.aws_profilename}"
}
provider "template" {
  version = "~> 1.0"
}

# ------------------------------------------------------------------------------
# IAM - POLICIES, ROLES, GROUPS, USERS, etc.
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# MODULES
# ------------------------------------------------------------------------------

# -- CREATE vpc, subnets, security groups, eips, network ACLs etc.
module "networking" {
  source = "../modules/networking"
  
  #inputs
  environment = "${var.environment}"
  vpc_name = "${var.vpc_name}"
  vpc_cidr = "${var.vpc_cidr}"
  publicsubnet_cidrs = ["${var.publicsubnet_one_cidr}","${var.publicsubnet_two_cidr}"]
  privatesubnet_cidrs = []
  availability_zones = ["${var.azs}"]
  database_privatesubnet_cidrs = []
  enable_natgateway = "false"
  enable_bastion = "false"
  
  tags { 
    # Name tag is handled internally
    "Terraform" = "true"
    "Role" = "networking"
    "Environment" = "${var.environment}"
  }
}

# -- CREATE glusterfs servers (3 total)

resource "aws_instance" "glusterfs" {

  #number of nodes for the cluster
  count = "${var.nodecount}"

  # connection={
  #     user="ubuntu"
  #     key_file="${var.aws_keyfile}"
  #   }

  ami = "${lookup(var.ubuntu1804_amis, var.region)}"
  instance_type = "t3.micro"
  key_name = "${var.aws_keyname}"
  #user_data = "${data.template_file.glusterfsnode_userdata.rendered}"
  
  vpc_security_group_ids = ["${module.networking.ssh_security_group_id}"]
  subnet_id = "${module.networking.public_subnets[0]}"

  tags {
    Name = "GlusterFS-${count.index}"
    Terraform = "true"
    Environment = "${var.environment}"
    GlusterNode = "true"
  }

  # Provision/configure the instances - have to sleep b/c we are using local-exec
  # This allows the instances to fully start up.
    provisioner "local-exec" {
        working_dir = "../playbooks/"
        command = "sleep 300; PRIVATEIPS=\"$(./ec2.py --profile default --list --refresh-cache | jq '._meta | {\"private_ips\":[.hostvars[].ec2_private_ip_address]}')\";ansible-playbook -b --private-key ${var.aws_keyfile} --limit ${self.public_ip} -e 'ansible_python_interpreter=/usr/bin/python3' --extra-vars 'ip=\"$${PRIVATEIPS}\"' gluster-cluster.yml"
    }
}