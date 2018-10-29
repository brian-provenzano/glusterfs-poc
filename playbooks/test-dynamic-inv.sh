#!/bin/bash
#
# Just a quick test script to test functionality of the dyn inv script for ansible
#
# Info / details on options below can be found in ec2.py
#
# Make certain you have AWS CLI setup with a profle/credentials :
# https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html
#
export EC2_INSTANCE_FILTERS='tag:Name=GlusterFS-*'
export EC2_INI_PATH=ec2.ini
echo $EC2_INSTANCE_FILTERS
echo $EC2_INI_PATH
echo "----------------"
python ec2.py --profile default --refresh-cache