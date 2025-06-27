# Template for 3-Leg OAuth Application (Frontend SPA)
# This template is for single-page applications using authorization code with PKCE only

# 3-Leg SPA Template Configuration

spa = {
  # Core OAuth app config (always required)
  app = {
    label = "DIV1_APPNAME_SPA"
    client_id = "DIV1_APPNAME_SPA"
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
    name = "DIV1_APPNAME_SPA_ACCESS_V1"
    description = "Access group for DIV1 APPNAME SPA"
  }
  
  # Trusted origin configuration (usually required)
  trusted_origin = {
    name = "DIV1_APPNAME_SPA_ORIGIN_V1"
    url = "http://localhost:3002"
    scopes = ["CORS", "REDIRECT"]
  }
  
  # Optional bookmark (can be null or omitted entirely for app limits)
  bookmark = null
} 