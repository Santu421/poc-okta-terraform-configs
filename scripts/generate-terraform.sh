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

# Check which .tfvars files exist to determine which modules to create
OAUTH_2LEG_EXISTS=false
WEB_OIDC_EXISTS=false
NA_OIDC_EXISTS=false
SPA_OIDC_EXISTS=false

if [ -f "$APP_PATH/2leg-api.tfvars" ]; then
    OAUTH_2LEG_EXISTS=true
    echo "Found 2leg-api.tfvars - will create oauth_2leg module"
fi

if [ -f "$APP_PATH/3leg-backend.tfvars" ]; then
    WEB_OIDC_EXISTS=true
    echo "Found 3leg-backend.tfvars - will create web_oidc module"
fi

if [ -f "$APP_PATH/3leg-native.tfvars" ]; then
    NA_OIDC_EXISTS=true
    echo "Found 3leg-native.tfvars - will create na_oidc module"
fi

if [ -f "$APP_PATH/3leg-frontend.tfvars" ]; then
    SPA_OIDC_EXISTS=true
    echo "Found 3leg-frontend.tfvars - will create spa_oidc module"
fi

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

# Common variables
variable "app_name" {}
variable "app_label" {}
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

# OAuth 2-Leg variables
variable "oauth_2leg_app_label" { default = null }
variable "oauth_2leg_auto_submit_toolbar" { default = false }
variable "oauth_2leg_hide_ios" { default = true }
variable "oauth_2leg_hide_web" { default = true }
variable "oauth_2leg_issuer_mode" { default = "ORG_URL" }
variable "oauth_2leg_group_name" { default = null }
variable "oauth_2leg_group_description" { default = null }
variable "oauth_2leg_trusted_origin_name" { default = null }
variable "oauth_2leg_trusted_origin_url" { default = null }
variable "oauth_2leg_bookmark_label" { default = null }
variable "oauth_2leg_bookmark_url" { default = null }

# Web OIDC variables
variable "web_oidc_app_label" { default = null }
variable "web_oidc_redirect_uris" { type = list(string), default = [] }
variable "web_oidc_auto_submit_toolbar" { default = false }
variable "web_oidc_hide_ios" { default = false }
variable "web_oidc_hide_web" { default = false }
variable "web_oidc_issuer_mode" { default = "ORG_URL" }
variable "web_oidc_pkce_required" { default = "OPTIONAL" }
variable "web_oidc_group_name" { default = null }
variable "web_oidc_group_description" { default = null }
variable "web_oidc_trusted_origin_name" { default = null }
variable "web_oidc_trusted_origin_url" { default = null }
variable "web_oidc_bookmark_label" { default = null }
variable "web_oidc_bookmark_url" { default = null }

# Native OIDC variables
variable "na_oidc_app_label" { default = null }
variable "na_oidc_redirect_uris" { type = list(string), default = [] }
variable "na_oidc_auto_submit_toolbar" { default = false }
variable "na_oidc_hide_ios" { default = false }
variable "na_oidc_hide_web" { default = true }
variable "na_oidc_issuer_mode" { default = "ORG_URL" }
variable "na_oidc_pkce_required" { default = "REQUIRED" }
variable "na_oidc_group_name" { default = null }
variable "na_oidc_group_description" { default = null }
variable "na_oidc_trusted_origin_name" { default = null }
variable "na_oidc_trusted_origin_url" { default = null }
variable "na_oidc_bookmark_label" { default = null }
variable "na_oidc_bookmark_url" { default = null }

# SPA OIDC variables
variable "spa_oidc_app_label" { default = null }
variable "spa_oidc_redirect_uris" { type = list(string), default = [] }
variable "spa_oidc_auto_submit_toolbar" { default = false }
variable "spa_oidc_hide_ios" { default = false }
variable "spa_oidc_hide_web" { default = false }
variable "spa_oidc_issuer_mode" { default = "ORG_URL" }
variable "spa_oidc_group_name" { default = null }
variable "spa_oidc_group_description" { default = null }
variable "spa_oidc_trusted_origin_name" { default = null }
variable "spa_oidc_trusted_origin_url" { default = null }
variable "spa_oidc_bookmark_label" { default = null }
variable "spa_oidc_bookmark_url" { default = null }

