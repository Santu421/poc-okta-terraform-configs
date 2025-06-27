# 3-Leg Native OIDC Configuration for TEST App

na = {
  # Core OAuth app config (always required)
  app = {
    label = "DIV1_TEST_NATIVE"
    client_id = "DIV1_TEST_NATIVE"
    token_endpoint_auth_method = "client_secret_basic"
    pkce_required = true
    login_mode = "DISABLED"
    type = "native"
    redirect_uris = [
      "com.test.app://callback",
      "com.test.app://logout"
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
    name = "DIV1_TEST_NATIVE_ACCESS_V1"
    description = "Access group for DIV1 TEST Native App"
  }
  
  # Trusted origin configuration (usually required)
  trusted_origin = {
    name = "DIV1_TEST_NATIVE_ORIGIN_V2"
    url = "http://localhost:3005"
    scopes = ["CORS", "REDIRECT"]
  }
  
  # Optional bookmark (can be null or omitted entirely for app limits)
  bookmark = null
} 