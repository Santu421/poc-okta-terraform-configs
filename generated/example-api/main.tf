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


# Outputs
