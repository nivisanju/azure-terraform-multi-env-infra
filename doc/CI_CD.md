# CI/CD Pipeline Documentation

This document describes the GitHub Actions workflow for automated Terraform validation, planning, and deployment.

## Workflow File

**Location:** `.github/workflows/terraform.yml`

**Terraform Version:** 1.6.0 (defined in `env.TF_VERSION`)

## Workflow Triggers

The workflow runs on:

1. **Pull Request** to `main` branch
   - Triggers: `validate` + `plan` jobs
   - Paths: Changes to `environments/**`, `modules/**`, or `.github/workflows/terraform.yml`

2. **Push** to `main` branch
   - Triggers: `validate` + `plan` + `apply` (dev only)
   - Paths: Same as PR trigger

3. **Manual Workflow Dispatch**
   - Allows manual selection of:
     - **Environment**: `dev` or `prod`
     - **Action**: `plan` or `apply`
   - Useful for production deployments

## Jobs Overview

### 1. `validate` Job

**Runs on:** All triggers  
**Purpose:** Code quality checks

**Steps:**
1. Checkout code
2. Setup Terraform 1.6.0
3. **fmt**: `terraform fmt -check -recursive` (fails if files need formatting)
4. **validate vnet module**: Validates `modules/vnet` without backend
5. **validate env roots**: Validates `environments/dev` and `environments/prod` without backend

**Failure conditions:**
- Files not formatted correctly
- Terraform syntax errors
- Provider configuration issues

### 2. `plan` Job

**Runs on:** All triggers  
**Needs:** `validate`  
**Matrix:** `env: [dev, prod]`

**Purpose:** Generate Terraform execution plans

**Steps:**
1. Checkout code
2. Setup Terraform 1.6.0
3. **Azure Login**: Authenticate using Service Principal credentials
4. **init**: Initialize Terraform with remote backend
5. **plan**: Generate plan and save to `tfplan` file
6. **Upload artifact**: Upload `tfplan-<env>` artifact (retained 7 days)

**Environment Variables:**
- `ARM_CLIENT_ID`: Service Principal Client ID
- `ARM_CLIENT_SECRET`: Service Principal Secret
- `ARM_SUBSCRIPTION_ID`: Azure Subscription ID
- `ARM_TENANT_ID`: Azure Tenant ID
- `TF_VAR_subscription_id`: Passed to Terraform variables
- `TF_VAR_tenant_id`: Passed to Terraform variables
- `TF_VAR_vm_ssh_public_key`: SSH public key for VMs

**Output:**
- Plan artifacts available for download from workflow run
- Plan output visible in workflow logs

### 3. `apply` Job

**Runs on:** Push to `main` only  
**Needs:** `validate`, `plan`  
**Matrix:** `env: [dev]`  
**Environment:** Uses GitHub Environment `dev`

**Purpose:** Automatically apply changes to development environment

**Steps:**
1. Checkout code
2. Setup Terraform 1.6.0
3. **Azure Login**: Authenticate using Service Principal credentials
4. **init**: Initialize Terraform with remote backend
5. **apply**: Apply changes automatically (`-auto-approve`)

**Environment Variables:** Same as `plan` job

**⚠️ Important:**
- Only applies to `dev` environment
- Runs automatically on push to `main`
- Uses GitHub Environment protection (if configured)

### 4. `apply-manual` Job

**Runs on:** `workflow_dispatch` with `action == 'apply'`  
**Needs:** `validate`, `plan`  
**Environment:** Uses GitHub Environment from `workflow_dispatch` input (`dev` or `prod`)

**Purpose:** Manual deployment to any environment (typically production)

**Steps:**
1. Checkout code
2. Setup Terraform 1.6.0
3. **Azure Login**: Authenticate using Service Principal credentials
4. **init**: Initialize Terraform with remote backend
5. **apply**: Apply changes automatically (`-auto-approve`)

