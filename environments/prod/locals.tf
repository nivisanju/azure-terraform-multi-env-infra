locals {
  env          = "prod"
  region       = var.location
  region_abbr  = substr(var.location, 0, 3)

  name_prefix  = "${local.env}-${local.region_abbr}"

  tags = {
    Environment = local.env
    Region      = var.location
    Project     = var.project
    ManagedBy   = "Terraform"
    CostCenter  = var.cost_center
  }
}

