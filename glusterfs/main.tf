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

  #create 3 instances for the cluster
  count = 3

  connection={
      user="ubuntu"
      key_file="${var.key_file}"
    }

  ami = "${lookup(var.ubuntu1804_amis, var.region)}"
  instance_type = "t2.micro"
  key_name = "${var.aws_keyname}"
  user_data = "${data.template_file.glusterfsnode_userdata.rendered}"
  
  vpc_security_group_ids = ["${module.networking.ssh_security_group_id}"]
  subnet_id = "${module.networking.public_subnets[0]}"

  tags {
    Name = "GlusterFS-${count.index}"
    Terraform = "true"
    Environment = "${var.environment}"
    GlusterNode = "true"
  }
}