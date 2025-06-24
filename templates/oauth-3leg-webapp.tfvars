# Template for 3-Leg OAuth Application (Web App Backend)
# This template is for web applications using authorization code flow

# OAuth App Configuration
app_name = "{{APP_NAME}}"
app_label = "{{APP_LABEL}}"

# Grant Types for 3-leg (Web App)
grant_types = ["authorization_code", "refresh_token"]

# Redirect URIs for Web App
redirect_uris = [
  "{{REDIRECT_URI}}",
  "{{LOGOUT_REDIRECT_URI}}"
]

# Response Types for Web App
response_types = ["code"]

# Authentication method for Web App (client secret)
token_endpoint_auth_method = "client_secret_basic"
pkce_required = false

# App visibility settings
auto_submit_toolbar = false
hide_ios = false
hide_web = false

# Optional settings
issuer_mode = "ORG_URL"

# Group for Web App access
group_name = "{{GROUP_NAME}}"
group_description = "Access group for {{APP_LABEL}} Web App"

# Trusted Origin for Web App
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