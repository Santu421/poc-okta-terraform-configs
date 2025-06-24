# Template for 2-Leg OAuth Application (API Services)
# This template is for server-to-server API authentication using client credentials flow only

# OAuth App Configuration
app_name = "{{APP_NAME}}"
app_label = "{{APP_LABEL}}"

# Grant Types for 2-leg (API Services) - Client Credentials only
grant_types = ["client_credentials"]

# No redirect URIs needed for client credentials flow
redirect_uris = []

# No response types needed for client credentials flow
response_types = []

# Authentication method for API services
token_endpoint_auth_method = "client_secret_basic"

# App visibility settings - Hidden from users since it's server-to-server
auto_submit_toolbar = false
hide_ios = true
hide_web = true

# Optional settings
issuer_mode = "ORG_URL"
pkce_required = null

# Group for API access
group_name = "{{GROUP_NAME}}"
group_description = "Access group for {{APP_LABEL}} API"

# Trusted Origin (if needed for API endpoints)
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