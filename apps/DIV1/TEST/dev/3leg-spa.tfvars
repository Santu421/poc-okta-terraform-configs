# 3-Leg SPA Configuration for TEST App

spa = {
  # SPA App Configuration
  label = "DIV1_TEST_SPA"

  # OAuth App Configuration
  token_endpoint_auth_method = "none"
  pkce_required = true
  login_mode = "DISABLED"
  client_id = "DIV1_TEST_SPA"
  type = "browser"

  # Redirect URIs for SPA
  redirect_uris = [
    "http://localhost:3000/callback",
    "http://localhost:3000/logout"
  ]

  # App visibility settings - Hide from users since login_mode is DISABLED
  auto_submit_toolbar = false
  hide_ios = true
  hide_web = true

  # Optional settings
  issuer_mode = "ORG_URL"
  status = "ACTIVE"
  grant_types = ["authorization_code"]
  response_types = ["code"]

  # Group for SPA access
  group_name = "DIV1_TEST_SPA_ACCESS_V3"
  group_description = "Access group for DIV1 TEST SPA"

  # Trusted Origin for SPA (using a different port to avoid conflicts)
  trusted_origin_name = "DIV1_TEST_SPA_ORIGIN_V3"
  trusted_origin_url = "http://localhost:3002"
  trusted_origin_scopes = ["CORS", "REDIRECT"]

  # Bookmark App (optional - for admin access)
  bookmark_label = "DIV1_TEST_SPA"
  bookmark_url = "http://localhost:3002"
  bookmark_status = "ACTIVE"
  bookmark_auto_submit_toolbar = false
  bookmark_hide_ios = false
  bookmark_hide_web = false
} 