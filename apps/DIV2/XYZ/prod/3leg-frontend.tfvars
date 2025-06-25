# 3-leg Frontend Configuration for XYZ Application (prod)
app_name = "DIV2_XYZ_OIDC_SPA_PROD"
app_label = "DIV2_XYZ_OIDC_SPA_PROD"
grant_types = ["authorization_code", "refresh_token"]
redirect_uris = [
  "https://xyz.company.com/callback",
  "https://xyz.company.com/silent-renew",
  "https://xyz-api.company.com/callback",
]
response_types = ["code"]
token_endpoint_auth_method = "none"

group_name = "DIV2_XYZ_SPA_ACCESS_PROD"
group_description = "Access group for XYZ Application Frontend (prod)"

trusted_origin_name = "DIV2_XYZ_SPA_ORIGIN_PROD"
trusted_origin_url = "https://xyz-prod.example.com"
trusted_origin_scopes = ["CORS", "REDIRECT"]

app_group_assignments = [
  {
    app_name = "DIV2_XYZ_OIDC_SPA_PROD"
    group_name = "DIV2_XYZ_SPA_ACCESS_PROD"
  }
]

bookmark_name = "DIV2_XYZ_SPA_BOOKMARK_PROD"
bookmark_label = "XYZ Application Frontend Admin (prod)"
bookmark_url = "https://xyz-prod.example.com"
