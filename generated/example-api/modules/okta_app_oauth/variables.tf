variable "app" {
  description = "OAuth application configuration"
  type = object({
    name         = string
    label        = string
    grant_types  = list(string)
    redirect_uris = list(string)
    response_types = list(string)
    
    # Optional attributes
    token_endpoint_auth_method = optional(string)
    auto_submit_toolbar        = optional(bool)
    hide_ios                   = optional(bool)
    hide_web                   = optional(bool)
    issuer_mode                = optional(string)
    login_uri                  = optional(string)
    login_uri_redirect         = optional(bool)
    logout_uri                 = optional(string)
    post_logout_redirect_uri   = optional(string)
    profile_editable           = optional(bool)
    refresh_token_leeway       = optional(number)
    refresh_token_rotation     = optional(string)
    client_secret              = optional(string)
    client_id                  = optional(string)
    pkce_required              = optional(bool)
    wildcard_redirect          = optional(string)
    
    # Accessibility attributes
    accessibility_error_redirect_url = optional(string)
    accessibility_login_redirect_url = optional(string)
    accessibility_self_service       = optional(bool)
  })
  
  validation {
    condition = contains(["client_secret_basic", "client_secret_post", "client_secret_jwt", "private_key_jwt", "none"], var.app.token_endpoint_auth_method) || var.app.token_endpoint_auth_method == null
    error_message = "token_endpoint_auth_method must be one of: client_secret_basic, client_secret_post, client_secret_jwt, private_key_jwt, none"
  }
  
  validation {
    condition = contains(["ORG_URL", "CUSTOM_URL"], var.app.issuer_mode) || var.app.issuer_mode == null
    error_message = "issuer_mode must be one of: ORG_URL, CUSTOM_URL"
  }
  
  validation {
    condition = contains(["ROTATE", "STATIC"], var.app.refresh_token_rotation) || var.app.refresh_token_rotation == null
    error_message = "refresh_token_rotation must be one of: ROTATE, STATIC"
  }
} 