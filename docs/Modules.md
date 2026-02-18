# Terraform Module Documentation

## VNET Module

**Purpose:** Creates Azure Virtual Network with Subnet and Network Security Group

### Variables

| Name | Type | Required | Default | Description |
|------|------|----------|---------|-------------|
| `environment` | string | Yes | - | Environment name (dev, staging, prod) |
| `region` | string | Yes | - | Azure region name |
| `resource_group_name` | string | Yes | - | Name of resource group |
| `vnet_cidr` | string | No | 10.0.0.0/16 | VNET address space |
| `subnet_cidr` | string | No | 10.0.1.0/24 | Subnet address prefix |
| `tags` | map(string) | Yes | - | Tags for resources |

### Outputs

| Name | Description |
|------|-------------|
| `vnet_id` | Virtual Network resource ID |
| `vnet_name` | Virtual Network name |
| `subnet_id` | Subnet resource ID |
| `subnet_name` | Subnet name |
| `nsg_id` | Network Security Group resource ID |

### Usage Example

```hcl
module "vnet" {
  source = "../../modules/vnet"

  environment         = "dev"
  region              = "eastus"
  resource_group_name = "rg-app-dev"
  vnet_cidr           = "10.0.0.0/16"
  subnet_cidr         = "10.0.1.0/24"

  tags = {
    Environment = "dev"
    Project     = "app"
  }
}
```

---

## VM Module

**Purpose:** Deploys Ubuntu Linux virtual machine with networking

### Variables

| Name | Type | Required | Default | Description |
|------|------|----------|---------|-------------|
| `environment` | string | Yes | - | Environment name |
| `region` | string | Yes | - | Azure region |
| `resource_group_name` | string | Yes | - | Resource group name |
| `subnet_id` | string | Yes | - | Subnet to deploy VM to |
| `vm_size` | string | No | Standard_B2s | VM SKU size |
| `os_disk_size_gb` | number | No | 30 | OS disk size |
| `tags` | map(string) | Yes | - | Resource tags |

### Outputs

| Name | Description |
|------|-------------|
| `vm_id` | Virtual Machine resource ID |
| `vm_name` | Virtual Machine name |
| `public_ip_address` | Public IP address |
| `private_ip_address` | Private IP address |
| `nic_id` | Network Interface ID |

### Requirements

- SSH public key at `ssh/id_rsa.pub`
- Network interface must be in same region as VM

### Usage Example

```hcl
module "vm" {
  source = "../../modules/vm"

  environment         = "dev"
  region              = "eastus"
  resource_group_name = "rg-app-dev"
  subnet_id           = module.vnet.subnet_id
  vm_size             = "Standard_B2s"
  os_disk_size_gb     = 30

  tags = {
    Environment = "dev"
    Project     = "app"
  }
}
```

---

## Storage Module

**Purpose:** Creates Azure Storage Account with blob container

### Variables

| Name | Type | Required | Default | Description |
|------|------|----------|---------|-------------|
| `environment` | string | Yes | - | Environment name |
| `region` | string | Yes | - | Region code (eus, wus, etc.) |
| `resource_group_name` | string | Yes | - | Resource group name |
| `account_tier` | string | No | Standard | Tier (Standard, Premium) |
| `account_replication_type` | string | No | LRS | Replication type |
| `tags` | map(string) | Yes | - | Resource tags |

### Outputs

| Name | Description |
|------|-------------|
| `storage_account_id` | Storage Account resource ID |
| `storage_account_name` | Storage Account name |
| `storage_primary_blob_endpoint` | Blob endpoint URL |
| `container_name` | Container name |

### Notes

- Storage account name is auto-generated with hash suffix (global uniqueness required)
- TLS 1.2 enforced
- Infrastructure encryption enabled by default

### Usage Example

```hcl
module "storage" {
  source = "../../modules/storage"

  environment              = "dev"
  region                   = "eus"
  resource_group_name      = "rg-app-dev"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    Environment = "dev"
    Project     = "app"
  }
}
```

---

## Environment Configuration

### dev (Development)

- **Region:** eastus
- **VM Size:** Standard_B2s (1 vCPU, 2 GB RAM)
- **Storage Replication:** LRS
- **OS Disk:** 30 GB
- **Tagging:** Environment=dev, CostCenter=engineering

### staging (Staging)

- **Region:** eastus
- **VM Size:** Standard_D2s_v3 (2 vCPU, 8 GB RAM)
- **Storage Replication:** GRS
- **OS Disk:** 50 GB
- **Tagging:** Environment=staging, CostCenter=engineering

### prod (Production)

- **Region:** eastus
- **VM Size:** Standard_D4s_v3 (4 vCPU, 16 GB RAM)
- **Storage Replication:** GRS
- **OS Disk:** 100 GB
- **Tagging:** Environment=prod, CostCenter=engineering

---

## Adding New Modules

To create a new module:

1. Create directory: `terraform/modules/{module-name}`
2. Add files:
   - `variables.tf` - Input variables
   - `main.tf` - Resource definitions
   - `outputs.tf` - Output values
   - `README.md` - Module documentation

3. Reference in environment config:
   ```hcl
   module "mymodule" {
     source = "../../modules/mymodule"
     # ...
   }
   ```

## Testing Modules

```bash
cd terraform/modules/vnet
terraform init -backend=false
terraform validate
terraform plan -var-file=../../environments/dev/terraform.tfvars
```
