# 3-Leg Web OIDC Configuration for TEST App

web = {
  # Core OAuth app config (always required)
  app = {
    label = "DIV1_TEST_WEB"
    client_id = "DIV1_TEST_WEB"
    token_endpoint_auth_method = "client_secret_basic"
    pkce_required = true
    login_mode = "DISABLED"
    type = "web"
    redirect_uris = [
      "https://test-web-app.company.com/callback",
      "https://test-web-app.company.com/logout"
    ]
    auto_submit_toolbar = false
    hide_ios = true
    hide_web = true
    issuer_mode = "ORG_URL"
    status = "ACTIVE"
    grant_types = ["authorization_code", "refresh_token", "client_credentials"]
    response_types = ["code"]
  }
  
  # Group configuration (usually required)
  group = {
    name = "DIV1_TEST_WEB_ACCESS_V1"
    description = "Access group for DIV1 TEST Web App"
  }
  
  # Trusted origin configuration (usually required)
  trusted_origin = {
    name = "DIV1_TEST_WEB_ORIGIN_V2"
    url = "https://test-web-app-v2.company.com"
    scopes = ["CORS", "REDIRECT"]
  }
  
  # Optional bookmark (can be null or omitted entirely for app limits)
  bookmark = null
} 