# Common bookmark variables
variable "bookmark_auto_submit_toolbar" { default = false }
variable "bookmark_hide_ios" { default = false }
variable "bookmark_hide_web" { default = false }

EOF

# Add OAuth 2-Leg module if .tfvars exists
if [ "$OAUTH_2LEG_EXISTS" = true ]; then
    cat >> "$WORK_DIR/main.tf" << 'EOF'

# OAuth 2-Leg Module (API Services)
module "oauth_2leg" {
  source = "./modules/oauth_2leg"
  
  app_label                      = var.oauth_2leg_app_label != null ? var.oauth_2leg_app_label : "${var.app_label} - API"
  auto_submit_toolbar            = var.oauth_2leg_auto_submit_toolbar
  hide_ios                       = var.oauth_2leg_hide_ios
  hide_web                       = var.oauth_2leg_hide_web
  issuer_mode                    = var.oauth_2leg_issuer_mode
  group_name                     = var.oauth_2leg_group_name != null ? var.oauth_2leg_group_name : "${var.group_name} - API Access"
  group_description              = var.oauth_2leg_group_description != null ? var.oauth_2leg_group_description : "API access group for ${var.app_name}"
  group_type                     = var.group_type
  trusted_origin_name            = var.oauth_2leg_trusted_origin_name != null ? var.oauth_2leg_trusted_origin_name : "${var.trusted_origin_name} - API"
  trusted_origin_url             = var.oauth_2leg_trusted_origin_url != null ? var.oauth_2leg_trusted_origin_url : var.trusted_origin_url
  trusted_origin_scopes          = var.trusted_origin_scopes
  trusted_origin_status          = var.trusted_origin_status
  bookmark_label                 = var.oauth_2leg_bookmark_label != null ? var.oauth_2leg_bookmark_label : "${var.bookmark_label} - API Admin"
  bookmark_url                   = var.oauth_2leg_bookmark_url != null ? var.oauth_2leg_bookmark_url : var.bookmark_url
  bookmark_status                = var.bookmark_status
  bookmark_auto_submit_toolbar   = var.bookmark_auto_submit_toolbar
  bookmark_hide_ios              = var.bookmark_hide_ios
  bookmark_hide_web              = var.bookmark_hide_web
}
EOF
fi

# Add Web OIDC module if .tfvars exists
if [ "$WEB_OIDC_EXISTS" = true ]; then
    cat >> "$WORK_DIR/main.tf" << 'EOF'

# Web OIDC Module (Web Applications)
module "web_oidc" {
  source = "./modules/web_oidc"
  
  app_label                      = var.web_oidc_app_label != null ? var.web_oidc_app_label : "${var.app_label} - Web"
  redirect_uris                  = var.web_oidc_redirect_uris
  auto_submit_toolbar            = var.web_oidc_auto_submit_toolbar
  hide_ios                       = var.web_oidc_hide_ios
  hide_web                       = var.web_oidc_hide_web
  issuer_mode                    = var.web_oidc_issuer_mode
  pkce_required                  = var.web_oidc_pkce_required
  group_name                     = var.web_oidc_group_name != null ? var.web_oidc_group_name : "${var.group_name} - Web Access"
  group_description              = var.web_oidc_group_description != null ? var.web_oidc_group_description : "Web access group for ${var.app_name}"
  group_type                     = var.group_type
  trusted_origin_name            = var.web_oidc_trusted_origin_name != null ? var.web_oidc_trusted_origin_name : "${var.trusted_origin_name} - Web"
  trusted_origin_url             = var.web_oidc_trusted_origin_url != null ? var.web_oidc_trusted_origin_url : var.trusted_origin_url
  trusted_origin_scopes          = var.trusted_origin_scopes
  trusted_origin_status          = var.trusted_origin_status
  bookmark_label                 = var.web_oidc_bookmark_label != null ? var.web_oidc_bookmark_label : "${var.bookmark_label} - Web Admin"
  bookmark_url                   = var.web_oidc_bookmark_url != null ? var.web_oidc_bookmark_url : var.bookmark_url
  bookmark_status                = var.bookmark_status
  bookmark_auto_submit_toolbar   = var.bookmark_auto_submit_toolbar
  bookmark_hide_ios              = var.bookmark_hide_ios
  bookmark_hide_web              = var.bookmark_hide_web
}
EOF
fi

