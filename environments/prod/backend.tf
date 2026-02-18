
terraform {
  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = "~>1.5"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "rg-pf-api-tfstate-ol-eus-002"
    storage_account_name = "stterraformpoceus001"
    container_name       = "terraform-backend"
    key                  = "Azure_core/EastUS/prod/terraform.tfstate"
    subscription_id      = "6a86f866-946c-4313-8eab-219a3df8acfd"
    tenant_id            = "773fd5cb-c4ae-4eda-9357-43e4adc8665f"
  }
}


provider "azurerm" {
  features {}
}
