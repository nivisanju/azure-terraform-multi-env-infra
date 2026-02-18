# Remote State Management

This document describes how Terraform remote state is configured and managed in this project.

## Overview

Each environment uses **Azure Storage Account** as the remote state backend, ensuring:

- ✅ State is stored securely in Azure
- ✅ State is shared among team members
- ✅ State locking prevents concurrent modifications
- ✅ State history via blob versioning (if enabled)

## Backend Configuration

### Location

Each environment has its backend configuration in `environments/<env>/backend.tf`:

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-pf-api-tfstate-ol-eus-002"
    storage_account_name = "stterraformpoceus001"
    container_name       = "terraform-backend"
    key                  = "Azure_core/EastUS/dev/terraform.tfstate"
    subscription_id      = "6a86f866-946c-4313-8eab-219a3df8acfd"
    tenant_id            = "773fd5cb-c4ae-4eda-9357-43e4adc8665f"
  }
}
```

### Backend Parameters

| Parameter | Description | Example |
|-----------|-------------|---------|
| `resource_group_name` | Resource group containing storage account | `rg-terraform-state` |
| `storage_account_name` | Storage account name (globally unique) | `stterraformstate` |
| `container_name` | Blob container name | `terraform-backend` |
| `key` | State file path (unique per environment) | `Azure_core/EastUS/dev/terraform.tfstate` |
| `subscription_id` | Subscription ID for backend resources | `12345678-...` |
| `tenant_id` | Tenant ID for authentication | `12345678-...` |

### State Key Convention

Each environment uses a **unique state key** to separate state files:

- **dev**: `Azure_core/EastUS/dev/terraform.tfstate`
- **prod**: `Azure_core/EastUS/prod/terraform.tfstate`

This allows:
- ✅ Multiple environments to share the same storage account/container
- ✅ Clear separation of state per environment
- ✅ Easy identification of state files

## Prerequisites in Azure

Before using remote state, ensure these resources exist:

### 1. Resource Group

```bash
az group create \
  --name rg-terraform-state \
  --location eastus
```

### 2. Storage Account

```bash
az storage account create \
  --name stterraformstate \
  --resource-group rg-terraform-state \
  --location eastus \
  --sku Standard_LRS \
  --kind StorageV2
```

**Note:** Storage account name must be globally unique.

### 3. Blob Container

```bash
az storage container create \
  --name terraform-backend \
  --account-name stterraformstate \
  --auth-mode login
```

### 4. Enable Versioning (Recommended)

```bash
az storage account blob-service-properties update \
  --account-name stterraformstate \
  --enable-versioning true \
  --enable-delete-retention true \
  --delete-retention-days 30
```

## Working with Remote State

### Initialization

**First time setup:**
```bash
cd environments/dev
terraform init
```

**Re-initialization (if backend changes):**
```bash
terraform init -reconfigure
```

**Validation without backend (faster):**
```bash
terraform init -backend=false
terraform validate
```

### State Operations

**View current state:**
```bash
terraform state list
terraform show
```

**View specific resource:**
```bash
terraform state show azurerm_resource_group.example
```

**Remove resource from state (without destroying):**
```bash
terraform state rm azurerm_resource_group.example
```

**Import existing resource:**
```bash
terraform import azurerm_resource_group.example /subscriptions/.../resourceGroups/example
```

**Move resource in state:**
```bash
terraform state mv azurerm_resource_group.old azurerm_resource_group.new
```

### State Locking

Terraform automatically locks state during operations to prevent concurrent modifications.

**If lock is stuck:**
```bash
# Get lock ID from error message
terraform force-unlock <lock-id>
```

**⚠️ Warning:** Only use `force-unlock` if you're certain no other process is using the state.

## State Security Best Practices

### 1. Access Control

- **Storage Account:** Restrict access using RBAC
- **Network Rules:** Use private endpoints or IP whitelisting
- **Service Principal:** Use least-privilege permissions

### 2. Encryption

- **At Rest:** Azure Storage encryption (enabled by default)
- **In Transit:** HTTPS only (enabled by default)

### 3. Backup and Recovery

- **Enable Versioning:** Allows recovery of previous state versions
- **Enable Soft Delete:** Protects against accidental deletion
- **Regular Backups:** Consider exporting state periodically

### 4. State File Contents

**⚠️ Important:** State files contain sensitive information:
- Resource IDs
- Some resource attributes (may include secrets)
- Resource dependencies

**Never commit state files to Git!**

Ensure `.gitignore` includes:
```
*.tfstate
*.tfstate.*
.terraform/
```

## CI/CD State Management

### GitHub Actions

The CI/CD workflow automatically:
1. Initializes Terraform with remote backend
2. Uses Service Principal authentication
3. Locks state during `plan` and `apply`
4. Releases lock after completion

### State Lock Behavior

- **Plan:** Acquires read lock
- **Apply:** Acquires write lock
- **Timeout:** Default 10 minutes (configurable)

If a workflow fails, the lock is automatically released after timeout.

## Troubleshooting State Issues

### State Lock Error

**Error:**
```
Error: Error acquiring the state lock
```

**Solution:**
1. Check for running Terraform processes
2. Check CI/CD workflows
3. Wait for timeout (10 minutes)
4. Use `force-unlock` only if necessary

### State Not Found

**Error:**
```
Error: Failed to get existing workspaces
```

**Solution:**
1. Verify backend configuration
2. Check storage account exists
3. Verify Service Principal has access
4. For new environments, state is created on first `apply`

### State Out of Sync

**Error:**
```
Error: Error refreshing state: Resource not found
```

**Solution:**
1. Check if resource was deleted outside Terraform
2. Use `terraform import` to add missing resources
3. Use `terraform state rm` to remove deleted resources
4. Run `terraform refresh` to sync state

### Access Denied

**Error:**
```
Error: storage: service returned error: StatusCode=403
```

**Solution:**
1. Verify Service Principal has Storage Blob Data Contributor role
2. Check storage account firewall rules
3. Verify subscription and tenant IDs are correct

## State Migration

### Moving State Between Environments

**Not recommended** - Each environment should have its own state.

If absolutely necessary:
1. Export state: `terraform state pull > state.json`
2. Modify state file (change resource names, IDs)
3. Import state: `terraform state push state.json`

### Changing Backend Configuration

1. Update `backend.tf` with new configuration
2. Run `terraform init -migrate-state`
3. Confirm migration when prompted

## Monitoring State

### Storage Account Metrics

Monitor via Azure Portal:
- **Blob count:** Number of state files
- **Storage size:** Total state file size
- **Access patterns:** Read/write frequency

### State File Size

Large state files (>100MB) may indicate:
- Too many resources in single state
- Consider splitting into multiple workspaces
- Clean up unused resources

## Best Practices Summary

✅ **Do:**
- Use separate state keys per environment
- Enable versioning and soft delete
- Use least-privilege access
- Lock state during operations
- Backup state files regularly

❌ **Don't:**
- Commit state files to Git
- Share state files via insecure channels
- Manually edit state files
- Use same state for multiple environments
- Disable state locking

---

For more information, see [TROUBLESHOOTING.md](TROUBLESHOOTING.md#state-management).
