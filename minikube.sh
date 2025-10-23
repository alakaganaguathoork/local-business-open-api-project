#!/bin/bash


###
## This script atuomates creating of a minikube local cluster on VMs using libvirt static MACs setup
###

set -euo pipefail

MK_DRIVER="kvm2"
MK_CONTAINER_RUNTIME="containerd"
CLUSTER_NAME="minikube"
NETWORK_NAME="minikube"
K8S_VERSION="1.32.0"
MK_ADDONS_LIST="ingress,volumesnapshots,csi-hostpath-driver"

declare -A NODE_MACS=(
  ["${CLUSTER_NAME}"]="52:54:00:aa:00:01"
  ["${CLUSTER_NAME}-m02"]="52:54:00:aa:00:02"
  ["${CLUSTER_NAME}-m03"]="52:54:00:aa:00:03"
)
declare -A NODE_IPS=(
  ["${CLUSTER_NAME}"]="192.168.58.101"
  ["${CLUSTER_NAME}-m02"]="192.168.58.102"
  ["${CLUSTER_NAME}-m03"]="192.168.58.103"
)

# 1️⃣ Ensure libvirt network exists
if ! sudo virsh net-info "$NETWORK_NAME" &>/dev/null; then
  echo "🛠️  Creating libvirt network $NETWORK_NAME"
  sudo tee /tmp/${NETWORK_NAME}-network.xml >/dev/null <<EOF
<network>
  <name>${NETWORK_NAME}</name>
  <forward mode='nat'/>
  <bridge name='virbr-${NETWORK_NAME}' stp='on' delay='0'/>
  <ip address='192.168.58.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='192.168.58.100' end='192.168.58.254'/>
$(for node in "${!NODE_MACS[@]}"; do
  echo "      <host mac='${NODE_MACS[$node]}' name='${node}' ip='${NODE_IPS[$node]}'/>"
done)
    </dhcp>
  </ip>
</network>
EOF
  sudo virsh net-define /tmp/${NETWORK_NAME}-network.xml
  sudo virsh net-start ${NETWORK_NAME}
  sudo virsh net-autostart ${NETWORK_NAME}
  sudo rm /tmp/${NETWORK_NAME}-network.xml
else
  echo "✅ Network ${NETWORK_NAME} already exists."
fi

# 2️⃣ Create cluster but immediately stop all nodes
echo "🚀 Creating Minikube cluster..."
minikube start \
  --driver=$MK_DRIVER \
  --container-runtime=$MK_CONTAINER_RUNTIME \
  --network=$NETWORK_NAME \
  --kubernetes-version="v${K8S_VERSION}" \
  --nodes=3 \
  --addons=$MK_ADDONS_LIST \

echo "🛑 Shutting down nodes for MAC patch..."
minikube stop

# 3️⃣ Patch persistent MACs for all nodes (while powered off)
for node in "${!NODE_MACS[@]}"; do
  echo "🔧 Defining static MAC for $node → ${NODE_MACS[$node]}"
  sudo virsh dumpxml "$node" | \
    sudo sed "s/<mac address='[^']*'\/>/<mac address='${NODE_MACS[$node]}'\/>/" | \
    sudo tee /tmp/${node}.xml >/dev/null
  sudo virsh define /tmp/${node}.xml
  sudo rm /tmp/${node}.xml
done

# 4️⃣ Restart cluster (MACs now fixed)
echo "♻️  Restarting cluster..."
minikube start --driver=$MK_DRIVER --network=$NETWORK_NAME

# 5️⃣ Verify IP consistency
echo "✅ Cluster ready. Node details:"
kubectl get nodes -owide

echo "🌐 Minikube IP: $(minikube ip)"

echo "🔎 Etcd status:"
minikube ssh -p $CLUSTER_NAME \
    -- "find /var/lib/minikube/binaries -iname kubectl -exec sudo {} \
    --kubeconfig=/var/lib/minikube/kubeconfig exec -ti pod/etcd-$CLUSTER_NAME \
    -n kube-system -- \
    /bin/sh -c \"ETCDCTL_API=3 etcdctl member list --write-out=table \
    --cacert=/var/lib/minikube/certs/etcd/ca.crt \
    --cert=/var/lib/minikube/certs/etcd/server.crt \
    --key=/var/lib/minikube/certs/etcd/server.key\" \; \
    -quit"
