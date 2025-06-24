# OAuth App Configuration
app_name = "app1"
app_label = "My OAuth App"
grant_types = ["authorization_code"]
redirect_uris = ["https://app1.example.com/callback"]
response_types = ["code"]
token_endpoint_auth_method = "client_secret_basic"
auto_submit_toolbar = false
hide_ios = false
hide_web = false
issuer_mode = "ORG_URL"
pkce_required = true 