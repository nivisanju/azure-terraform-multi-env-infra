# GitHub Repository Setup

## Initial Repository Setup

### 1. Create Repository

Create a new GitHub repository with the following settings:

```
Repository Name: azure-infrastructure
Description: Infrastructure as Code for Azure multi-environment deployments
Visibility: Private (adjust based on policy)
```

### 2. GitHub Secrets

Add these secrets under **Settings > Secrets and variables > Actions > New repository secret**:

```
Name: AZURE_SUBSCRIPTION_ID
Value: [Your Azure Subscription ID]

Name: AZURE_TENANT_ID
Value: [Your Azure Tenant ID]

Name: AZURE_CLIENT_ID
Value: [Service Principal App ID]

Name: AZURE_CLIENT_SECRET
Value: [Service Principal Password]

Name: TF_STATE_RG
Value: rg-terraform-state

Name: TF_STATE_SA
Value: stterraformstate

Name: TF_STATE_CONTAINER
Value: tfstate
```

### 3. Environment Protection Rules

Under **Settings > Environments**, create:

**dev**
- No protection rules (rapid iteration)

**staging**
- Require manual approval before deployment
- Approvers: DevOps Team Lead

**prod**
- Require manual approval before deployment
- Approvers: 2+ of: Engineering Manager, Security Lead, DevOps Lead
- Reviewers can approve their own dismissals: ☐ Unchecked

### 4. Branch Protection Rules

Under **Settings > Branches > Add rule**:

**Branch name pattern:** `main`

✓ Require a pull request before merging
  ✓ Require 2 approvals
  ✓ Dismiss stale pull request approvals

✓ Require status checks to pass before merging
  ✓ terraform-plan
  ✓ security-scan
  ✓ terraform-validate

✓ Require branches to be up to date before merging

✓ Require conversation resolution before merging

✓ Include administrators in restrictions

### 5. CODEOWNERS

Create `.github/CODEOWNERS`:

```
# DevOps team owns all infrastructure
terraform/          @devops-team
.github/workflows/   @devops-team

# Docs reviewed by technical writers
*.md                 @tech-writers
```

### 6. Repository Settings

**General**
- Allow auto-merge (squash)
- Allow forking: Unchecked (for private repos)
- Auto-delete head branches

**Security & Analysis**
- Enable Dependabot alerts
- Enable Dependabot security updates
- Enable code scanning

**Deploy keys** (Optional)
- Add any deployment keys if needed for other services

## Initial Commit

```bash
# Initialize local repo (if not already done)
git init
git branch -M main

# Add all files
git add .

# Create initial commit
git commit -m "Initial commit: Multi-environment Terraform infrastructure

- Terraform modules: vnet, vm, storage
- Environment configurations: dev, staging, prod
- GitHub Actions CI/CD pipeline
- Comprehensive documentation
- SSH-based VM authentication
- Remote state management support"

# Add remote and push
git remote add origin https://github.com/YOUR_ORG/azure-infrastructure.git
git push -u origin main
```

## Workflow Triggers

The GitHub Actions workflow is triggered by:

1. **Push to main**
   - Runs terraform plan and apply for dev
   - Automatically applies after successful plan

2. **Pull Request to main**
   - Runs terraform plan
   - Posts results as PR comment
   - Does NOT apply changes (requires merge)

3. **Workflow Dispatch** (manual)
   - Allows manual selection of environment
   - Choose deploy action (plan/apply)
   - Requires environment approval

4. **File Changes**
   - Only triggers on changes to `terraform/` or `.github/workflows/`
   - Ignores documentation-only changes

## GitHub CLI Setup (Optional)

```bash
# Install GitHub CLI
# https://cli.github.com

# Authenticate
gh auth login

# Clone repository
gh repo clone YOUR_ORG/azure-infrastructure
cd azure-infrastructure

# Create feature branch
gh repo create

# Create pull request
gh pr create --title "Add NAT Gateway for outbound connectivity" \
  --body "Adds a NAT Gateway for all VMs to have static outbound IPs"

# Check status
gh pr status
```

## CI/CD Features

### Automated Checks

 **Terraform Format**
- Enforces HCL formatting standards

**Terraform Validate**
- Checks syntax and validity

**Security Scanning**
- Checkov scans for security issues
- Uploads SARIF report for GitHub Security tab

**Artifact Storage**
- Terraform plans stored 5 days
- Outputs stored 30 days
- Available for download if needed

### Approval Flow

**Development (auto)**
```
PR Created → Plan → Merge → Apply (automatic)
```

**Staging (manual)**
```
PR Created → Plan → Merge → Await Approval → Apply
```

**Production (multi-approver)**
```
PR Created → Plan → Merge → 2+ Approvals → Apply
```

## Notifications

Configure notifications under GitHub **Settings > Notifications**:

**Watch this repository:** All Activity

**Notification settings:**
- ☑ Email for push reviews
- ☑ Email for pull request reviews
- ☑ Email when assigned

**Integration with Slack:** (Optional)
```
Add GitHub App to Slack:
- #devops-deployments
- Notifications for workflow runs
- PR comments
```

## Repository Health Checks

Run these after setup:

```bash
# Verify branch protection
gh api repos/{owner}/{repo}/branches/main/protection

# Check secrets configured
gh secret list

# View environments
gh api repos/{owner}/{repo}/environments

# Check Actions enabled
gh api repos/{owner}/{repo} --template '{{.actions_enabled}}'
```

## Backup & Disaster Recovery

```bash
# Mirror repository to backup location
git clone --mirror https://github.com/YOUR_ORG/azure-infrastructure.git
cd azure-infrastructure.git
git push --mirror https://github.com/YOUR_ORG/azure-infrastructure-backup.git
```

## Team Collaboration

### Add Team Members

1. Go to **Settings > Collaborators and teams**
2. Add users or teams
3. Assign roles:
   - **Developers:** Read/Write
   - **Team Leads:** Maintain
   - **DevOps:** Admin

### Create Team

```bash
# Via GitHub CLI
gh team create \
  --org YOUR_ORG \
  --name devops \
  --privacy secret

# Add members
gh team member add devops USERNAME --role maintainer
```

### Rulesets (Optional - GitHub Enterprise)

```yaml
# Enforce rules across organization
- Branch name pattern: ^(main|release/)
- Dismiss stale reviews: true
- Require pull requests: true
- Minimum review count: 2
```

## Continuous Monitoring

### Enable Advanced Security

1. **Settings > Security & analysis > Code security and analysis**
2. Enable:
   - ✓ Dependabot alerts
   - ✓ Dependabot security updates
   - ✓ Secret scanning
   - ✓ Code scanning

### Create Dashboard

Create GitHub Project for infrastructure management:

```
Columns:
- Backlog
- In Progress
- Testing
- Done

Issues:
- New features (databases, load balancers)
- Infrastructure improvements
- Security patches
- Documentation updates
```

## Audit & Compliance

Maintain audit trail:

```bash
# View all commits
gh api repos/{owner}/{repo}/commits

# View deployment history
gh api repos/{owner}/{repo}/deployments

# Export logs (for compliance)
gh run list --limit 100 --json createdAt,databaseId,conclusion,name,status

# Check who deployed what
gh run list --json actor,conclusion,createdAt,name -L 50
```
