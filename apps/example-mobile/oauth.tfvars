app_name = "example-mobile"
app_label = "Example Mobile App"
grant_types = ["password", "refresh_token"]
response_types = []
token_endpoint_auth_method = "client_secret_basic"
pkce_required = false
auto_submit_toolbar = false
hide_ios = false
hide_web = false
issuer_mode = "ORG_URL"

redirect_uris = [
  "https://example-mobile.example.com/logout"
]

# Response Types for Native (none for password grant)
response_types = []

# Authentication method for Native apps (client secret for server-side token exchange)
token_endpoint_auth_method = "client_secret_basic"
pkce_required = false
