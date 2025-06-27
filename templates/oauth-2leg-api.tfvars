# Template for 2-Leg OAuth Application (API Services)
# This template is for server-to-server API authentication using client credentials flow only

# 2-Leg API Template Configuration

oauth2 = {
  # Core OAuth app config (always required)
  app = {
    label = "DIV1_APPNAME_API_SVCS"
    client_id = "DIV1_APPNAME_API_SVCS"
    token_endpoint_auth_method = "client_secret_basic"
    omit_secret = true
    auto_key_rotation = true
    login_mode = "DISABLED"
    hide_ios = true
    hide_web = true
    issuer_mode = "ORG_URL"
    consent_method = "TRUSTED"
    status = "ACTIVE"
    grant_types = ["client_credentials"]
    response_types = ["token"]
    type = "service"
    user_name_template = "${source.login}"
    user_name_template_type = "BUILT_IN"
    wildcard_redirect = "DISABLED"
  }
  
  # Optional group (can be null or omitted entirely)
  group = null
  
  # Optional trusted origin (can be null or omitted entirely)
  trusted_origin = null
  
  # Optional bookmark (can be null or omitted entirely)
  bookmark = null
} 