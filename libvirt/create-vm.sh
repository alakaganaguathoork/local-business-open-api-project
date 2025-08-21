#!/bin/bash

# 1 Define consts for images
# ===== BASE: image and disk =====
VM_DISK="disks/arch-x86_64-basic-20250815.404997.qcow2"
VM_ISO="iso/archlinux-2025.08.01-x86_64.iso"
DISKS_DIR="disks"

# 2 Define consts for VM
# ===== CLI: command, count, base name =====
COMMAND="${1:-}"                     # create|delete
COUNT="${2:-1}"                      # how many VMs
BASENAME="${3:-arch}"                # base VM name prefix (default is "arch")

# ===== VM setup =====
VM_RAMSIZE="2048"
VM_CORES="2"
VM_DISKSIZE="10"
VM_NETNAT="network=default" # nat network
VM_NETBRIDGE="bridge=virbr0" # bridge network


create_images_dir() {
  if [[ -d "$DISKS_DIR" ]]; then
    echo "/disks directory already exists.";
  else
    echo "Creating /disks..."
    mkdir $DISKS_DIR;
  fi
}

# 3 Do disk function
create_base_disk() {
  create_images_dir
  echo "Creating an empty disk for $1..."
  qemu-img create -f qcow2 "$1.qcow2" "${VM_DISKSIZE}G" >/dev/null
}

create_golden_disk() {
  local image="$1"

  create_images_dir
  echo "Copying golden image to $image..."
  cp $VM_DISK "$image"
}

# Create VM with a clean disk
install_one_vm() {
  local count=$1
  local name=$2
  local vm_name="$name-$count"
  local image="$DISKS_DIR/$vm_name.qcow2"

  virt-install \
    --name "$vm_name" \
    --cdrom "$VM_ISO" \
    --disk path="$image",size=$VM_DISKSIZE,bus=virtio,format=qcow2 \
    --ram "$VM_RAMSIZE" \
    --vcpus "$VM_CORES" \
    --network "$VM_NETBRIDGE" \
    --os-variant generic \
    --noautoconsole
}

# Create VM with a bootable disk
create_one_vm() {
  local count=$1
  local name=$2
  local vm_name="$name-$count"
  local image="$DISKS_DIR/$vm_name.qcow2"

  create_golden_disk "$image"
  virt-install \
    --name "$vm_name" \
    --ram "$VM_RAMSIZE" \
    --vcpus "$VM_CORES" \
    --network "$VM_NETBRIDGE" \
    --os-variant generic \
    --import \
    --disk path="$image",size="$VM_DISKSIZE" \
    --noautoconsole
}

delete_one_vm() {
  local count=$1
  local name=$2
  local vm_name="$name-$count"

  echo "Shutting down $vm_name..."
  virsh shutdown "$vm_name" >/dev/null 2>&1 || true
  
  sleep 2 || true
  
  echo "Destroying $vm_name..."
  virsh destroy "$vm_name" >/dev/null 2>&1 || true
  
  echo "Deleting $vm_name..."
  virsh undefine "$vm_name" --remove-all-storage || virsh undefine "$vm_name"
}

do_many_vms() {
  local action=$1
  local count=$2
  local name=$3
  
  for ((i=1; i<=$count; i++)); do
    ${action}_one_vm "$i" "$name"
  done
}

die() { 
  echo "ERROR: $*" >&2 
  exit 1
}


echo "===== Starting! ====="

case "$COMMAND" in
  "$COMMAND")  
    do_many_vms $COMMAND $COUNT $BASENAME 
    ;;
  *)        
    die "Usage: $0 {install|create|delete} [count] [basename]" 
    ;;
esac

echo "===== Done! ======"
