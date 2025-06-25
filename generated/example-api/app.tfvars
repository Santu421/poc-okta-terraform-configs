# Template for 2-Leg OAuth Application (API Services)
# This template is for server-to-server API authentication using client credentials flow

# OAuth App Configuration
app_name = "example-api"
app_label = "Example API Service"

# Grant Types for 2-leg (API Services)
grant_types = ["client_credentials"]

# No redirect URIs needed for client credentials flow
redirect_uris = []

# No response types needed for client credentials flow
response_types = []

# Authentication method for API services
token_endpoint_auth_method = "client_secret_basic"

# App visibility settings
auto_submit_toolbar = false
hide_ios = true
hide_web = true

# Optional settings
issuer_mode = "ORG_URL"
pkce_required = null

# Group for API access
group_name = "example-api-access"
group_description = "Access group for Example API Service API"

# Trusted Origin (if needed for API endpoints)
trusted_origin_name = "example-api-origin"
trusted_origin_url = "https://example-api.example.com"
trusted_origin_scopes = ["CORS"]

# App-Group Assignments
app_group_assignments = [
  {
    app_name = "example-api"
    group_name = "example-api-access"
  }
]

# Bookmark App (optional - for admin access)
bookmark_name = "example-api-bookmark"
bookmark_label = "Example API Service Admin"
bookmark_url = "https://example-api.example.com" 