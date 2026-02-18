terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

locals {
  resolved_container_name = var.container_name != "" ? var.container_name : "tf-${var.env}"
}

resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

resource "azurerm_storage_account" "this" {
  name                            = "st${replace(var.project, "-", "")}${var.env}${random_string.suffix.result}"
  resource_group_name             = var.resource_group_name
  location                        = var.location
  account_tier                    = var.account_tier
  account_replication_type        = var.replication_type
  account_kind                    = "StorageV2"
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false

  tags = merge(var.tags, {
    Purpose = "Storage"
  })
}

resource "azurerm_storage_container" "this" {
  name                  = local.resolved_container_name
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = "private"
}