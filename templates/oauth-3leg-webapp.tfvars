# Template for 3-Leg OAuth Application (Web App Backend)
# This template is for web applications using authorization code flow only

# 3-Leg Web App Template Configuration

web = {
  # Core OAuth app config (always required)
  app = {
    label = "DIV1_APPNAME_WEB"
    client_id = "DIV1_APPNAME_WEB"
    token_endpoint_auth_method = "client_secret_basic"
    pkce_required = true
    login_mode = "DISABLED"
    type = "web"
    redirect_uris = [
      "https://appname.company.com/callback",
      "https://appname.company.com/logout"
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
    name = "DIV1_APPNAME_WEB_ACCESS_V1"
    description = "Access group for DIV1 APPNAME Web App"
  }
  
  # Trusted origin configuration (usually required)
  trusted_origin = {
    name = "DIV1_APPNAME_WEB_ORIGIN_V1"
    url = "https://appname.company.com"
    scopes = ["CORS", "REDIRECT"]
  }
  
  # Optional bookmark (can be null or omitted entirely for app limits)
  bookmark = null
} 