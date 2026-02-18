# Troubleshooting Guide

Common issues and solutions when working with this Terraform project.

## Table of Contents

- [CI/CD Issues](#cicd-issues)
- [Terraform Errors](#terraform-errors)
- [Authentication Problems](#authentication-problems)
- [State Management](#state-management)
- [Module Issues](#module-issues)

## CI/CD Issues

### `terraform fmt -check` fails (exit code 3)

**Error:**
```
Error: Terraform exited with code 3.
```

**Cause:** Files are not formatted according to Terraform's canonical format.

**Solution:**
```bash
# Format all files
terraform fmt -recursive

# Review changes
git diff

# Commit formatting changes
git add .
git commit -m "chore: terraform fmt"
```

### Workflow fails on Azure login

**Error:**
```
Error: Login failed with Error: Using auth-type: SERVICE_PRINCIPAL. 
Not all values are present. Ensure 'client-id' and 'tenant-id' are supplied.
```

**Cause:** Missing or incorrect GitHub secrets.

**Solution:**
1. Verify all required secrets are set:
   - `AZURE_CLIENT_ID`
   - `ARM_CLIENT_SECRET`
   - `AZURE_SUBSCRIPTION_ID`
   - `AZURE_TENANT_ID`
2. Check secret values are correct (no extra spaces, valid UUIDs)
3. Ensure Service Principal has Contributor role on subscription

### Plan job skipped

**Cause:** Plan job depends on `validate`, which may have failed.

**Solution:**
1. Check `validate` job output for errors
2. Fix formatting or validation issues
3. Re-run workflow

## Terraform Errors

### Duplicate provider / required_providers configuration

**Error:**
```
Error: Duplicate required providers configuration
A module may have only one required providers configuration.
```

**Cause:** Multiple `terraform { required_providers { ... } }` blocks in the same directory.

**Solution:**
- Keep only one `terraform` block per environment directory
- Consolidate provider requirements into a single block
- Remove duplicate `provider.tf` files if they exist

**Example fix:**
```hcl
# backend.tf - Keep this
terraform {
  required_providers {
    azurerm = { ... }
  }
  backend "azurerm" { ... }
}

# provider.tf - Remove this if it duplicates the above
```

### Unsupported argument on AzureRM resources

**Error:**
```
Error: Unsupported argument
An argument named "disable_bgp_route_propagation" is not expected here.
```

**Cause:** Provider version mismatch. The argument may have been renamed or removed in newer AzureRM provider versions.

**Solution:**
1. Check provider version in CI: Look at workflow init output
2. Check Terraform Registry for correct argument name:
   - `disable_bgp_route_propagation` → `bgp_route_propagation_enabled` (inverted boolean)
   - `private_endpoint_network_policies_enabled` → `private_endpoint_network_policies` (string: "Enabled"/"Disabled")
3. Update module code to match provider schema
4. Test locally with same provider version

**Common provider changes:**
- AzureRM 3.x → 4.x: Many boolean arguments changed to string enums
- Check [AzureRM provider changelog](https://github.com/hashicorp/terraform-provider-azurerm/blob/main/CHANGELOG.md)

### Terraform authentication error

**Error:**
```
Error: Error building ARM Config: Authenticating using the Azure CLI is only 
supported as a User (not a Service Principal).
```

**Cause:** Terraform is trying to use Azure CLI authentication, but CI uses Service Principal.

**Solution:**
- Ensure `ARM_*` environment variables are set in workflow:
  - `ARM_CLIENT_ID`
  - `ARM_CLIENT_SECRET`
  - `ARM_SUBSCRIPTION_ID`
  - `ARM_TENANT_ID`
- These variables tell Terraform to use Service Principal auth instead of Azure CLI

## Authentication Problems

### Local: Azure CLI not authenticated

**Error:**
```
Error: Error building ARM Config: Please ensure you have installed the Azure CLI
```

**Solution:**
```bash
# Login to Azure
az login

# Set subscription
az account set --subscription "<subscription-id>"

# Verify
az account show
```

### CI: Service Principal lacks permissions

**Error:**
```
Error: authorization failed
```

**Cause:** Service Principal doesn't have required permissions.

**Solution:**
```bash
# Grant Contributor role to Service Principal
az role assignment create \
  --assignee <client-id> \
  --role Contributor \
  --scope /subscriptions/<subscription-id>
```

### CI: Invalid credentials

**Error:**
```
Error: Login failed with Error: Invalid client secret provided.
```

**Cause:** Service Principal secret expired or incorrect.

**Solution:**
1. Create new Service Principal secret:
   ```bash
   az ad sp credential reset --name <sp-name> --years 2
   ```
2. Update `ARM_CLIENT_SECRET` in GitHub secrets
3. Re-run workflow

## State Management

### State lock error

**Error:**
```
Error: Error acquiring the state lock
LockID: ...
```

**Cause:** Another Terraform process is using the state, or previous run crashed without releasing lock.

**Solution:**
1. **Check for running processes:**
   - Verify no other Terraform runs are in progress
   - Check CI/CD workflows

2. **Force unlock (use with caution):**
   ```bash
   terraform force-unlock <lock-id>
   ```

3. **Prevent future locks:**
   - Use `-lock-timeout` for long operations
   - Ensure workflows complete successfully

### State file not found

**Error:**
```
Error: Failed to get existing workspaces: storage: service returned error
```

**Cause:** State file doesn't exist in storage account, or backend configuration is incorrect.

**Solution:**
1. Verify backend configuration in `backend.tf`:
   - Storage account name
   - Container name
   - State key path
2. Check storage account exists and is accessible
3. For new environments, state will be created on first `terraform apply`

### State file out of sync

**Error:**
```
Error: Error refreshing state: Resource not found
```

**Cause:** Resources were deleted outside of Terraform, or state is stale.

**Solution:**
1. **Import missing resources:**
   ```bash
   terraform import azurerm_resource_group.example /subscriptions/.../resourceGroups/example
   ```

2. **Remove deleted resources from state:**
   ```bash
   terraform state rm azurerm_resource_group.example
   ```

3. **Refresh state:**
   ```bash
   terraform refresh
   ```

## Module Issues

### Module not found

**Error:**
```
Error: Module not found
```

**Cause:** Incorrect module source path or module doesn't exist.

**Solution:**
1. Verify module path is correct:
   ```hcl
   source = "../../modules/vnet"  # Relative to calling file
   ```
2. Ensure module directory exists
3. Run `terraform init` to download modules

### Module variable type mismatch

**Error:**
```
Error: Invalid value for input variable
```

**Cause:** Variable type doesn't match module's expected type.

**Solution:**
1. Check module's `variables.tf` for expected types
2. Verify your variable values match:
   - `string` → `"value"`
   - `number` → `123`
   - `bool` → `true` or `false`
   - `list(string)` → `["item1", "item2"]`
   - `map(string)` → `{ key = "value" }`

### Module output not found

**Error:**
```
Error: Reference to undeclared output value
```

**Cause:** Output doesn't exist in module, or name is misspelled.

**Solution:**
1. Check module's `outputs.tf` for available outputs
2. Verify output name spelling
3. Run `terraform init` to refresh module outputs

## General Tips

### Debugging Terraform

**Enable verbose logging:**
```bash
export TF_LOG=DEBUG
terraform plan
```

**Check provider version:**
```bash
terraform version
terraform providers
```

### Getting Help

1. **Check documentation:**
   - [ONBOARDING.md](ONBOARDING.md)
   - [CI_CD.md](CI_CD.md)
   - [MODULES.md](MODULES.md)

2. **Review workflow logs:**
   - GitHub Actions → Select workflow run → View logs

3. **Test locally:**
   - Reproduce issue locally
   - Check Terraform and provider versions match CI

4. **Contact DevOps team:**
   - Share error message and context
   - Include relevant workflow run link

---

**Still stuck?** Review the error message carefully, check the relevant documentation, and don't hesitate to ask for help!
