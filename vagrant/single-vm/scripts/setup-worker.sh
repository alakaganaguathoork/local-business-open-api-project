#!/bin/bash

CP_NODE_IP="172.16.9.10"
W_NODE_1_IP="172.16.9.11"
VAGRANT_ROOT="/home/vagrant"
SHARED_FOLDER="$VAGRANT_ROOT/shared"

sudo apt update
sudo apt install -y nano

sudo tee /etc/hosts <<EOF
$CP_NODE_IP master master
EOF

ssh-keygen -q -t rsa -N '' <<< $'\ny' >/dev/null 2>&1
cp $VAGRANT_ROOT/.ssh/id_rsa.pub $SHARED_FOLDER/worker_id_rsa.pub

cat $SHARED_FOLDER/master_id_rsa.pub >> $VAGRANT_ROOT/.ssh/authorized_keys 