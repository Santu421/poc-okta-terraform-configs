# 3-leg Frontend Configuration for XYZ Application (dev)
app_name = "DIV2_XYZ_OIDC_SPA_DEV"
app_label = "DIV2_XYZ_OIDC_SPA_DEV"
grant_types = ["authorization_code", "refresh_token"]
redirect_uris = [
  "http://localhost:3000/callback",
  "http://localhost:3000/silent-renew",
  "http://localhost:8080/callback",
]
response_types = ["code"]
token_endpoint_auth_method = "none"

group_name = "DIV2_XYZ_SPA_ACCESS_DEV"
group_description = "Access group for XYZ Application Frontend (dev)"

trusted_origin_name = "DIV2_XYZ_SPA_ORIGIN_DEV"
trusted_origin_url = "https://xyz-dev.example.com"
trusted_origin_scopes = ["CORS", "REDIRECT"]

app_group_assignments = [
  {
    app_name = "DIV2_XYZ_OIDC_SPA_DEV"
    group_name = "DIV2_XYZ_SPA_ACCESS_DEV"
  }
]

bookmark_name = "DIV2_XYZ_SPA_BOOKMARK_DEV"
bookmark_label = "XYZ Application Frontend Admin (dev)"
bookmark_url = "https://xyz-dev.example.com"