**Usage:**
1. Go to **Actions** tab in GitHub
2. Select **Terraform CI/CD** workflow
3. Click **Run workflow**
4. Select:
   - Branch: `main`
   - Environment: `dev` or `prod`
   - Action: `apply`
5. Click **Run workflow**

**⚠️ Important:**
- Requires manual approval if GitHub Environment protection is enabled
- Always review plan artifacts before applying to production

## Required Secrets

The workflow requires these **Repository Secrets** (Settings → Secrets and variables → Actions):

| Secret Name | Description | Example |
|------------|-------------|---------|
| `AZURE_CLIENT_ID` | Service Principal Client ID (Application ID) | `12345678-1234-1234-1234-123456789abc` |
| `ARM_CLIENT_SECRET` | Service Principal Client Secret | `~Secret123~` |
| `AZURE_SUBSCRIPTION_ID` | Azure Subscription ID | `12345678-1234-1234-1234-123456789abc` |
| `AZURE_TENANT_ID` | Azure Tenant ID (Directory ID) | `12345678-1234-1234-1234-123456789abc` |
| `VM_SSH_PUBLIC_KEY` | SSH public key for VM access | `ssh-rsa AAAAB3NzaC1yc2E...` |

### Creating Service Principal

If you need to create a new Service Principal:

```bash
# Login to Azure
az login

# Create Service Principal with Contributor role
az ad sp create-for-rbac \
  --name "github-actions-terraform" \
  --role Contributor \
  --scopes /subscriptions/<SUBSCRIPTION_ID> \
  --sdk-auth

# Output will include:
# {
#   "clientId": "...",
#   "clientSecret": "...",
#   "subscriptionId": "...",
#   "tenantId": "..."
# }
```

**Note:** The workflow uses individual secrets (`AZURE_CLIENT_ID`, `ARM_CLIENT_SECRET`, etc.) rather than a single `AZURE_CREDENTIALS` JSON secret.

## Authentication Flow

1. **GitHub Actions** → **Azure Login Action** (`azure/login@v2`)
   - Uses `creds` JSON constructed from individual secrets
   - Authenticates Azure CLI

2. **Terraform** → **AzureRM Provider**
   - Uses `ARM_*` environment variables:
     - `ARM_CLIENT_ID`
     - `ARM_CLIENT_SECRET`
     - `ARM_SUBSCRIPTION_ID`
     - `ARM_TENANT_ID`
   - This ensures Terraform uses Service Principal auth (not Azure CLI)

## GitHub Environments

GitHub Environments provide protection rules for deployments:

### Recommended Configuration

**dev Environment:**
- No protection rules (for rapid iteration)
- Auto-approval enabled

**prod Environment:**
- Require manual approval
- Require 2+ reviewers
- Restrict who can approve deployments

### Setting Up Environments

1. Go to **Settings** → **Environments**
2. Create environments: `dev`, `prod`
3. Configure protection rules for `prod`
4. The workflow automatically uses these environments

## Workflow Best Practices

### Before Merging PRs

1. Review `validate` job output
2. Review `plan` output for both environments
3. Download and inspect plan artifacts if needed
4. Ensure no unexpected resource changes

### Production Deployments

1. Merge PR to `main` first (triggers dev apply)
2. Verify dev deployment is successful
3. Use workflow dispatch to apply to prod
4. Review plan output before approving
5. Monitor deployment logs

### Troubleshooting Failed Workflows

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for:
- Authentication errors
- Formatting failures
- Provider version issues
- State lock problems

## Workflow Artifacts

- **Plan artifacts**: Available for 7 days after workflow run
- **Location**: Workflow run → Artifacts section
- **Naming**: `tfplan-dev`, `tfplan-prod`

## Monitoring

- **Workflow runs**: View in **Actions** tab
- **Deployment history**: View in **Environments** tab
- **Notifications**: Configure in repository settings

---

For questions or issues, refer to [TROUBLESHOOTING.md](TROUBLESHOOTING.md) or contact the DevOps team.
