# GlusterFS Cluster POC

The goal of this exercise was to create a multi-node [GlusterFS](https://docs.gluster.org/en/latest/) storage cluster with sufficient fault tolerance to survive a single node failure with no loss of data.

This was done by first deploying several AWS instances using [Terraform](https://www.terraform.io/), then using the local-exec terraform provisioner for configuration of those instances via Ansible roles.  Ansible [dynamic inventory](https://docs.ansible.com/ansible/latest/user_guide/intro_dynamic_inventory.html#example-aws-ec2-external-inventory-script) was used to populate the inventory due to the use of AWS instances.

Ansible roles consisted of three roles:
- `ufw` : handle configuration of a local firewall
- `glusterfs` :  package installation and service enablement.
- `common` : initial setup, update pkg cache etc

The playbook `gluster-cluster.yml` used to configure the cluster is based on the [Gluster_Volume](http://docs.ansible.com/ansible/latest/modules/gluster_volume_module.html) module.


## Getting Started

Clone this repo to your workstation

## Prerequisites

- [AWS Account](https://aws.amazon.com/free/?nc2=h_ql_pr) - free tier can be utilized
- [AWS Credentials](https://docs.aws.amazon.com/sdk-for-java/v1/developer-guide/signup-create-iam-user.html) - setup configuration locally with a 'default' profile.  Ensure your IAM user has the correct permissions (EC2FullAccess should be enough)
- [Ansible](https://www.ansible.com)  - install locally (tested with version 2.7)
- [Terraform](https://www.terraform.io/) -  install locally (tested with version 0.11.10)
    - You can use my [hashicorp-get](https://github.com/brian-provenzano/hashicorp-get) script to assist in installing terraform (as well as a few other hashicorp tools)
- [jq](https://stedolan.github.io/jq/) - JSON parser used to parse and create custom json objects for ansible to consume to handle dyn inventory


NOTE: All builds/tests were performed on Fedora 28, but should function on Linux/Mac systems  - YMMV

## Initial Setup    

After installing, configuring the prerequisites and cloning the repo, simply change directory into `glusterfs` to begin.

Run `terraform init` to config terraform and pull the necessary plugins.  We will default to using a local terraform state file in this project to keep things simple.

To hit the ground running you can run `terraform apply` as shown below to begin provisioning.  For the cautious people out there, you can instead run `terraform apply` without the option '-auto-approve' first, inspect what terraform is going to do then type 'yes' to proceed.

NOTE: If you are ok with exceeding free tier you can use a larger instance to speed the provisioning up.  Just set the following variable on the terraform command line to override the default t2.micro.  For example, in my testing I found that the following will drastically reduce the provisioning time:

`-var 'gluster_instancetype=t3.medium'`


`terraform apply -auto-approve -var 'aws_keyname=<your-awskeyname>' -var 'aws_keyfile=<path-to-your-aws-keyfile-pem>' -var 'aws_profilename=<aws-profilename>'`


For example - assuming use of the 'default' AWS profile:

`terraform apply -auto-approve -var 'aws_keyname=myawskey' -var 'aws_keyfile=/home/testuser/keys/myawskey.pem' -var 'aws_profilename=default'`



This might take several minutes to complete, but you should see the following immediately:

```
on-key.pem' -var 'aws_profilename=default'
aws_vpc.main: Refreshing state... (ID: vpc-0a0316bed61608eb5)
aws_route_table.public: Refreshing state... (ID: rtb-0f4c76436c224ef9b)
aws_security_group.ssh_only: Refreshing state... (ID: sg-00aaa7f1c76701620)
aws_subnet.public[0]: Refreshing state... (ID: subnet-015af2756e074bb2f)
aws_subnet.public[1]: Refreshing state... (ID: subnet-0a0ea21c564ffff87)
aws_internet_gateway.main_igw: Refreshing state... (ID: igw-081d5e220ee62e76b)
aws_route.main_internet_access: Refreshing state... (ID: r-rtb-0f4c76436c224ef9b1080289494)
aws_route_table_association.associate_pub[0]: Refreshing state... (ID: rtbassoc-0cbf102321651bb63)
aws_route_table_association.associate_pub[1]: Refreshing state... (ID: rtbassoc-0e0152323503f7e7e)
aws_instance.glusterfs[0]: Refreshing state... (ID: i-0cdfe5ef500fb28ff)
aws_instance.glusterfs[2]: Refreshing state... (ID: i-02a823e57c7a78a76)
aws_instance.glusterfs[1]: Refreshing state... (ID: i-0892df6ac14c2ddb1)
....

```

Upon SUCCESSFUL provisioning of the cluster, you should see something like the following results:

```
null_resource.run_ansible_provisioning_glustercluster (local-exec): PLAY RECAP *********************************************************************
null_resource.run_ansible_provisioning_glustercluster (local-exec): 34.221.167.201             : ok=22   changed=13   unreachable=0    failed=0
null_resource.run_ansible_provisioning_glustercluster (local-exec): 52.42.197.11               : ok=21   changed=12   unreachable=0    failed=0
null_resource.run_ansible_provisioning_glustercluster (local-exec): 54.68.0.152                : ok=21   changed=12   unreachable=0    failed=0

null_resource.run_ansible_provisioning_glustercluster: Creation complete after 10m2s (ID: 5330255383112739896)

Apply complete! Resources: 13 added, 0 changed, 0 destroyed.

Outputs:

glustercluster_privateips = [
    10.100.1.171,
    10.100.1.4,
    10.100.1.174
]
glustercluster_publicips = [
    34.221.167.201,
    54.68.0.152,
    52.42.197.11
]
```

### Tests / Demo Cluster functionality


NOTE: Run ALL of the following ansible commands from the `playbooks` directory!  Also, if you do not wish to omit the '--private-key' option, you can edit `ansible.cfg`  in the playbooks directory.  Just uncomment the 'privatekey' line and provide the path to your aws key pem file.


#### Test/check cluster:


Run test on all nodes (optionally you can use 'tag_GlusterNode_true' instead of 'all')


`ansible all -e 'ansible_python_interpreter=/usr/bin/python3' --private-key <path-to-your-aws-keyfile> -a "gluster peer status" -b`


You should see the following information returned:

```
54.68.0.152 | CHANGED | rc=0 >>
Number of Peers: 2

Hostname: 10.100.1.171
Uuid: 077bfcb0-e26b-4c8b-833d-8ba343b6b5f6
State: Peer in Cluster (Connected)

Hostname: 10.100.1.174
Uuid: 72821a69-d50d-4208-9d60-c15534af8816
State: Peer in Cluster (Connected)

52.42.197.11 | CHANGED | rc=0 >>
Number of Peers: 2

Hostname: 10.100.1.171
Uuid: 077bfcb0-e26b-4c8b-833d-8ba343b6b5f6
State: Peer in Cluster (Connected)

Hostname: 10.100.1.4
Uuid: 2dffd8ae-5d55-486a-8e94-0a046171c432
State: Peer in Cluster (Connected)

34.221.167.201 | CHANGED | rc=0 >>
Number of Peers: 2

Hostname: 10.100.1.174
Uuid: 72821a69-d50d-4208-9d60-c15534af8816
State: Peer in Cluster (Connected)

Hostname: 10.100.1.4
Uuid: 2dffd8ae-5d55-486a-8e94-0a046171c432
State: Peer in Cluster (Connected)


```

#### Data tests:

Note: The data for your GlusterFS resides in `/data/gluster` on each node in the cluster.


To test replication across the cluster, just ssh into any node and run the following: 

 `sudo touch /data/gluster/replicate-me.txt`
 
 To use Ansible to accomplish this on one node:  

 `ansible tag_Name_GlusterFS_1 -e 'ansible_python_interpreter=/usr/bin/python3' --private-key <path-to-your-aws-keyfile> -a "touch /data/gluster/replicate-me.txt" -b`




Now check that the data replicated to the other nodes:

`ansible all -e 'ansible_python_interpreter=/usr/bin/python3' --private-key <path-to-your-aws-keyfile> -a "ls /data/gluster" -b`

You should see the following that demonstrates that the  data replicated:

```
54.68.0.152 | CHANGED | rc=0 >>
replicate-me.txt

34.221.167.201 | CHANGED | rc=0 >>
replicate-me.txt

52.42.197.11 | CHANGED | rc=0 >>
replicate-me.txt

```




#### Test node failure and resilency:

 Destroying a node can be done by adding the following to the `terraform apply` command to tell terraform to remove one instance/node (we started with 3):

 `-var 'nodecount=2'`

For example (`-auto-approve` removed in this case so we can follow the plan):

`terraform apply -var 'nodecount=2' -var 'aws_keyname=myawskey' -var 'aws_keyfile=/home/testuser/keys/myawskey.pem' -var 'aws_profilename=default'`

You should see the following that confirms a node was destroyed by Terraform:

```
An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  - aws_instance.glusterfs[2]


Plan: 0 to add, 0 to change, 1 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

....

aws_instance.glusterfs[2]: Destroying... (ID: i-02d9bcb727a8d3920)
aws_instance.glusterfs.2: Still destroying... (ID: i-02d9bcb727a8d3920, 10s elapsed)
aws_instance.glusterfs.2: Still destroying... (ID: i-02d9bcb727a8d3920, 20s elapsed)
aws_instance.glusterfs.2: Still destroying... (ID: i-02d9bcb727a8d3920, 30s elapsed)
aws_instance.glusterfs[2]: Destruction complete after 31s

Apply complete! Resources: 0 added, 0 changed, 1 destroyed.

Outputs:

glustercluster_privateips = [
    10.100.1.171,
    10.100.1.4
]
glustercluster_publicips = [
    34.221.167.201,
    54.68.0.152
]
```


#### To view general Gluster volume info after killing off a node

Run the following to show volume info after killing the node:


 `ansible all -e 'ansible_python_interpreter=/usr/bin/python3' --private-key <path-to-your-aws-keyfile> -a "gluster volume info" -b`

```
54.68.0.152 | CHANGED | rc=0 >>
 
Volume Name: gluster
Type: Replicate
Volume ID: 7c672ad0-d14a-48a6-97a5-dd43480a2424
Status: Started
Snapshot Count: 0
Number of Bricks: 1 x 3 = 3
Transport-type: tcp
Bricks:
Brick1: 10.100.1.171:/srv/gluster/brick
Brick2: 10.100.1.174:/srv/gluster/brick
Brick3: 10.100.1.4:/srv/gluster/brick
Options Reconfigured:
transport.address-family: inet
nfs.disable: on
performance.client-io-threads: off

34.221.167.201 | CHANGED | rc=0 >>
 
Volume Name: gluster
Type: Replicate
Volume ID: 7c672ad0-d14a-48a6-97a5-dd43480a2424
Status: Started
Snapshot Count: 0
Number of Bricks: 1 x 3 = 3
Transport-type: tcp
Bricks:
Brick1: 10.100.1.171:/srv/gluster/brick
Brick2: 10.100.1.174:/srv/gluster/brick
Brick3: 10.100.1.4:/srv/gluster/brick
Options Reconfigured:
transport.address-family: inet
nfs.disable: on
performance.client-io-threads: off

```

#### To test for volume healing within a cluster


`ansible all -e 'ansible_python_interpreter=/usr/bin/python3' --private-key <path-to-your-aws-keyfile> -a "gluster volume heal gluster info" -b`

```
34.221.167.201 | CHANGED | rc=0 >>
Brick 10.100.1.171:/srv/gluster/brick
Status: Connected
Number of entries: 0

Brick 10.100.1.174:/srv/gluster/brick
Status: Transport endpoint is not connected
Number of entries: -

Brick 10.100.1.4:/srv/gluster/brick
Status: Connected
Number of entries: 0

54.68.0.152 | CHANGED | rc=0 >>
Brick 10.100.1.171:/srv/gluster/brick
Status: Connected
Number of entries: 0

Brick 10.100.1.174:/srv/gluster/brick
Status: Transport endpoint is not connected
Number of entries: -

Brick 10.100.1.4:/srv/gluster/brick
Status: Connected
Number of entries: 0

```

### Idempotency Test

Finally, if you'd like to test for idempotency, just re-run the Ansible playbook gluster-cluster.yml outside of Terraform as follows:

NOTE:  You may wish to run this before the "node destruction/resilency" test above so that all nodes are available.

I have provided a script in the `playbooks` directory to handle this since we need to ensure $PRIVATEIPS is set due to dyn inv usage.  The one argument for the script is the AWS keyfile for ansible to use.

Example:

`run-glusterfs-playbook.sh ~/keys/myawskey.pem`


## Cleanup

When you are done issue `terraform destroy` to remove all resources

Example:

`terraform destroy -var 'aws_keyname=myawskey' -var 'aws_keyfile=/home/testuser/keys/myawskey.pem' -var 'aws_profilename=default'`


## License

- [MIT License](https://docs.gluster.org/en/latest/)  (do whatever you want :))

