#!/usr/bin/python3
"""
get-currentamis.py
-----------------------
Simple script returns the current (latest) AMI for specified region (optional) and description (required); other options available 
-----------------------

Usage:
-----------------------
get-currentamis.py <ami-desc>
<ami-desc> = "linux_amazon, linux_amazon2, etc"

TODOs - future features?

"""

import boto3
import argparse

##########################################
#- Modify the options below as needed
##########################################

SUPPORTED_AMIS = "linux_amazon,linux_amazon2,linux_ubuntu1604,linux_ubuntu1804,linux_rhel75,windows_2016base"

##########################################
#- END - Do not modify below here!!!
##########################################

def main():

    parser = argparse.ArgumentParser(prog="get-currentamis.py", \
            description="Returns the current (latest) AMI imageid specfied")
    #-required
    parser.add_argument("ami_description", type=str, \
            help="Specify {0} Either as a single value or comma seperated list of values".format(SUPPORTED_AMIS))
    #-optional
    parser.add_argument("-r", "--region", \
            help="AWS region for AMI.  If not specified, will use AWS profile default")
    #-informational args
    # parser.add_argument("-d", "--debug", action="store_true",
    #         help="Debug mode - show more informational messages for debugging")
    parser.add_argument("-v", "--version", action="version", version="1.0")
    args = parser.parse_args()
    ami_description = args.ami_description.strip()

    try:
        description_list = ami_description.split(',')
        
        if len(description_list) == 0:
            raise ValueError("You must provide a single ami_description or a comma seperated list of ami_descriptions")

        notallowedlist = [x for x in description_list if x not in SUPPORTED_AMIS]
        if len(notallowedlist) != 0:
            raise ValueError("You specified one of more AMI descriptions that are not allowed [{0}]".format(''.join(notallowedlist)))

        if args.region:
            awsregion = args.region.strip()
            ec2 = boto3.client('ec2', region_name=awsregion)
        else:
            session = boto3.Session(profile_name='default')
            awsregion = session.region_name
            ec2 = session.client('ec2')

        print("\033[32m >> Using region {0} << \033[0m".format(awsregion))

        for description in description_list:
            
            if description == "linux_amazon":

                response = ec2.describe_images(
                    Owners=['amazon'], 
                    Filters=[
                    {'Name': 'name', 'Values': ['amzn-ami-hvm-*-x86_64-gp2']},
                    {'Name': 'architecture', 'Values': ['x86_64']},
                    {'Name': 'root-device-type', 'Values': ['ebs']},
                    {'Name': 'state', 'Values': ['available']},
                    ],
                )
                amis = sorted(response['Images'], key=lambda x: x['CreationDate'], reverse=True)
                ami = amis[0]['ImageId']
                description = amis[0]['Description']

            elif description == "linux_amazon2":

                response = ec2.describe_images(
                    Owners=['amazon'], 
                    Filters=[
                    {'Name': 'name', 'Values': ['amzn2-ami-hvm-2.0.*-x86_64-gp2']},
                    {'Name': 'architecture', 'Values': ['x86_64']},
                    {'Name': 'root-device-type', 'Values': ['ebs']},
                    {'Name': 'state', 'Values': ['available']},
                    ],
                )
                amis = sorted(response['Images'], key=lambda x: x['CreationDate'], reverse=True)
                ami = amis[0]['ImageId']
                description = amis[0]['Description']

            elif description == "linux_ubuntu1804":

                response = ec2.describe_images(
                    Filters=[
                    {'Name': 'name', 'Values': ['ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*']},
                    {'Name': 'architecture', 'Values': ['x86_64']},
                    {'Name': 'root-device-type', 'Values': ['ebs']},
                    {'Name': 'state', 'Values': ['available']},
                    ],
                )
                amis = sorted(response['Images'], key=lambda x: x['CreationDate'], reverse=True)
                ami = amis[0]['ImageId']
                description = amis[0]['Description']

            elif description == "linux_ubuntu1604":

                response = ec2.describe_images(
                    Filters=[
                    {'Name': 'name', 'Values': ['ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*']},
                    {'Name': 'architecture', 'Values': ['x86_64']},
                    {'Name': 'root-device-type', 'Values': ['ebs']},
                    {'Name': 'state', 'Values': ['available']},
                    ],
                )
                amis = sorted(response['Images'], key=lambda x: x['CreationDate'], reverse=True)
                ami = amis[0]['ImageId']
                description = amis[0]['Description']

            elif description == "windows_2016base":

                response = ec2.describe_images(
                    Owners=['amazon'], 
                    Filters=[
                    {'Name': 'name', 'Values': ['Windows_Server-2016-English-Full-Base*']},
                    {'Name': 'architecture', 'Values': ['x86_64']},
                    {'Name': 'root-device-type', 'Values': ['ebs']},
                    {'Name': 'state', 'Values': ['available']},
                    ],
                )
                amis = sorted(response['Images'], key=lambda x: x['CreationDate'], reverse=True)
                ami = amis[0]['ImageId']
                description = amis[0]['Description']

            elif description == "linux_rhel75":

                response = ec2.describe_images(
                    Owners=['309956199498'], 
                    Filters=[
                    {'Name': 'name', 'Values': ['RHEL-7.5_HVM_GA*']},
                    {'Name': 'architecture', 'Values': ['x86_64']},
                    {'Name': 'root-device-type', 'Values': ['ebs']},
                    {'Name': 'state', 'Values': ['available']},
                    ],
                )
                amis = sorted(response['Images'], key=lambda x: x['CreationDate'], reverse=True)
                ami = amis[0]['ImageId']
                description = amis[0]['Description']

            print("[ {0} ] - {1}".format(ami,description))

    except Exception as e:
        print("\033[31m >> ERROR: {0} << \033[0m".format(e))

if __name__ == '__main__':
    main()
