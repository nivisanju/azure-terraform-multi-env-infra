output "vnet_id" {
  description = "VNET resource ID"
  value       = azurerm_virtual_network.this.id
}

output "vnet_name" {
  description = "VNET name"
  value       = azurerm_virtual_network.this.name
}

output "subnet_ids" {
  description = "Map of subnet name => subnet ID"
  value       = { for k, s in azurerm_subnet.this : k => s.id }
}

output "nsg_ids" {
  description = "Map of subnet name => NSG ID (only where NSGs exist)"
  value       = { for k, n in azurerm_network_security_group.this : k => n.id }
}

output "route_table_ids" {
  description = "Map of subnet name => route table ID (only where RTs exist)"
  value       = { for k, rt in azurerm_route_table.this : k => rt.id }
}

output "ddos_protection_plan_id" {
  description = "DDoS plan ID if enabled, otherwise null"
  value       = var.enable_ddos_protection ? azurerm_network_ddos_protection_plan.this[0].id : null
}

output "network_summary" {
  description = "High-level network summary for automation/runbooks"
  value = {
    vnet_id        = azurerm_virtual_network.this.id
    vnet_name      = azurerm_virtual_network.this.name
    address_space  = azurerm_virtual_network.this.address_space
    subnet_count   = length(azurerm_subnet.this)
    subnet_ids     = { for k, s in azurerm_subnet.this : k => s.id }
    ddos_enabled   = var.enable_ddos_protection
    nsg_count      = length(azurerm_network_security_group.this)
    route_tbl_cnt  = length(azurerm_route_table.this)
  }
}

