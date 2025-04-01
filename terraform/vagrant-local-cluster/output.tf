output "control_plane_ips" {
  value = [for vm in vagrant_vm.control_plane : vm.network_interface[0].ip]
}

output "worker_ips" {
  value = [for vm in vagrant_vm.worker : vm.network_interface[0].ip]
}
