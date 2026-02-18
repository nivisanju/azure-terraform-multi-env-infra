output "storage_account_name" {
  description = "Storage account name."
  value       = azurerm_storage_account.this.name
}

output "storage_account_id" {
  description = "Storage account ID."
  value       = azurerm_storage_account.this.id
}

output "container_name" {
  description = "Blob container name."
  value       = azurerm_storage_container.this.name
}

output "container_id" {
  description = "Blob container ID."
  value       = azurerm_storage_container.this.id
}

output "primary_blob_endpoint" {
  description = "Storage account primary blob endpoint."
  value       = azurerm_storage_account.this.primary_blob_endpoint
}