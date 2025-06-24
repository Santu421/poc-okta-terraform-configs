# Template for 3-Leg OAuth Application (Native Mobile/Desktop)
# This template is for native applications using password grant type (Resource Owner Password Credentials)

# OAuth App Configuration
app_name = "{{APP_NAME}}"
app_label = "{{APP_LABEL}}"

# Grant Types for 3-leg (Native) - Password grant for native apps
grant_types = ["password", "refresh_token"]

# Redirect URIs for native apps (if needed for logout)
redirect_uris = [
  "{{LOGOUT_REDIRECT_URI}}"
]

# Response Types for Native (none for password grant)
response_types = []

# Authentication method for Native apps (client secret for server-side token exchange)
token_endpoint_auth_method = "client_secret_basic"
pkce_required = false

# App visibility settings - Visible to users
auto_submit_toolbar = false
hide_ios = false
hide_web = false

# Optional settings
issuer_mode = "ORG_URL"

# Group for Native app access
group_name = "{{GROUP_NAME}}"
group_description = "Access group for {{APP_LABEL}} Native App"

# Trusted Origin for Native app (if needed for web components)
trusted_origin_name = "{{TRUSTED_ORIGIN_NAME}}"
trusted_origin_url = "{{TRUSTED_ORIGIN_URL}}"
trusted_origin_scopes = ["CORS"]

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