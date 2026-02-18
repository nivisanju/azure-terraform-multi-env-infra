variable "resource_group_name" {
  description = "Resource group where the storage account will be created."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "project" {
  description = "Project identifier for naming/tagging."
  type        = string
}

variable "env" {
  description = "Environment name (e.g. dev, prod)."
  type        = string
}

variable "tags" {
  description = "Base tags applied to all resources."
  type        = map(string)
}

variable "account_tier" {
  description = "Storage account tier."
  type        = string
  default     = "Standard"
}

variable "replication_type" {
  description = "Storage replication type."
  type        = string
  default     = "LRS"
}

variable "container_name" {
  description = "Blob container name. Defaults to tf-<env>."
  type        = string
  default     = ""
}