output "resource_group_name" {
  value       = azurerm_resource_group.this.name
  description = "Environment resource group name"
}

output "vnet_id" {
  value       = module.vnet.vnet_id
  description = "VNET ID"
}

output "subnet_ids" {
  value       = module.vnet.subnet_ids
  description = "Subnet IDs"
}

output "vm_public_ip" {
  value       = azurerm_public_ip.vm.ip_address
  description = "VM public IP"
}

output "vm_private_ip" {
  value       = azurerm_network_interface.vm.private_ip_address
  description = "VM private IP"
}

output "storage_account_name" {
  value       = azurerm_storage_account.this.name
  description = "Storage account name"
}

output "storage_blob_endpoint" {
  value       = azurerm_storage_account.this.primary_blob_endpoint
  description = "Storage blob endpoint"
}

