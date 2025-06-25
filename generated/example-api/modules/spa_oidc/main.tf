# SPA OIDC Module (Single Page Applications)
# This module creates OAuth applications for single page applications with PKCE

resource "okta_app_oauth" "spa_oidc" {
  label                      = var.app_label
  type                       = "browser"
  grant_types                = ["authorization_code", "refresh_token"]
  redirect_uris              = var.redirect_uris
  response_types             = ["code"]
  token_endpoint_auth_method = "none"
  auto_submit_toolbar        = var.auto_submit_toolbar
  hide_ios                   = var.hide_ios
  hide_web                   = var.hide_web
  issuer_mode                = var.issuer_mode
  pkce_required              = "REQUIRED"

  lifecycle {
    ignore_changes = [groups]
  }
}

# Group for SPA access
resource "okta_group" "spa_oidc_group" {
  name        = var.group_name
  description = var.group_description
  type        = var.group_type
}

# App-Group Assignment
resource "okta_app_group_assignment" "spa_oidc_assignment" {
  app_id   = okta_app_oauth.spa_oidc.id
  group_id = okta_group.spa_oidc_group.id
}

# Trusted Origin for SPA
resource "okta_trusted_origin" "spa_oidc_origin" {
  name   = var.trusted_origin_name
  origin = var.trusted_origin_url
  scopes = var.trusted_origin_scopes
  status = var.trusted_origin_status
}

# Bookmark App (optional - for admin access)
resource "okta_app_bookmark" "spa_oidc_bookmark" {
  label                = var.bookmark_label
  url                  = var.bookmark_url
  status               = var.bookmark_status
  auto_submit_toolbar  = var.bookmark_auto_submit_toolbar
  hide_ios             = var.bookmark_hide_ios
  hide_web             = var.bookmark_hide_web
} 