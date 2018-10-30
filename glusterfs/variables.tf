#environment|testing
# !!! leave line above as is - do not delete (used in our tfwrapper) !!!

variable "nodecount" {
  description = "The number of nodes to create in the gluster cluster"
  default = 3
}

# ---------------------
# Networking : VPCs,etc
# ---------------------
variable "vpc_name" {
  description = "The name of the VPC"
  default = "mainvpc"
}
variable "vpc_cidr" {
  description = "The CIDR range for the VPC"
  default = "10.100.0.0/16"
}
variable "publicsubnet_one_cidr" {
  description = "The CIDR of public subnet one"
  default = "10.100.1.0/24"
}
variable "publicsubnet_two_cidr" {
  description = "The CIDR of public subnet two"
  default = "10.100.2.0/24"
}

# ----------------------------
# REGIONS, Keys etc
# Change below to suit your needs
# ----------------------------

# aws region 
variable "region" {
  description = "uswest2 region"
  default = "us-west-2"
}

#AWS AZs for region
variable "azs" {
  type = "list"
  description = "uswest2 availability zones"
  default = ["us-west-2a","us-west-2b"]
}

# AWS Keys/ access - pass these in as -var on terraform cli
# Example:  terraform plan -var 'aws_keyname=mykeyname' -var 'aws_keyfile=/home/myuser/keys/mykeyfile.pem' -var 'aws_profilename=default'
variable "aws_keyname" {}
variable "aws_keyfile" {}
variable "aws_profilename" {}


# ---------------------
# Misc
# ---------------------
variable "environment" {
  description = "Name of environment (testing, development, production, etc)"
  default = "glustercluster"
}

# templates for instances / launch configs
data "template_file" "glusterfsnode_userdata" {
  template = "${file("../global/files/bootstraps/config-basic.sh")}"
  vars {
    # normally this is done by changing AMI (new AMI built with new code), 
    # but cheating here for demo purpose since changes to userdata force it as well
    force_redeploy = "touchme-to-v1" #just increment 1->2 to force a redeploy of instances etc.
  }
}

#---Canned AMIs
# Use get-currentamis.py to populate the below.

# Ubuntu 18.04 LTS
variable "ubuntu1804_amis" {
  type = "map"
  default = {
    us-west-1 = "ami-03d5270fcb641f79b"
    us-west-2 = "ami-0f47ef92b4218ec09"
  }
}

# Ubuntu 16.04 LTS
variable "ubuntu1604_amis" {
  type = "map"
  default = {
    us-west-1 = "ami-0d246a5d0c8b685ea"
    us-west-2 = "ami-01e0cf6e025c036e4"
  }
}

# Amazon Linux
variable "amlinux2_amis" {
  default = {
    type = "map"
    us-west-1 = "ami-04534c96466647bfb"
    us-west-2 = "ami-0d1000aff9a9bad89"
  }
}