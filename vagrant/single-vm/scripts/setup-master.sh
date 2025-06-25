#!/bin/bash

# CP_NODE_IP="172.16.9.10"
W_NODE_1_IP="172.16.9.11"
VAGRANT_ROOT="/home/vagrant"
ANSIBLE_ROOT="$VAGRANT_ROOT/.ansible"
SHARED_FOLDER="$VAGRANT_ROOT/shared"

# Install Ansible
sudo apt update
sudo apt install -y ansible \
                    nano \
                    python3-pip

mkdir $ANSIBLE_ROOT
# Create a default inventory for worker node
touch $ANSIBLE_ROOT/inventory $VAGRANT_ROOT/.ansible.cfg
chown -R vagrant:vagrant $ANSIBLE_ROOT $VAGRANT_ROOT/.ansible.cfg

sudo tee /etc/hosts <<EOF
$W_NODE_1_IP worker worker
EOF

tee $VAGRANT_ROOT/.ansible.cfg <<EOF
[defaults]
inventory=$ANSIBLE_ROOT/inventory
EOF

tee $ANSIBLE_ROOT/inventory <<EOF
[default]
172.16.9.11

[ansible_hosts]
master=172.16.9.11
EOF

# Silently generate SSH key
ssh-keygen -q -t rsa -N '' <<< $'\ny' >/dev/null 2>&1
cp $VAGRANT_ROOT/.ssh/id_rsa.pub $SHARED_FOLDER/master_id_rsa.pub