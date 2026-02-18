# Terraform Modules Documentation

This document describes the reusable Terraform modules available in this repository.

## Available Modules

- [vnet](#vnet-module) - Virtual Network with subnets, NSGs, and route tables
- [vm_linux](#vm_linux-module) - Linux Virtual Machine
- [storage](#storage-module) - Storage Account with container

## VNET Module

**Location:** `modules/vnet/`

**Purpose:** Creates a Virtual Network with optional subnets, Network Security Groups (NSGs), route tables, and DDoS protection.

### Features

- ✅ Virtual Network with configurable address space
- ✅ Multiple subnets with custom address prefixes
- ✅ Optional NSGs per subnet with custom rules
- ✅ Optional route tables per subnet
- ✅ Service endpoints support
- ✅ Subnet delegation support
- ✅ Optional DDoS protection plan
- ✅ Custom DNS servers

### Usage Example

```hcl
module "vnet" {
  source = "../../modules/vnet"

  resource_group_name = azurerm_resource_group.this.name
  location            = var.location
  vnet_name           = "vnet-dev-eus-hub-01"
  address_space       = ["10.10.0.0/16"]

  enable_ddos_protection = false
  create_nsgs            = true
  create_route_tables    = false
  dns_servers            = []

  subnets = [
    {
      name             = "app-subnet"
      address_prefixes = ["10.10.1.0/24"]
      service_endpoints = ["Microsoft.Storage"]
      nsg_rules = [
        {
          name                       = "AllowSSH"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "22"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        },
        {
          name                       = "AllowHTTP"
          priority                   = 110
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          destination_port_range     = "80"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        }
      ]
    },
    {
      name             = "data-subnet"
      address_prefixes = ["10.10.2.0/24"]
      service_endpoints = ["Microsoft.Storage"]
    }
  ]

  tags = {
    Environment = "dev"
    Project     = "case-study"
  }
}
```

### Input Variables

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `resource_group_name` | `string` | ✅ | - | Resource group name |
| `location` | `string` | ✅ | - | Azure region |
| `vnet_name` | `string` | ✅ | - | VNET name |
| `address_space` | `list(string)` | ✅ | - | VNET CIDR blocks |
| `dns_servers` | `list(string)` | ❌ | `[]` | Custom DNS servers |
| `enable_ddos_protection` | `bool` | ❌ | `false` | Enable DDoS protection plan |
| `create_nsgs` | `bool` | ❌ | `true` | Create NSGs when rules provided |
| `create_route_tables` | `bool` | ❌ | `false` | Create route tables when routes provided |
| `subnets` | `list(object)` | ✅ | - | Subnet definitions (see below) |
| `tags` | `map(string)` | ❌ | `{}` | Tags for all resources |

### Subnet Object Structure

```hcl
{
  name              = string
  address_prefixes  = list(string)
  
  # Optional
  service_endpoints           = list(string)
  service_endpoint_policy_ids = list(string)
  
  private_endpoint_network_policies_enabled     = bool  # default: true
  private_link_service_network_policies_enabled = bool  # default: false
  
  nsg_rules = list(object({
    name                       = string
    priority                   = number
    direction                  = string  # "Inbound" or "Outbound"
    access                     = string  # "Allow" or "Deny"
    protocol                   = string  # "Tcp", "Udp", "Icmp", "*"
    source_port_range          = optional(string)
    source_port_ranges         = optional(list(string))
    destination_port_range     = optional(string)
    destination_port_ranges    = optional(list(string))
    source_address_prefix      = optional(string)
    source_address_prefixes    = optional(list(string))
    destination_address_prefix = optional(string)
    destination_address_prefixes = optional(list(string))
    description                = optional(string)
  }))
  
  route_table_routes = list(object({
    name                   = string
    address_prefix         = string
    next_hop_type          = string  # "VirtualAppliance", "VnetLocal", etc.
    next_hop_in_ip_address = optional(string)
  }))
  
  route_table_disable_bgp = bool  # default: false
  
  delegation = optional(object({
    name = string
    service_delegation = object({
      name    = string
      actions = list(string)
    })
  }))
}
```

### Outputs

| Output | Description |
|--------|-------------|
| `vnet_id` | VNET resource ID |
| `vnet_name` | VNET name |
| `subnet_ids` | Map of subnet name → subnet ID |
| `nsg_ids` | Map of subnet name → NSG ID (where NSGs exist) |
| `route_table_ids` | Map of subnet name → route table ID (where RTs exist) |
| `ddos_protection_plan_id` | DDoS plan ID if enabled |
| `network_summary` | High-level network summary object |

## VM_LINUX Module

**Location:** `modules/vm_linux/`

**Purpose:** Creates a Linux Virtual Machine with optional public IP.

### Features

- ✅ Linux VM (Ubuntu 22.04 LTS)
- ✅ SSH key authentication
- ✅ Optional public IP
- ✅ Network interface configuration
- ✅ Standard OS disk

### Usage Example

```hcl
module "vm" {
  source = "../../modules/vm_linux"

  resource_group_name = azurerm_resource_group.this.name
  location            = var.location
  subnet_id           = module.vnet.subnet_ids["app-subnet"]
  name_prefix          = "dev-eus-01"
  vm_size              = "Standard_D2s_v3"
  admin_username       = "azureuser"
  ssh_public_key       = var.vm_ssh_public_key
  create_public_ip     = false

  tags = {
    Environment = "dev"
    Project     = "case-study"
  }
}
```

### Input Variables

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `resource_group_name` | `string` | ✅ | - | Resource group name |
| `location` | `string` | ✅ | - | Azure region |
| `subnet_id` | `string` | ✅ | - | Subnet ID for network interface |
| `name_prefix` | `string` | ✅ | - | Prefix for resource names |
| `vm_size` | `string` | ✅ | - | VM SKU (e.g., "Standard_D2s_v3") |
| `admin_username` | `string` | ✅ | - | Admin username |
| `ssh_public_key` | `string` | ✅ | - | SSH public key contents |
| `create_public_ip` | `bool` | ❌ | `false` | Create public IP |
| `tags` | `map(string)` | ❌ | `{}` | Tags for all resources |

### Outputs

| Output | Description |
|--------|-------------|
| `vm_id` | VM resource ID |
| `vm_name` | VM name |
| `vm_private_ip` | VM private IP address |
| `vm_public_ip` | VM public IP (if created) |
| `network_interface_id` | Network interface ID |

## STORAGE Module

**Location:** `modules/storage/`

**Purpose:** Creates a Storage Account with container.

### Features

- Storage Account (StorageV2)
- Blob container
- Random suffix for unique naming
- TLS 1.2 minimum
- Public access disabled

### Usage Example

```hcl
module "storage" {
  source = "../../modules/storage"

  resource_group_name = azurerm_resource_group.this.name
  location            = var.location
  project             = var.project
  env                 = "dev"
  container_name      = ""  # Auto-generated if empty

  account_tier        = "Standard"
  replication_type    = "LRS"

  tags = {
    Environment = "dev"
    Project     = "case-study"
  }
}
```

### Input Variables

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `resource_group_name` | `string` | ✅ | - | Resource group name |
| `location` | `string` | ✅ | - | Azure region |
| `project` | `string` | ✅ | - | Project identifier |
| `env` | `string` | ✅ | - | Environment name |
| `container_name` | `string` | ❌ | `""` | Container name (auto: `tf-<env>` if empty) |
| `account_tier` | `string` | ❌ | `"Standard"` | Storage tier |
| `replication_type` | `string` | ❌ | `"LRS"` | Replication type |
| `tags` | `map(string)` | ❌ | `{}` | Tags for all resources |

### Outputs

| Output | Description |
|--------|-------------|
| `storage_account_id` | Storage Account resource ID |
| `storage_account_name` | Storage Account name |
| `storage_account_primary_endpoint` | Primary endpoint URL |
| `container_id` | Container resource ID |
| `container_name` | Container name |

## Module Development Guidelines

### Adding a New Module

1. **Create module directory:**
   ```bash
   mkdir -p modules/<module-name>
   ```

2. **Create standard files:**
   - `main.tf` - Resource definitions
   - `variables.tf` - Input variables
   - `outputs.tf` - Output values
   - `README.md` - Module documentation (optional)

3. **Follow naming conventions:**
   - Use descriptive resource names
   - Include `tags` variable for consistency
   - Use `locals` for computed values

4. **Test locally:**
   ```bash
   cd modules/<module-name>
   terraform init -backend=false
   terraform validate
   ```

5. **Update documentation:**
   - Add module to this file (`docs/MODULES.md`)
   - Include usage examples
   - Document all variables and outputs

### Module Best Practices

- Use consistent variable naming
- Always include `tags` variable
- Provide sensible defaults where possible
- Use `optional()` for complex object types
- Document all variables and outputs
- Test modules in isolation before use
- Follow Terraform style guide

---

For questions about module usage, refer to the module's source code or contact the DevOps team.
