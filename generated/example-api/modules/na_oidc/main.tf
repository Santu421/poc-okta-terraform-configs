# Native OIDC Module (Mobile/Native Applications)
# This module creates OAuth applications for native/mobile applications

resource "okta_app_oauth" "na_oidc" {
  label                      = var.app_label
  type                       = "native"
  grant_types                = ["password", "refresh_token", "authorization_code"]
  redirect_uris              = var.redirect_uris
  response_types             = ["code"]
  token_endpoint_auth_method = "client_secret_basic"
  auto_submit_toolbar        = var.auto_submit_toolbar
  hide_ios                   = var.hide_ios
  hide_web                   = var.hide_web
  issuer_mode                = var.issuer_mode
  pkce_required              = var.pkce_required

  lifecycle {
    ignore_changes = [groups]
  }
}

# Group for native app access
resource "okta_group" "na_oidc_group" {
  name        = var.group_name
  description = var.group_description
  type        = var.group_type
}

# App-Group Assignment
resource "okta_app_group_assignment" "na_oidc_assignment" {
  app_id   = okta_app_oauth.na_oidc.id
  group_id = okta_group.na_oidc_group.id
}

# Trusted Origin for native app
resource "okta_trusted_origin" "na_oidc_origin" {
  name   = var.trusted_origin_name
  origin = var.trusted_origin_url
  scopes = var.trusted_origin_scopes
  status = var.trusted_origin_status
}

# Bookmark App (optional - for admin access)
resource "okta_app_bookmark" "na_oidc_bookmark" {
  label                = var.bookmark_label
  url                  = var.bookmark_url
  status               = var.bookmark_status
  auto_submit_toolbar  = var.bookmark_auto_submit_toolbar
  hide_ios             = var.bookmark_hide_ios
  hide_web             = var.bookmark_hide_web
} 