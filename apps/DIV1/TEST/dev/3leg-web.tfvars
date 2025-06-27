# 3-Leg Web OIDC Configuration for TEST App

web = {
  # Web App Configuration
  label = "DIV1_TEST_WEB"

  # OAuth App Configuration
  token_endpoint_auth_method = "client_secret_basic"
  pkce_required = true
  login_mode = "DISABLED"
  client_id = "DIV1_TEST_WEB"
  type = "web"

  # Redirect URIs for Web app
  redirect_uris = [
    "https://test-web-app.company.com/callback",
    "https://test-web-app.company.com/logout"
  ]

  # App visibility settings
  auto_submit_toolbar = false
  hide_ios = true
  hide_web = true

  # Optional settings
  issuer_mode = "ORG_URL"
  status = "ACTIVE"
  grant_types = ["authorization_code", "refresh_token", "client_credentials"]
  response_types = ["code"]

  # Group for Web app access
  group_name = "DIV1_TEST_WEB_ACCESS_V1"
  group_description = "Access group for DIV1 TEST Web App"

  # Trusted Origin for Web app
  trusted_origin_name = "DIV1_TEST_WEB_ORIGIN_V1"
  trusted_origin_url = "https://test-web-app.company.com"
  trusted_origin_scopes = ["CORS", "REDIRECT"]

  # Bookmark App (optional - for admin access) - COMMENTED OUT TO STAY WITHIN 5-APP LIMIT
  # bookmark_label = "DIV1_TEST_WEB"
  # bookmark_url = "https://test-web-app.company.com"
  # bookmark_status = "ACTIVE"
  # bookmark_auto_submit_toolbar = false
  # bookmark_hide_ios = false
  # bookmark_hide_web = false
} 