# Add Native OIDC module if .tfvars exists
if [ "$NA_OIDC_EXISTS" = true ]; then
    cat >> "$WORK_DIR/main.tf" << 'EOF'

# Native OIDC Module (Mobile/Native Applications)
module "na_oidc" {
  source = "./modules/na_oidc"
  
  app_label                      = var.na_oidc_app_label != null ? var.na_oidc_app_label : "${var.app_label} - Native"
  redirect_uris                  = var.na_oidc_redirect_uris
  auto_submit_toolbar            = var.na_oidc_auto_submit_toolbar
  hide_ios                       = var.na_oidc_hide_ios
  hide_web                       = var.na_oidc_hide_web
  issuer_mode                    = var.na_oidc_issuer_mode
  pkce_required                  = var.na_oidc_pkce_required
  group_name                     = var.na_oidc_group_name != null ? var.na_oidc_group_name : "${var.group_name} - Native Access"
  group_description              = var.na_oidc_group_description != null ? var.na_oidc_group_description : "Native access group for ${var.app_name}"
  group_type                     = var.group_type
  trusted_origin_name            = var.na_oidc_trusted_origin_name != null ? var.na_oidc_trusted_origin_name : "${var.trusted_origin_name} - Native"
  trusted_origin_url             = var.na_oidc_trusted_origin_url != null ? var.na_oidc_trusted_origin_url : var.trusted_origin_url
  trusted_origin_scopes          = var.trusted_origin_scopes
  trusted_origin_status          = var.trusted_origin_status
  bookmark_label                 = var.na_oidc_bookmark_label != null ? var.na_oidc_bookmark_label : "${var.bookmark_label} - Native Admin"
  bookmark_url                   = var.na_oidc_bookmark_url != null ? var.na_oidc_bookmark_url : var.bookmark_url
  bookmark_status                = var.bookmark_status
  bookmark_auto_submit_toolbar   = var.bookmark_auto_submit_toolbar
  bookmark_hide_ios              = var.bookmark_hide_ios
  bookmark_hide_web              = var.bookmark_hide_web
}
EOF
fi

# Add SPA OIDC module if .tfvars exists
if [ "$SPA_OIDC_EXISTS" = true ]; then
    cat >> "$WORK_DIR/main.tf" << 'EOF'

# SPA OIDC Module (Single Page Applications)
module "spa_oidc" {
  source = "./modules/spa_oidc"
  
  app_label                      = var.spa_oidc_app_label != null ? var.spa_oidc_app_label : "${var.app_label} - SPA"
  redirect_uris                  = var.spa_oidc_redirect_uris
  auto_submit_toolbar            = var.spa_oidc_auto_submit_toolbar
  hide_ios                       = var.spa_oidc_hide_ios
  hide_web                       = var.spa_oidc_hide_web
  issuer_mode                    = var.spa_oidc_issuer_mode
  group_name                     = var.spa_oidc_group_name != null ? var.spa_oidc_group_name : "${var.group_name} - SPA Access"
  group_description              = var.spa_oidc_group_description != null ? var.spa_oidc_group_description : "SPA access group for ${var.app_name}"
  group_type                     = var.group_type
  trusted_origin_name            = var.spa_oidc_trusted_origin_name != null ? var.spa_oidc_trusted_origin_name : "${var.trusted_origin_name} - SPA"
  trusted_origin_url             = var.spa_oidc_trusted_origin_url != null ? var.spa_oidc_trusted_origin_url : var.trusted_origin_url
  trusted_origin_scopes          = var.trusted_origin_scopes
  trusted_origin_status          = var.trusted_origin_status
  bookmark_label                 = var.spa_oidc_bookmark_label != null ? var.spa_oidc_bookmark_label : "${var.bookmark_label} - SPA Admin"
  bookmark_url                   = var.spa_oidc_bookmark_url != null ? var.spa_oidc_bookmark_url : var.bookmark_url
  bookmark_status                = var.bookmark_status
  bookmark_auto_submit_toolbar   = var.bookmark_auto_submit_toolbar
  bookmark_hide_ios              = var.bookmark_hide_ios
  bookmark_hide_web              = var.bookmark_hide_web
}
EOF
fi

