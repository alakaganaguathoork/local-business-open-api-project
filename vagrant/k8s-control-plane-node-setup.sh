#!/bin/bash

HOME="/home/vagrant"

# Init a cluster
sudo kubeadm init \
                    --cri-socket unix:///var/run/cri-dockerd.sock \
                    --apiserver-advertise-address 172.16.8.10 \
                    --pod-network-cidr 172.16.8.0/24

# Generate kubectl config file
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown vagrant:vagrant $HOME/.kube/config

# Apply CNI
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
# kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

# Allow scheduling on the master node
kubectl taint nodes --all node-role.kubernetes.io/master-

# Save the join command to add worker nodes
touch $HOME/shared/join_command.sh
tee $HOME/shared/join_command.sh <<EOF
#!/bin/bash
$(kubeadm token create --print-join-command) --cri-socket unix:///var/run/cri-dockerd.sock
EOF
chmod +x /home/vagrant/shared/join_command.sh