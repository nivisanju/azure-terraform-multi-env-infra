# Resource Groups vs Subscriptions (multi-environment)

## Choice used here: Resource Groups

This PoC separates environments using **Resource Groups** (RGs) inside a subscription, combined with consistent **naming** and **mandatory tags**.

### Why Resource Groups are a good default

- **RBAC**: grant access per environment at RG scope (`rg-<env>-<region>-...`).
- **Cost reporting**: cost can be sliced by `Environment` tag while keeping billing simpler.
- **Operational simplicity**: fewer subscriptions, less policy/identity overhead.
- **Scalability**: works well up to many environments; still supports policy at RG scope.

### When separate subscriptions make sense

- **Hard isolation** required (compliance / blast radius).
- **Different billing entities** or chargeback rules.
- **Subscription quotas/limits** require distribution.
- **Different tenants/identity boundaries**.

## How it’s enforced

- Resource names include **environment** and **region**.
- Tags include **Environment / Region / Project / ManagedBy / CostCenter**.
- CI validates Terraform and can be extended to enforce tagging via policy-as-code tools (e.g. Checkov/OPA).

