# VNET module

Reusable Azure VNET module with optional security controls.

## Features

- VNET + subnets
- Optional **NSGs** (per subnet, when `nsg_rules` are provided)
- Optional **DDoS plan**
- Optional **route tables** (per subnet, when routes are provided)
- Service endpoints and subnet delegations

## Usage (example)

```hcl
module "vnet" {
  source = "../../modules/vnet"

  resource_group_name = azurerm_resource_group.this.name
  location            = var.location

  vnet_name     = "vnet-dev-eus-hub-01"
  address_space = ["10.10.0.0/16"]

  enable_ddos_protection = false
  create_nsgs            = true
  create_route_tables    = false

  subnets = [
    {
      name             = "app-subnet"
      address_prefixes = ["10.10.1.0/24"]
      nsg_rules = [
        {
          name                       = "AllowSSH"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          destination_port_range     = "22"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        }
      ]
    }
  ]

  tags = {
    Environment = "dev"
    Region      = "eastus"
    Project     = "case-study"
    ManagedBy   = "Terraform"
    CostCenter  = "engineering"
  }
}
```

## What you need

- Azure subscription / credentials
- Existing or created Resource Group
- VNET CIDR(s) and subnet CIDR(s)

## Testing

- Local smoke validation:
  - `terraform fmt -check -recursive`
  - `terraform init -backend=false`
  - `terraform validate`

CI runs those checks automatically.

<!-- BEGIN_TF_DOCS -->
<!-- terraform-docs will inject Inputs/Outputs here in CI -->
<!-- END_TF_DOCS -->

