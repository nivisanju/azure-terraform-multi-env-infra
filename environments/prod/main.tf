resource "azurerm_resource_group" "this" {
  name     = "rg-${local.name_prefix}-network-01"
  location = var.location
  tags     = local.tags
}

module "vnet" {
  source = "../../modules/vnet"

  resource_group_name    = azurerm_resource_group.this.name
  location               = var.location
  vnet_name              = "vnet-${local.name_prefix}-hub-01"
  address_space          = var.vnet_address_space
  enable_ddos_protection = true
  create_nsgs            = true
  create_route_tables    = false
  dns_servers            = []
  subnets                = var.subnets
  tags                   = local.tags
}

resource "random_string" "storage_suffix" {
  length  = 6
  upper   = false
  special = false
}

resource "azurerm_storage_account" "this" {
  name                            = "st${replace(var.project, "-", "")}${local.env}${random_string.storage_suffix.result}"
  resource_group_name             = azurerm_resource_group.this.name
  location                        = var.location
  account_tier                    = var.storage_account_tier
  account_replication_type        = var.storage_replication_type
  account_kind                    = "StorageV2"
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  tags                            = merge(local.tags, { Purpose = "Storage" })
}

resource "azurerm_storage_container" "this" {
  name                  = "tf-${local.env}"
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = "private"
}

resource "azurerm_public_ip" "vm" {
  name                = "pip-${local.name_prefix}-vm-01"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = merge(local.tags, { Purpose = "Compute" })
}

resource "azurerm_network_interface" "vm" {
  name                = "nic-${local.name_prefix}-vm-01"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = merge(local.tags, { Purpose = "Compute" })

  ip_configuration {
    name                          = "internal"
    subnet_id                     = module.vnet.subnet_ids["app-subnet"]
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm.id
  }
}

resource "azurerm_linux_virtual_machine" "this" {
  name                  = "vm-${local.name_prefix}-01"
  location              = var.location
  resource_group_name   = azurerm_resource_group.this.name
  size                  = var.vm_size
  admin_username        = var.vm_admin_username
  network_interface_ids = [azurerm_network_interface.vm.id]

  admin_ssh_key {
    username   = var.vm_admin_username
    public_key = var.vm_ssh_public_key
  }

  disable_password_authentication = true

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  tags = merge(local.tags, { Purpose = "Compute" })
}

