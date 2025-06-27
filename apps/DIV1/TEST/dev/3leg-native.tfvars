# 3-Leg Native OIDC Configuration for TEST App

na = {
  # Native App Configuration
  label = "DIV1_TEST_NATIVE"

  # OAuth App Configuration
  token_endpoint_auth_method = "client_secret_basic"
  pkce_required = true
  login_mode = "DISABLED"
  client_id = "DIV1_TEST_NATIVE"
  type = "native"

  # Redirect URIs for Native app
  redirect_uris = [
    "com.test.app://callback",
    "com.test.app://logout"
  ]

  # App visibility settings
  auto_submit_toolbar = false
  hide_ios = true
  hide_web = true

  # Optional settings
  issuer_mode = "ORG_URL"
  status = "ACTIVE"
  grant_types = ["password", "refresh_token", "authorization_code"]
  response_types = ["code"]

  # Group for Native app access
  group_name = "DIV1_TEST_NATIVE_ACCESS_V1"
  group_description = "Access group for DIV1 TEST Native App"

  # Trusted Origin for Native app
  trusted_origin_name = "DIV1_TEST_NATIVE_ORIGIN_V1"
  trusted_origin_url = "http://localhost:3003"
  trusted_origin_scopes = ["CORS", "REDIRECT"]

  # Bookmark App (optional - for admin access) - COMMENTED OUT TO STAY WITHIN 5-APP LIMIT
  # bookmark_label = "DIV1_TEST_NATIVE"
  # bookmark_url = "com.test.app://"
  # bookmark_status = "ACTIVE"
  # bookmark_auto_submit_toolbar = false
  # bookmark_hide_ios = false
  # bookmark_hide_web = false
} 