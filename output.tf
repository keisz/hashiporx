output "hashiporx_server" {
  description = "hashiporx servers"
  value       = vsphere_virtual_machine.vm_server.*.name
}

output "hashiporx_client" {
  description = "hashiporx servers"
  value       = vsphere_virtual_machine.vm_client.*.name
}

output "vault_hostname" {
  description = "vault hostame"
  value       = vsphere_virtual_machine.vm_vault.*.name
}

output "server_ip" {
  description = "default ip address of the deployed VM"
  value       = vsphere_virtual_machine.vm_server.*.default_ip_address
}

output "client_ip" {
  description = "default ip address of the deployed VM"
  value       = vsphere_virtual_machine.vm_client.*.default_ip_address
}

output "vault_ip" {
  description = "default ip address of the deployed VM"
  value       = vsphere_virtual_machine.vm_vault.*.default_ip_address
}

