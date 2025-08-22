#!/bin/bash

# ===== BASE: image and disk =====
VM_DISK="disks/arch-x86_64-basic-20250815.404997.qcow2"
VM_ISO="iso/archlinux-2025.08.01-x86_64.iso"
DISKS_DIR="disks"

# ===== CLI: command, count, base name =====
COMMAND="${1:-}" # install|create|delete
FILE="${2:-}"    # YAML with values
NAMES=()         # Array of parsed VM names from YAML-file
COUNT=()         # Array of parsed VM count for each name from YAML-file

# ===== VM setup =====
VM_RAMSIZE="2048"
VM_CORES="2"
VM_DISKSIZE="10"
VM_NETNAT="network=default" # nat network
VM_NETBRIDGE="bridge=virbr0" # bridge network

color() {
  # prints in bold magenta
  printf "\e[1;35m%b\e[0m" "$1"
}

# ===== Parsing YAML-file =====
parse_yaml() {
  while read -r line; do
    if [[ $line =~ name: ]]; then
      NAMES+=("$(echo "$line" | sed 's/.*name: *//;s/"//g')") # sed used to get rid of quotes
    elif [[ $line =~ count: ]]; then
      COUNT+=("$(echo "$line" | awk '{print $2}')") # awk used as it simplier to take a number
    fi
  done < "$FILE"
}

create_images_dir() {
  if [[ -d "$DISKS_DIR" ]]; then
    echo "$DISKS_DIR directory already exists.";
  else
    echo "Creating $DISKS_DIR..."
    mkdir -p $DISKS_DIR;
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
    --disk path="$image" \
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
  local action=$COMMAND

  for idx in "${!NAMES[@]}"; do
    local base="${NAMES[$idx]}"
    local total="${COUNT[$idx]}"
    for ((i=1; i<=total; i++)); do
      printf "===== Stage %s for '%b-%i' was STARTED\n" "$action" "$base" "$i" 
      ${action}_one_vm "$i" "$base"
      printf "===== Stage %s for '%b-%i' was DONE\n" "$action" "$base" "$i" 
    done
  done
  # for ((i=1; i<=$count; i++)); do
    # ${action}_one_vm "$i" "$name"
  # done
}

die() { 
  echo "ERROR: $*" >&2 
  exit 1
}


printf "===== Starting! =====\n\n"

case "$COMMAND" in
  install|create|delete)
    parse_yaml
    do_many_vms
    ;;
  *)        
    die "Usage: $0 {install|create|delete} values.yml" 
    ;;
esac

echo "===== Done! ======"
