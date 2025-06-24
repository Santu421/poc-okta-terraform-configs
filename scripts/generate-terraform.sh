#!/bin/bash

# Script to generate Terraform configuration from .tfvars files
# This script copies config content into modules and generates main.tf

set -e

# Configuration
MODULES_REPO_PATH="../poc-okta-terraform-modules"
APP_PATH="$1"
APP_NAME="$2"

if [ -z "$APP_PATH" ] || [ -z "$APP_NAME" ]; then
    echo "Usage: $0 <app_path> <app_name>"
    echo "Example: $0 apps/app1 app1"
    exit 1
fi

echo "Generating Terraform configuration for $APP_NAME..."

# Create working directory
WORK_DIR="$(pwd)/generated/$APP_NAME"
mkdir -p "$WORK_DIR"

# Copy modules to working directory
echo "Copying modules..."
cp -r "$MODULES_REPO_PATH/modules" "$WORK_DIR/"

# Copy root files
cp "$MODULES_REPO_PATH/versions.tf" "$WORK_DIR/"
cp "$MODULES_REPO_PATH/README.md" "$WORK_DIR/"

# Generate main.tf from template
echo "Generating main.tf..."

cat > "$WORK_DIR/main.tf" << 'EOF'
terraform {
  required_version = ">= 1.0"
  required_providers {
    okta = {
      source  = "okta/okta"
      version = "~> 4.0"
    }
  }
}

# Load variables from .tfvars files
variable "app_name" {}
variable "app_label" {}
variable "grant_types" { type = list(string) }
variable "redirect_uris" { type = list(string) }
variable "response_types" { type = list(string) }
variable "token_endpoint_auth_method" { default = null }
variable "auto_submit_toolbar" { default = null }
variable "hide_ios" { default = null }
variable "hide_web" { default = null }
variable "issuer_mode" { default = null }
variable "pkce_required" { default = null }

variable "bookmark_name" {}
variable "bookmark_label" {}
variable "bookmark_url" {}
variable "bookmark_status" { default = "ACTIVE" }

variable "group_name" {}
variable "group_description" { default = null }
variable "group_type" { default = "OKTA_GROUP" }

variable "trusted_origin_name" {}
variable "trusted_origin_url" {}
variable "trusted_origin_scopes" { type = list(string) }
variable "trusted_origin_status" { default = "ACTIVE" }

variable "app_group_assignments" { type = list(object({
  app_name = string
  group_name = string
})) }

# OAuth App
module "okta_oauth_app" {
  source = "./modules/okta_app_oauth"
  
  app = {
    name         = var.app_name
    label        = var.app_label
    grant_types  = var.grant_types
    redirect_uris = var.redirect_uris
    response_types = var.response_types
    token_endpoint_auth_method = var.token_endpoint_auth_method
    auto_submit_toolbar = var.auto_submit_toolbar
    hide_ios = var.hide_ios
    hide_web = var.hide_web
    issuer_mode = var.issuer_mode
    pkce_required = var.pkce_required
  }
}

# Bookmark App
module "okta_bookmark" {
  source = "./modules/okta_app_bookmark"
  
  bookmark = {
    name   = var.bookmark_name
    label  = var.bookmark_label
    url    = var.bookmark_url
    status = var.bookmark_status
    auto_submit_toolbar = var.auto_submit_toolbar
    hide_ios = var.hide_ios
    hide_web = var.hide_web
  }
}

# Group
module "okta_group" {
  source = "./modules/okta_group"
  
  group = {
    name        = var.group_name
    description = var.group_description
    type        = var.group_type
  }
}

# Trusted Origin
module "okta_trusted_origin" {
  source = "./modules/okta_trusted_origin"
  
  trusted_origin = {
    name   = var.trusted_origin_name
    origin = var.trusted_origin_url
    scopes = var.trusted_origin_scopes
    status = var.trusted_origin_status
  }
}

# App-Group Assignments
module "okta_app_group_assignments" {
  source = "./modules/okta_app_group_assignment"
  assignments = var.app_group_assignments
}

# Outputs
output "oauth_app_id" {
  value = module.okta_oauth_app.app_id
}

output "oauth_client_id" {
  value = module.okta_oauth_app.client_id
}

output "bookmark_app_id" {
  value = module.okta_bookmark.app_id
}

output "group_id" {
  value = module.okta_group.group_id
}

output "trusted_origin_id" {
  value = module.okta_trusted_origin.trusted_origin_id
}
EOF

# Copy .tfvars files to working directory
echo "Copying .tfvars files..."
cp "$APP_PATH"/*.tfvars "$WORK_DIR/"

echo "Generated Terraform configuration in: $WORK_DIR"
echo ""
echo "To deploy:"
echo "cd $WORK_DIR"
echo "terraform init"
echo "terraform plan"
echo "terraform apply" 