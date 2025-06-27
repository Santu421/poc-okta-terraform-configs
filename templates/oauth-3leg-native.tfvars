# Template for 3-Leg OAuth Application (Native Mobile/Desktop)
# This template is for native applications using authorization code flow

# 3-Leg Native App Template Configuration

na = {
  # Core OAuth app config (always required)
  app = {
    label = "DIV1_APPNAME_NATIVE"
    client_id = "DIV1_APPNAME_NATIVE"
    token_endpoint_auth_method = "client_secret_basic"
    pkce_required = true
    login_mode = "DISABLED"
    type = "native"
    redirect_uris = [
      "com.appname.app://callback",
      "com.appname.app://logout"
    ]
    auto_submit_toolbar = false
    hide_ios = true
    hide_web = true
    issuer_mode = "ORG_URL"
    status = "ACTIVE"
    grant_types = ["password", "refresh_token", "authorization_code"]
    response_types = ["code"]
  }
  
  # Group configuration (usually required)
  group = {
    name = "DIV1_APPNAME_NATIVE_ACCESS_V1"
    description = "Access group for DIV1 APPNAME Native App"
  }
  
  # Trusted origin configuration (usually required)
  trusted_origin = {
    name = "DIV1_APPNAME_NATIVE_ORIGIN_V1"
    url = "http://localhost:3003"
    scopes = ["CORS", "REDIRECT"]
  }
  
  # Optional bookmark (can be null or omitted entirely for app limits)
  bookmark = null
} 