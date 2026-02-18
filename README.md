# Azure Terraform Multi-Environment Infrastructure

Terraform project for provisioning Azure infrastructure using a **multi-environment** architecture with reusable modules.

## 🏗️ Project Structure

```
azure-terraform-multi-env-infra/
├── environments/          # Environment-specific root modules
│   ├── dev/              # Development environment
│   │   ├── backend.tf    # Remote state configuration
│   │   ├── main.tf       # Root module calling child modules
│   │   ├── variables.tf  # Environment variables
│   │   └── terraform.tfvars  # Environment values
│   └── prod/             # Production environment
│       └── [same structure]
├── modules/              # Reusable Terraform modules
│   ├── vnet/            # Virtual Network module
│   ├── vm_linux/        # Linux VM module
│   └── storage/         # Storage Account module
└── .github/workflows/   # CI/CD pipelines
    └── terraform.yml    # GitHub Actions workflow
```

## 🚀 Quick Start

### Prerequisites

- **Terraform** >= 1.6.0 (matches CI version)
- **Azure CLI** (for local authentication)
- **Git** and access to this repository
- Azure subscription with appropriate permissions

### Local Development

**1. Clone the repository:**
```bash
git clone <repository-url>
cd azure-terraform-multi-env-infra
```

**2. Format and validate code:**
```bash
terraform fmt -recursive

# Validate modules
cd modules/vnet && terraform init -backend=false && terraform validate && cd ../..

# Validate environments
  cd environments/dev
  terraform init -backend=false
  terraform validate


**3. Plan changes (example: dev environment):**
```bash
cd environments/dev
terraform init
terraform plan
```

**4. Apply changes:**
```bash
terraform apply
```

## 📚 Documentation

Comprehensive documentation is available in the `docs/` directory:

- **[ONBOARDING.md](docs/ONBOARDING.md)** - Complete onboarding guide for new DevOps engineers
- **[CI_CD.md](docs/CI_CD.md)** - GitHub Actions workflow details and configuration
- **[STATE.md](docs/STATE.md)** - Remote state management and backend configuration
- **[MODULES.md](docs/MODULES.md)** - Module documentation and usage examples
- **[ENVIRONMENT_STRATEGY.md](docs/ENVIRONMENT_STRATEGY.md)** - Resource Groups vs Subscriptions strategy
- **[OUTPUTS_GUIDE.md](docs/OUTPUTS_GUIDE.md)** - What outputs are useful and why
- **[REQUIREMENTS_ASSESSMENT.md](docs/REQUIREMENTS_ASSESSMENT.md)** - Requirements compliance assessment
- **[TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)** - Common issues and solutions

## 🔄 CI/CD Pipeline

The GitHub Actions workflow (`.github/workflows/terraform.yml`) provides:

- **Automatic validation** on every PR and push
- **Terraform plan** for both `dev` and `prod` on PRs
- **Automatic apply** to `dev` on push to `main`
- **Manual apply** to any environment via workflow dispatch

See [docs/CI_CD.md](docs/CI_CD.md) for detailed workflow documentation.

## 🔐 Required GitHub Secrets

The CI/CD pipeline requires these repository secrets:

- `AZURE_CLIENT_ID` - Service Principal Client ID
- `ARM_CLIENT_SECRET` - Service Principal Client Secret
- `AZURE_SUBSCRIPTION_ID` - Azure Subscription ID
- `AZURE_TENANT_ID` - Azure Tenant ID
- `VM_SSH_PUBLIC_KEY` - SSH public key for VM access

See [docs/CI_CD.md](docs/CI_CD.md#required-secrets) for setup instructions.

## 🏷️ Environments

- **dev**: Development environment (auto-applied on push to `main`)
- **prod**: Production environment (manual apply via workflow dispatch)

Each environment has its own:
- Remote state file (separate keys in the same storage account)
- Variable values (`terraform.tfvars`)
- Resource naming (via `locals`)

## 📦 Modules

Reusable modules are located in `modules/`:

- **vnet**: Virtual Network with subnets, NSGs, route tables, DDoS protection
- **vm_linux**: Linux Virtual Machine with public IP option
- **storage**: Storage Account with container

See [docs/MODULES.md](docs/MODULES.md) for detailed module documentation.

## 🤝 Contributing

1. Create a feature branch
2. Make your changes
3. Ensure `terraform fmt` and `terraform validate` pass locally
4. Open a pull request
5. Review the plan output in the PR
6. Merge after approval

## 📝 License

[Add your license information here]
## 📝 Output
**1. App Registration**
<img width="1444" height="434" alt="image" src="https://github.com/user-attachments/assets/58590566-0ce6-4bcb-8746-b2c917361fc6" />
**2. Statefile Storage Account**
<img width="2344" height="1120" alt="image" src="https://github.com/user-attachments/assets/dc8d367a-7869-4b3a-99c2-ea3b075e78c2" />
**3. Resources in Azure portal**
<img width="2882" height="1216" alt="image" src="https://github.com/user-attachments/assets/b52daf6e-3ecb-4b03-8aa1-6b6dcf9ee2f5" />

