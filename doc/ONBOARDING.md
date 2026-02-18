# Onboarding Guide for DevOps Engineers

Welcome! This guide will help you get started with the Azure Terraform Multi-Environment Infrastructure project.

## 📋 Table of Contents

- [Project Overview](#project-overview)
- [Prerequisites](#prerequisites)
- [Repository Structure](#repository-structure)
- [Local Setup](#local-setup)
- [Development Workflow](#development-workflow)
- [CI/CD Overview](#cicd-overview)
- [Common Tasks](#common-tasks)

## Project Overview

This repository manages Azure infrastructure using Terraform with a **multi-environment** approach:

- **Reusable modules** in `modules/` for common infrastructure patterns
- **Environment-specific configurations** in `environments/` (dev, prod)
- **Automated CI/CD** via GitHub Actions
- **Remote state** stored in Azure Storage Account

## Prerequisites

Before you begin, ensure you have:

### Required Tools

- **Terraform** >= 1.6.0
  ```bash
  # Install via Homebrew (macOS)
  brew install terraform
  
  # Or download from https://www.terraform.io/downloads
  ```

- **Azure CLI** (for local authentication)
  ```bash
  # Install via Homebrew (macOS)
  brew install azure-cli
  
  # Or follow: https://docs.microsoft.com/cli/azure/install-azure-cli
  ```

- **Git** (already installed on most systems)

### Azure Access

- Access to the Azure subscription(s) used by this project
- Permissions to:
  - Create/modify resource groups
  - Deploy resources (VMs, VNETs, Storage Accounts)
  - Read/write to the Terraform state storage account

### GitHub Access

- Access to this repository
- Understanding of GitHub Actions (for CI/CD)

## Repository Structure

```
azure-terraform-multi-env-infra/
├── environments/
│   ├── dev/                    # Development environment
│   │   ├── backend.tf         # Remote state config
│   │   ├── main.tf            # Calls modules
│   │   ├── locals.tf          # Environment-specific locals
│   │   ├── variables.tf       # Variable definitions
│   │   └── terraform.tfvars   # Variable values
│   └── prod/                   # Production environment
│       └── [same structure]
├── modules/
│   ├── vnet/                   # Virtual Network module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── vm_linux/               # Linux VM module
│   └── storage/                # Storage Account module
├── docs/                       # Documentation
└── .github/workflows/
    └── terraform.yml           # CI/CD workflow
```

## Local Setup

### 1. Clone the Repository

```bash
git clone <repository-url>
cd azure-terraform-multi-env-infra
```

### 2. Authenticate to Azure

```bash
# Login to Azure
az login

# Set your subscription (if you have multiple)
az account set --subscription "<subscription-id>"

# Verify
az account show
```

### 3. Verify Terraform Installation

```bash
terraform version
# Should show: Terraform v1.6.0 or higher
```

## Development Workflow

### Formatting Code

Always format your Terraform code before committing:

```bash
terraform fmt -recursive
```

This ensures consistency and prevents CI failures.

### Validating Code

**Quick validation (no backend):**
```bash
# Validate modules
cd modules/vnet
terraform init -backend=false
terraform validate
cd ../..

# Validate environments
cd environments/dev
terraform init -backend=false
terraform validate
cd ../..
```

**Full validation (with backend):**
```bash
cd environments/dev
terraform init
terraform validate
terraform plan
```

### Planning Changes

**For dev environment:**
```bash
cd environments/dev
terraform init
terraform plan
```

**For prod environment:**
```bash
cd environments/prod
terraform init
terraform plan
```

### Applying Changes

⚠️ **Always review the plan output before applying!**

```bash
cd environments/dev
terraform plan -out=tfplan
terraform apply tfplan
```

Or interactively:
```bash
terraform apply
```

## CI/CD Overview

The GitHub Actions workflow automatically:

1. **Validates** code on every PR and push
   - Checks formatting (`terraform fmt -check`)
   - Validates syntax (`terraform validate`)

2. **Plans** changes on pull requests
   - Creates plans for both `dev` and `prod`
   - Uploads plan artifacts for review

3. **Applies** changes automatically
   - **dev**: Auto-applied on push to `main`
   - **prod**: Manual apply via workflow dispatch

See [CI_CD.md](CI_CD.md) for detailed workflow documentation.

## Common Tasks

### Adding a New Module

1. Create module directory: `modules/<module-name>/`
2. Add `main.tf`, `variables.tf`, `outputs.tf`
3. Document usage in `docs/MODULES.md`
4. Reference from environment `main.tf`

### Modifying an Existing Module

1. Make changes in `modules/<module-name>/`
2. Test locally: `terraform init && terraform validate`
3. Update environment code that uses the module
4. Test in dev environment first
5. Create PR with changes

### Adding a New Environment

1. Copy `environments/dev/` to `environments/<new-env>/`
2. Update `backend.tf` with new state key
3. Update `terraform.tfvars` with environment-specific values
4. Add environment to workflow matrix if needed

### Troubleshooting CI Failures

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for common issues:

- Formatting errors
- Provider version mismatches
- Authentication failures
- State lock issues

## Next Steps

1. ✅ Complete local setup
2. ✅ Review [CI_CD.md](CI_CD.md) for workflow details
3. ✅ Read [MODULES.md](MODULES.md) to understand available modules
4. ✅ Check [STATE.md](STATE.md) for remote state configuration
5. ✅ Start with a small change in `dev` environment

## Getting Help

- Review documentation in `docs/` directory
- Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for common issues
- Contact the DevOps team lead for questions

---

**Welcome aboard! 🚀**