# Add outputs section
cat >> "$WORK_DIR/main.tf" << 'EOF'

# Outputs
EOF

if [ "$OAUTH_2LEG_EXISTS" = true ]; then
    cat >> "$WORK_DIR/main.tf" << 'EOF'
output "oauth_2leg_app_id" {
  description = "OAuth 2-Leg application ID"
  value       = module.oauth_2leg.oauth_2leg_app_id
}

output "oauth_2leg_client_id" {
  description = "OAuth 2-Leg client ID"
  value       = module.oauth_2leg.oauth_2leg_client_id
}

output "oauth_2leg_group_id" {
  description = "OAuth 2-Leg group ID"
  value       = module.oauth_2leg.oauth_2leg_group_id
}
EOF
fi

if [ "$WEB_OIDC_EXISTS" = true ]; then
    cat >> "$WORK_DIR/main.tf" << 'EOF'
output "web_oidc_app_id" {
  description = "Web OIDC application ID"
  value       = module.web_oidc.web_oidc_app_id
}

output "web_oidc_client_id" {
  description = "Web OIDC client ID"
  value       = module.web_oidc.web_oidc_client_id
}

output "web_oidc_group_id" {
  description = "Web OIDC group ID"
  value       = module.web_oidc.web_oidc_group_id
}
EOF
fi

if [ "$NA_OIDC_EXISTS" = true ]; then
    cat >> "$WORK_DIR/main.tf" << 'EOF'
output "na_oidc_app_id" {
  description = "Native OIDC application ID"
  value       = module.na_oidc.na_oidc_app_id
}

output "na_oidc_client_id" {
  description = "Native OIDC client ID"
  value       = module.na_oidc.na_oidc_client_id
}

output "na_oidc_group_id" {
  description = "Native OIDC group ID"
  value       = module.na_oidc.na_oidc_group_id
}
EOF
fi

if [ "$SPA_OIDC_EXISTS" = true ]; then
    cat >> "$WORK_DIR/main.tf" << 'EOF'
output "spa_oidc_app_id" {
  description = "SPA OIDC application ID"
  value       = module.spa_oidc.spa_oidc_app_id
}

output "spa_oidc_client_id" {
  description = "SPA OIDC client ID"
  value       = module.spa_oidc.spa_oidc_client_id
}

output "spa_oidc_group_id" {
  description = "SPA OIDC group ID"
  value       = module.spa_oidc.spa_oidc_group_id
}
EOF
fi

# Copy .tfvars files to working directory
echo "Copying .tfvars files..."
cp "$APP_PATH"/*.tfvars "$WORK_DIR/"

echo "Generated Terraform configuration in: $WORK_DIR"
echo ""
echo "Modules created:"
if [ "$OAUTH_2LEG_EXISTS" = true ]; then echo "  - oauth_2leg (API Services)"; fi
if [ "$WEB_OIDC_EXISTS" = true ]; then echo "  - web_oidc (Web Applications)"; fi
if [ "$NA_OIDC_EXISTS" = true ]; then echo "  - na_oidc (Native/Mobile Applications)"; fi
if [ "$SPA_OIDC_EXISTS" = true ]; then echo "  - spa_oidc (Single Page Applications)"; fi
echo ""
echo "To deploy:"
echo "cd $WORK_DIR"
echo "terraform init"
echo "terraform plan"
echo "terraform apply" 