# Template for Hybrid OAuth Application (SPA + API)
# This template is for applications that need both user authentication (SPA) and API access (client credentials)

# OAuth App Configuration
app_name = "{{APP_NAME}}"
app_label = "{{APP_LABEL}}"

# Grant Types for Hybrid (SPA + API) - Both authorization code and client credentials
grant_types = ["authorization_code", "refresh_token", "client_credentials"]

# Redirect URIs for SPA functionality
redirect_uris = [
  "{{REDIRECT_URI}}",
  "{{LOGOUT_REDIRECT_URI}}"
]

# Response Types for SPA
response_types = ["code"]

# Authentication method - Client secret for API access, none for SPA
token_endpoint_auth_method = "client_secret_basic"
pkce_required = true

# App visibility settings - Visible to users for SPA, but also supports API access
auto_submit_toolbar = false
hide_ios = false
hide_web = false

# Optional settings
issuer_mode = "ORG_URL"

# Group for application access
group_name = "{{GROUP_NAME}}"
group_description = "Access group for {{APP_LABEL}} (SPA + API)"

# Trusted Origin for SPA
trusted_origin_name = "{{TRUSTED_ORIGIN_NAME}}"
trusted_origin_url = "{{TRUSTED_ORIGIN_URL}}"
trusted_origin_scopes = ["CORS", "REDIRECT"]

# App-Group Assignments
app_group_assignments = [
  {
    app_name = "{{APP_NAME}}"
    group_name = "{{GROUP_NAME}}"
  }
]

# Bookmark App (optional - for admin access)
bookmark_name = "{{BOOKMARK_NAME}}"
bookmark_label = "{{BOOKMARK_LABEL}}"
bookmark_url = "{{BOOKMARK_URL}}" 