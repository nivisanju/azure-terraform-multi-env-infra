#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "Validating module: $MODULE_DIR"
cd "$MODULE_DIR"

terraform fmt -check -recursive
terraform init -backend=false
terraform validate

echo "OK"

