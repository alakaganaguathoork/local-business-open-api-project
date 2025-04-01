provider "vagrant" {}

# Provisioning the Kubernetes control plane VMs
resource "vagrant_vm" "control_plane" {
  count = 3
  name  = "k8s-control-plane-${count.index + 1}"
  box   = "ubuntu/bionic64"

  network_interface {
    type = "private_network"
    adapter = "1"
  }

  memory = 2048
  cpus   = 2

  provisioner "remote-exec" {
    inline = [
      "sudo apt update && sudo apt upgrade -y",
      "sudo apt install -y apt-transport-https curl",
      "curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -",
      "echo 'deb https://apt.kubernetes.io/ kubernetes-xenial main' | sudo tee -a /etc/apt/sources.list.d/kubernetes.list",
      "sudo apt update",
      "sudo apt install -y kubelet kubeadm kubectl",
      "sudo apt-mark hold kubelet kubeadm kubectl",
      "sudo systemctl enable kubelet && sudo systemctl start kubelet",
      "sudo kubeadm init --pod-network-cidr=10.244.0.0/16",
      "mkdir -p $HOME/.kube",
      "sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config",
      "sudo chown $(id -u):$(id -g) $HOME/.kube/config",
      "kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml"
    ]
  }

  provisioner "remote-exec" {
    when = destroy
    inline = [
      "sudo kubeadm reset -f"
    ]
  }
}

# Join worker nodes to the Kubernetes cluster
resource "vagrant_vm" "worker" {
  count = 2
  name  = "k8s-worker-${count.index + 1}"
  box   = "ubuntu/bionic64"
  
  network_interface {
    type    = "private_network"
    adapter = "1"
  }

  memory = 2048
  cpus   = 2

  provisioner "remote-exec" {
    inline = [
      "sudo apt update && sudo apt upgrade -y",
      "sudo apt install -y apt-transport-https curl",
      "curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -",
      "echo 'deb https://apt.kubernetes.io/ kubernetes-xenial main' | sudo tee -a /etc/apt/sources.list.d/kubernetes.list",
      "sudo apt update",
      "sudo apt install -y kubelet kubeadm kubectl",
      "sudo apt-mark hold kubelet kubeadm kubectl",
      "sudo systemctl enable kubelet && sudo systemctl start kubelet",
      "sudo kubeadm join ${vagrant_vm.control_plane[0].network_interface[0].ip}:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash>"
    ]
  }

  provisioner "remote-exec" {
    when = destroy
    inline = [
      "sudo kubeadm reset -f"
    ]
  }
}

provider "kubernetes" {
  host                   = "https://${vagrant_vm.control_plane[0].network_interface[0].ip}:6443"
  client_certificate     = file("~/.kube/config")
  client_key             = file("~/.kube/config")
  cluster_ca_certificate = file("~/.kube/config")
}

# Deploying the Python app
resource "kubernetes_deployment" "python_app" {
  metadata {
    name = "python-app"
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "python-app"
      }
    }
    template {
      metadata {
        labels = {
          app = "python-app"
        }
      }

      spec {
        container {
          name  = "python-app"
          image = "yourusername/python-app:latest"  # Replace with your Docker image
          port {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "python_app_service" {
  metadata {
    name = "python-app-service"
  }

  spec {
    selector = {
      app = "python-app"
    }

    port {
      port        = 80
      target_port = 80
      protocol    = "TCP"
    }

    type = "NodePort"
  }
}

