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
    grant_types = ["authorization_code", "client_credentials", "refresh_token"]
    response_types = ["code"]
    
    # Custom authorization groups (not Terraform defined - for profile storage)
    OKTA_AUTHZ_GROUPS = [
      "DIV1_DEVELOPERS",
      "DIV1_ADMINS"
    ]
    APP_AUTHZ_LDAP_GROUPS = [
      "LDAP_DIV1_DEVELOPERS",
      "LDAP_DIV1_TESTERS"
    ]
    APP_AUTHZ_SPAPP_GROUPS = [
      "SPAPP_DIV1_USERS",
      "SPAPP_DIV1_MANAGERS"
    ]
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