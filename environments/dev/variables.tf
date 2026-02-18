variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "tenant_id" {
  description = "Azure tenant ID"
  type        = string
}

variable "location" {
  description = "Azure region (e.g. eastus)"
  type        = string
  default     = "eastus"
}

variable "project" {
  description = "Project identifier for naming/tagging"
  type        = string
  default     = "case-study"
}

variable "cost_center" {
  description = "Cost center tag"
  type        = string
  default     = "engineering"
}

variable "vnet_address_space" {
  description = "VNET CIDR"
  type        = list(string)
  default     = ["10.10.0.0/16"]
}

variable "subnets" {
  description = "Subnet definitions passed to the VNET module"
  type        = any
}

variable "vm_size" {
  description = "VM SKU"
  type        = string
  default     = "Standard_B2s"
}

variable "vm_admin_username" {
  description = "VM admin username"
  type        = string
  default     = "azureuser"
}

variable "vm_ssh_public_key" {
  description = "SSH public key (contents)"
  type        = string
}

variable "storage_account_tier" {
  description = "Storage tier"
  type        = string
  default     = "Standard"
}

variable "storage_replication_type" {
  description = "Replication type"
  type        = string
  default     = "LRS"
}

