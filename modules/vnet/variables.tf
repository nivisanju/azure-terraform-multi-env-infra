variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "vnet_name" {
  description = "VNET name"
  type        = string
}

variable "address_space" {
  description = "VNET address spaces (CIDRs)"
  type        = list(string)
}

variable "dns_servers" {
  description = "Optional custom DNS servers for the VNET"
  type        = list(string)
  default     = []
}

variable "enable_ddos_protection" {
  description = "Enable DDoS protection plan for the VNET (costs apply)"
  type        = bool
  default     = false
}

variable "create_nsgs" {
  description = "Create NSGs per subnet when rules are provided"
  type        = bool
  default     = true
}

variable "create_route_tables" {
  description = "Create route tables per subnet when routes are provided"
  type        = bool
  default     = false
}

variable "subnets" {
  description = "Subnet definitions (supports optional NSG rules, service endpoints, delegation, and routes)"
  type = list(object({
    name             = string
    address_prefixes = list(string)

    private_endpoint_network_policies_enabled     = optional(bool, true)
    private_link_service_network_policies_enabled = optional(bool, false)

    service_endpoints           = optional(list(string), [])
    service_endpoint_policy_ids = optional(list(string), [])

    delegation = optional(object({
      name = string
      service_delegation = object({
        name    = string
        actions = list(string)
      })
    }), null)

    nsg_rules = optional(list(object({
      name                         = string
      priority                     = number
      direction                    = string
      access                       = string
      protocol                     = string
      source_port_range            = optional(string)
      source_port_ranges           = optional(list(string))
      destination_port_range       = optional(string)
      destination_port_ranges      = optional(list(string))
      source_address_prefix        = optional(string)
      source_address_prefixes      = optional(list(string))
      destination_address_prefix   = optional(string)
      destination_address_prefixes = optional(list(string))
      description                  = optional(string)
    })), null)

    route_table_routes = optional(list(object({
      name                   = string
      address_prefix         = string
      next_hop_type          = string
      next_hop_in_ip_address = optional(string)
    })), null)

    route_table_disable_bgp = optional(bool, false)
  }))
}

variable "tags" {
  description = "Tags applied to all resources created by this module"
  type        = map(string)
  default     = {}
}

