# 3-Leg SPA Configuration for TEST App

spa = {
  # Core OAuth app config (always required)
  app = {
    label = "DIV1_TEST_SPA"
    client_id = "DIV1_TEST_SPA"
    token_endpoint_auth_method = "none"
    pkce_required = true
    login_mode = "DISABLED"
    type = "browser"
    redirect_uris = [
      "http://localhost:3000/callback",
      "http://localhost:3000/logout"
    ]
    auto_submit_toolbar = false
    hide_ios = true
    hide_web = true
    issuer_mode = "ORG_URL"
    status = "ACTIVE"
    grant_types = ["authorization_code"]
    response_types = ["code"]
  }
  
  # Group configuration (usually required)
  group = {
    name = "DIV1_TEST_SPA_ACCESS_V3"
    description = "Access group for DIV1 TEST SPA"
  }
  
  # Trusted origin configuration (usually required)
  trusted_origin = {
    name = "DIV1_TEST_SPA_ORIGIN_V4"
    url = "http://localhost:3004"
    scopes = ["CORS", "REDIRECT"]
  }
  
  # Optional bookmark (can be null or omitted entirely for app limits)
  bookmark = null
} 