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
  
  # Bookmark configuration with optional parameters for testing
  bookmark = {
    name = "DIV1_TEST_BOOKMARK"
    label = "DIV1 TEST Bookmark App"
    url = "https://test-bookmark.company.com"
    status = "ACTIVE"
    
    # Testing optional parameters
    admin_note = "Test admin note for DIV1 TEST bookmark app"
    enduser_note = "Test end user note for bookmark"
    hide_ios = true
    hide_web = false
    auto_submit_toolbar = true
    accessibility_self_service = true
    request_integration = false
    
    # Test timeouts
    timeouts = {
      create = "5m"
      read = "3m"
      update = "5m"
    }
  }
} 