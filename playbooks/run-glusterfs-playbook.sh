#!/bin/bash
#
# FUNCTION: Run Ansible gluster-cluster playbook
# DESC: Runs ansible playbook and ensures the ec2p.py script  + jq json obj creation is run to grab the current instance priv IPs
#

#check for args then release the hounds...
if [[ $# -eq 0 ]] ; then
    echo "You must provide the full path to your aws keyfile (.pem)"
    exit 1
fi

#1 - Run ansible to provision the instances
echo "[**] Provision glusterfs cluster using ansible playbook gluster-cluster.yml ..."
PRIVATEIPS="$(./ec2.py --profile default --list --refresh-cache | jq '._meta | {"private_ips":[.hostvars[].ec2_private_ip_address]}')" && \
echo "[1] -> Our inventory JSON to pass to ansible: ${PRIVATEIPS}" && \
echo "[2] -> Run gluster-cluster playbook..." && \
ansible-playbook -b -e 'ansible_python_interpreter=/usr/bin/python3' --private-key ${1} --extra-vars "${PRIVATEIPS}" gluster-cluster.yml