# RG (either keep as a resource or move to a small module)
resource "azurerm_resource_group" "this" {
  name     = "rg-${local.name_prefix}-network-01"
  location = var.location
  tags     = local.tags
}

module "vnet" {
  source              = "../../modules/vnet"
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location
  vnet_name           = "vnet-${local.name_prefix}-hub-01"
  address_space       = var.vnet_address_space
  enable_ddos_protection = false
  create_nsgs            = true
  create_route_tables    = false
  dns_servers            = []
  subnets                = var.subnets
  tags                   = local.tags
}

module "storage" {
  source              = "../../modules/storage"
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location
  project             = var.project
  env                 = local.env
  tags                = local.tags
  account_tier        = var.storage_account_tier
  replication_type    = var.storage_replication_type
}

module "vm" {
  source              = "../../modules/vm_linux"
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location
  subnet_id           = module.vnet.subnet_ids["app-subnet"]
  name_prefix         = "${local.name_prefix}-01"
  vm_size             = var.vm_size
  admin_username      = var.vm_admin_username
  ssh_public_key      = var.vm_ssh_public_key
  tags                = local.tags
}