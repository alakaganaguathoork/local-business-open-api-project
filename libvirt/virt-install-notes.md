A simple example:
```
ISO_PATH="archlinux-2025.08.01-x86_64.iso";

virt-install \
--name vm-test \
--ram 2048 \
--vcpus 2 \
--cdrom $ISO_PATH \
--network bridge=virbr0 \
--disk path=/var/lib/libvirt/images/u19.qcow2,size=8 \
# --os-variant generic 
```

virt-install \
--name arch \
--ram 2048 \
--vcpus 2 \
--network bridge=virbr0 \
--disk path=/home/mishap/Downloads/Arch-Linux-x86_64-basic-20250815.404997.qcow2,size=8 \
--os-variant generic \
--import