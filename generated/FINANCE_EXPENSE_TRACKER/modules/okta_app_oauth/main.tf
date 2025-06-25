resource "okta_app_oauth" "this" {
  label         = var.app.label
  grant_types   = var.app.grant_types
  redirect_uris = var.app.redirect_uris
  response_types = var.app.response_types

  # Optional attributes - only set if provided
  token_endpoint_auth_method = try(var.app.token_endpoint_auth_method, null)
  auto_submit_toolbar        = try(var.app.auto_submit_toolbar, null)
  hide_ios                   = try(var.app.hide_ios, null)
  hide_web                   = try(var.app.hide_web, null)
  issuer_mode                = try(var.app.issuer_mode, null)
  login_uri                  = try(var.app.login_uri, null)
  login_uri_redirect         = try(var.app.login_uri_redirect, null)
  logout_uri                 = try(var.app.logout_uri, null)
  post_logout_redirect_uri   = try(var.app.post_logout_redirect_uri, null)
  profile_editable           = try(var.app.profile_editable, null)
  refresh_token_leeway       = try(var.app.refresh_token_leeway, null)
  refresh_token_rotation     = try(var.app.refresh_token_rotation, null)
  client_secret              = try(var.app.client_secret, null)
  client_id                  = try(var.app.client_id, null)
  pkce_required              = try(var.app.pkce_required, null)
  wildcard_redirect          = try(var.app.wildcard_redirect, null)

  # Accessibility attributes
  accessibility_error_redirect_url = try(var.app.accessibility_error_redirect_url, null)
  accessibility_login_redirect_url = try(var.app.accessibility_login_redirect_url, null)
  accessibility_self_service       = try(var.app.accessibility_self_service, null)
} 