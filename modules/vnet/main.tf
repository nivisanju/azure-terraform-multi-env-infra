terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0"
    }
  }
}

resource "azurerm_network_ddos_protection_plan" "this" {
  count               = var.enable_ddos_protection ? 1 : 0
  name                = "${var.vnet_name}-ddos"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = merge(var.tags, { Purpose = "DDoS" })
}

resource "azurerm_virtual_network" "this" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space
  dns_servers         = var.dns_servers
  tags                = var.tags

  dynamic "ddos_protection_plan" {
    for_each = var.enable_ddos_protection ? [1] : []
    content {
      id     = azurerm_network_ddos_protection_plan.this[0].id
      enable = true
    }
  }
}

resource "azurerm_network_security_group" "this" {
  for_each = var.create_nsgs ? {
    for s in var.subnets : s.name => s
    if s.nsg_rules != null
  } : {}

  name                = "nsg-${each.key}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = merge(var.tags, { Subnet = each.key, Purpose = "NSG" })

  dynamic "security_rule" {
    for_each = each.value.nsg_rules != null ? each.value.nsg_rules : []
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol

      source_port_range          = try(security_rule.value.source_port_range, null)
      source_port_ranges         = try(security_rule.value.source_port_ranges, null)
      destination_port_range     = try(security_rule.value.destination_port_range, null)
      destination_port_ranges    = try(security_rule.value.destination_port_ranges, null)
      source_address_prefix      = try(security_rule.value.source_address_prefix, null)
      source_address_prefixes    = try(security_rule.value.source_address_prefixes, null)
      destination_address_prefix = try(security_rule.value.destination_address_prefix, null)
      destination_address_prefixes = try(security_rule.value.destination_address_prefixes, null)
      description                = try(security_rule.value.description, null)
    }
  }
}

resource "azurerm_route_table" "this" {
  for_each = var.create_route_tables ? {
    for s in var.subnets : s.name => s
    if s.route_table_routes != null
  } : {}

  name                          = "rt-${each.key}"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  disable_bgp_route_propagation = try(each.value.route_table_disable_bgp, false)
  tags                          = merge(var.tags, { Subnet = each.key, Purpose = "RouteTable" })

  dynamic "route" {
    for_each = each.value.route_table_routes != null ? each.value.route_table_routes : []
    content {
      name                   = route.value.name
      address_prefix         = route.value.address_prefix
      next_hop_type          = route.value.next_hop_type
      next_hop_in_ip_address = try(route.value.next_hop_in_ip_address, null)
    }
  }
}

resource "azurerm_subnet" "this" {
  for_each = { for s in var.subnets : s.name => s }

  name                 = each.key
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = each.value.address_prefixes

  private_endpoint_network_policies_enabled     = try(each.value.private_endpoint_network_policies_enabled, true)
  private_link_service_network_policies_enabled = try(each.value.private_link_service_network_policies_enabled, false)

  service_endpoints           = try(each.value.service_endpoints, [])
  service_endpoint_policy_ids = try(each.value.service_endpoint_policy_ids, [])

  dynamic "delegation" {
    for_each = each.value.delegation != null ? [each.value.delegation] : []
    content {
      name = delegation.value.name
      service_delegation {
        name    = delegation.value.service_delegation.name
        actions = delegation.value.service_delegation.actions
      }
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "this" {
  for_each = var.create_nsgs ? {
    for s in var.subnets : s.name => s
    if s.nsg_rules != null
  } : {}

  subnet_id                 = azurerm_subnet.this[each.key].id
  network_security_group_id = azurerm_network_security_group.this[each.key].id
}

resource "azurerm_subnet_route_table_association" "this" {
  for_each = var.create_route_tables ? {
    for s in var.subnets : s.name => s
    if s.route_table_routes != null
  } : {}

  subnet_id      = azurerm_subnet.this[each.key].id
  route_table_id = azurerm_route_table.this[each.key].id
}

