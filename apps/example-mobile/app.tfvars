# Template for 3-Leg OAuth Application (Native Mobile/Desktop)
# This template is for native applications using password grant type (Resource Owner Password Credentials)

# OAuth App Configuration
app_name = "example-mobile"
app_label = "Example Mobile App"

# Grant Types for 3-leg (Native) - Password grant for native apps
grant_types = ["password", "refresh_token"]

# Redirect URIs for native apps (if needed for logout)
redirect_uris = [
  "https://example-mobile.example.com/logout"
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
group_name = "example-mobile-access"
group_description = "Access group for Example Mobile App Native App"

# Trusted Origin for Native app (if needed for web components)
trusted_origin_name = "example-mobile-origin"
trusted_origin_url = "https://api.example.com"
trusted_origin_scopes = ["CORS"]

# App-Group Assignments
app_group_assignments = [
  {
    app_name = "example-mobile"
    group_name = "example-mobile-access"
  }
]

# Bookmark App (optional - for admin access)
bookmark_name = "example-mobile-bookmark"
bookmark_label = "Example Mobile App Admin"
bookmark_url = "https://example-mobile.example.com" 