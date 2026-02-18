# Release lifecycle (GitHub Actions)

## Branching model (simple)

- Feature branches → Pull Request → `main`

## Pipeline behavior

- **On PR**: `terraform fmt` + `terraform validate` + `terraform plan` (per environment).
- **On merge to main**: `terraform apply` (dev can be auto; prod should be gated).
- **Manual**: `workflow_dispatch` can run plan/apply for selected env.

## Recommended environment gates

Use GitHub Environments:

- `dev`: no approvals (auto deploy)
- `prod`: required reviewers (1–2 approvals)

## Artifacts

- Plan files and `terraform output -json` can be uploaded as artifacts for traceability.

