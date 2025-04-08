#!/bin/bash

arch="$(dpkg --print-architecture)"
k8s_version="1.32"
cri_dockerd_version="0.3.16"
cri_dockerd_tar_name="cri-dockerd-$cri_dockerd_version.$arch.tgz"

#Update packages list
sudo apt update
sudo apt upgrade -y

#Install required packages
sudo apt install -y curl \
                    lsb-release \
                    ca-certificates \
                    gnupg \
                    gpg \
                    apt-transport-https \
                    net-tools \
                    nano \
                    tar

#Install Docker
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
            -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$arch signed-by=/etc/apt/keyrings/docker.asc] \
  https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce \
                    docker-ce-cli \
                    containerd.io \
                    docker-buildx-plugin \
                    docker-compose-plugin

# sudo tee /etc/docker/daemon.json <<EOF
# {
  # 
    # "exec-opts": ["native.cgroupdriver=systemd"],
  # 
    # "log-driver": "json-file",
  # 
    # "log-opts": {
  # 
        # "max-size": "100m"
  # 
    # },
  # 
    # "storage-driver": "overlay2"
  # 
# }
# EOF

#Restart Docker with new settings
sudo systemctl enable docker.service
sudo systemctl enable containderd.service
sudo systemctl daemon-reload
sudo systemctl restart docker.service
sudo systemctl status docker.service

#Install cri-dockerd (to use docker as CRI)
wget https://github.com/Mirantis/cri-dockerd/releases/download/v$cri_dockerd_version/$cri_dockerd_tar_name
tar xvf $cri_dockerd_tar_name
sudo chown root:root cri-dockerd/cri-dockerd
sudo mv cri-dockerd/cri-dockerd /usr/bin/
rm $cri_dockerd_tar_name
rm -r cri-dockerd/

sudo tee /etc/systemd/system/cri-docker.service <<EOF
[Unit]
Description=CRI interface for Docker
Requires=docker.service
After=docker.service

[Service]
ExecStart=/usr/bin/cri-dockerd --container-runtime-endpoint=unix:///var/run/cri-dockerd.sock
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

sudo tee /etc/systemd/system/cri-docker.socket <<EOF 
[Unit]
Description=CRI Docker Socket for Kubernetes
PartOf=cri-docker.service

[Socket]
ListenStream=/run/cri-dockerd.sock
SocketMode=0660
SocketUser=root
SocketGroup=docker

[Install]
WantedBy=sockets.target
EOF

# sudo systemctl enable cri-docker
sudo systemctl start cri-docker
sudo systemctl enable --now cri-docker.service cri-docker.socket

# Install k8s components 
curl -fsSL https://pkgs.k8s.io/core:/stable:/v$k8s_version/deb/Release.key | \
sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v$k8s_version/deb/ /" | \
sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update
sudo apt install -y kubelet \
                    kubeadm \
                    kubectl
sudo apt-mark hold kubelet \
                    kubeadm \
                    kubectl

# Disable swap
sudo swapoff -a
#(makes swapoff setting persistent)
sudo sed -i '/ swap / s/^/#/' /etc/fstab 

# Check if a required port opened (for kubectl to interact)
#nc 127.0.0.1 6443 -zv -w 2

# Enable required modules
sudo tee /etc/modules-load.d/k8s.conf <<EOF
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

#Configure k8s network setup
sudo tee /etc/sysctl.d/kubernetes.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1 
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
 
#Restart networking settings
sudo sysctl --system
#sudo sysctl -p /etc/sysctl.d/kubernetes.conf

#Manage Docker as a non-root user
# sudo groupadd docker
sudo usermod -aG docker $USER
# sudo newgrp docker

#Enable and start kubelet
sudo systemctl enable kubelet
sudo systemctl start kubelet.service
