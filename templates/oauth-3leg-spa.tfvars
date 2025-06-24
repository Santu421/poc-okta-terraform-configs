# Template for 3-Leg OAuth Application (Frontend SPA)
# This template is for single-page applications using authorization code with PKCE only

# OAuth App Configuration
app_name = "{{APP_NAME}}"
app_label = "{{APP_LABEL}}"

# Grant Types for 3-leg (SPA) - Authorization Code only
grant_types = ["authorization_code", "refresh_token"]

# Redirect URIs for SPA
redirect_uris = [
  "{{REDIRECT_URI}}",
  "{{LOGOUT_REDIRECT_URI}}"
]

# Response Types for SPA
response_types = ["code"]

# Authentication method for SPA (PKCE is required, no client secret)
token_endpoint_auth_method = "none"
pkce_required = true

# App visibility settings - Visible to users
auto_submit_toolbar = false
hide_ios = false
hide_web = false

# Optional settings
issuer_mode = "ORG_URL"

# Group for SPA access
group_name = "{{GROUP_NAME}}"
group_description = "Access group for {{APP_LABEL}} SPA"

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