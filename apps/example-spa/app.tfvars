# Template for 3-Leg OAuth Application (Frontend SPA)
# This template is for single-page applications using authorization code with PKCE

# OAuth App Configuration
app_name = "example-spa"
app_label = "Example SPA App"

# Grant Types for 3-leg (SPA)
grant_types = ["authorization_code", "refresh_token"]

# Redirect URIs for SPA
redirect_uris = [
  "https://spa.example.com/callback",
  "https://example-spa.example.com/logout"
]

# Response Types for SPA
response_types = ["code"]

# Authentication method for SPA (PKCE is required)
token_endpoint_auth_method = "none"
pkce_required = true

# App visibility settings
auto_submit_toolbar = false
hide_ios = false
hide_web = false

# Optional settings
issuer_mode = "ORG_URL"

# Group for SPA access
group_name = "example-spa-access"
group_description = "Access group for Example SPA App SPA"

# Trusted Origin for SPA
trusted_origin_name = "example-spa-origin"
trusted_origin_url = "https://spa.example.com"
trusted_origin_scopes = ["CORS", "REDIRECT"]

# App-Group Assignments
app_group_assignments = [
  {
    app_name = "example-spa"
    group_name = "example-spa-access"
  }
]

# Bookmark App (optional - for admin access)
bookmark_name = "example-spa-bookmark"
bookmark_label = "Example SPA App Admin"
bookmark_url = "https://example-spa.example.com" 