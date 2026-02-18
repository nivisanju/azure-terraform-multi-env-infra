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


output "storage_account_name" {
  value       = module.storage.storage_account_name
  description = "Storage account name"
}

output "storage_blob_endpoint" {
  value       = module.storage.primary_blob_endpoint
  description = "Storage blob endpoint"
}



output "vm_public_ip" {
  value       = module.vm.public_ip_address
  description = "VM public IP"
}