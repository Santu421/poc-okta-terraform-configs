# OAuth 2-Leg Module (API Services)
# This module creates OAuth applications for server-to-server API authentication

resource "okta_app_oauth" "oauth_2leg" {
  label                      = var.app_label
  type                       = "service"
  grant_types                = ["client_credentials"]
  redirect_uris              = []
  response_types             = []
  token_endpoint_auth_method = "client_secret_basic"
  auto_submit_toolbar        = var.auto_submit_toolbar
  hide_ios                   = var.hide_ios
  hide_web                   = var.hide_web
  issuer_mode                = var.issuer_mode
  pkce_required              = null

  lifecycle {
    ignore_changes = [groups]
  }
}

# Group for API access
resource "okta_group" "oauth_2leg_group" {
  name        = var.group_name
  description = var.group_description
  type        = var.group_type
}

# App-Group Assignment
resource "okta_app_group_assignment" "oauth_2leg_assignment" {
  app_id   = okta_app_oauth.oauth_2leg.id
  group_id = okta_group.oauth_2leg_group.id
}

# Trusted Origin (if needed for API endpoints)
resource "okta_trusted_origin" "oauth_2leg_origin" {
  name   = var.trusted_origin_name
  origin = var.trusted_origin_url
  scopes = var.trusted_origin_scopes
  status = var.trusted_origin_status
}

# Bookmark App (optional - for admin access)
resource "okta_app_bookmark" "oauth_2leg_bookmark" {
  label                = var.bookmark_label
  url                  = var.bookmark_url
  status               = var.bookmark_status
  auto_submit_toolbar  = var.bookmark_auto_submit_toolbar
  hide_ios             = var.bookmark_hide_ios
  hide_web             = var.bookmark_hide_web
} 