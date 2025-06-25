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

# Outputs
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
