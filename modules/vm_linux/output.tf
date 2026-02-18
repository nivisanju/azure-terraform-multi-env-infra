output "vm_id" {
  description = "VM resource ID."
  value       = azurerm_linux_virtual_machine.this.id
}

output "vm_name" {
  description = "VM name."
  value       = azurerm_linux_virtual_machine.this.name
}

output "nic_id" {
  description = "Network interface ID."
  value       = azurerm_network_interface.this.id
}

output "public_ip_address" {
  description = "Public IP address (null if not created)."
  value       = var.create_public_ip ? azurerm_public_ip.this[0].ip_address : null
}


