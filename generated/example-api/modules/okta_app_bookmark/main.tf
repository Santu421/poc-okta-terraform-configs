resource "okta_app_bookmark" "this" {
  label  = var.bookmark.label
  url    = var.bookmark.url
  status = var.bookmark.status

  # Optional attributes - only set if provided
  auto_submit_toolbar = try(var.bookmark.auto_submit_toolbar, null)
  hide_ios           = try(var.bookmark.hide_ios, null)
  hide_web           = try(var.bookmark.hide_web, null)
  logo_url           = try(var.bookmark.logo_url, null)
  request_integration = try(var.bookmark.request_integration, null)
} 