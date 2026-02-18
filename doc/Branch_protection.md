# GitHub branch protection rules configuration
# Apply these settings to your main branch

Branch: main

Required status checks to pass before merging:
  ✓ Setup & Validation
  ✓ Terraform Plan
  ✓ Security Scan - Checkov

Require branches to be up to date before merging:
  ✓ Enabled

Require code reviews before merging:
  ✓ Require at least 2 approvals (for changes to terraform/)
  ✓ Dismiss stale pull request approvals when new commits are pushed
  ✓ Require review from Code Owners

Require approval of the most recent reviewable push:
  ✓ Enabled

Require conversation resolution before merging:
  ✓ Enabled

Required status checks that must pass:
  • setup-and-validation
  • terraform-plan
  • security-scan

Restrictions:
   Restrict who can push to matching branches
    - Allow dismissals by: DevOps Team
    - Restrict push access:
      - DevOps Team only
      - Infrastructure Admins only

Additional settings:
   Include administrators
   Require branches to be up to date before merging
  Require signed commits
