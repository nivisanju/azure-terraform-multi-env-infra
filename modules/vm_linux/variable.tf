variable "resource_group_name" {
  description = "Resource group name."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for the VM NIC."
  type        = string
}

variable "name_prefix" {
  description = "Prefix for VM-related resources (vm, nic, pip)."
  type        = string
}

variable "vm_size" {
  description = "VM SKU."
  type        = string
  default     = "Standard_B2s"
}

variable "admin_username" {
  description = "Admin username."
  type        = string
}

variable "ssh_public_key" {
  description = "SSH public key contents."
  type        = string
}

variable "create_public_ip" {
  description = "Whether to create a public IP."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
}