# 3-leg Frontend Configuration for XYZ Application (uat)
app_name = "DIV2_XYZ_OIDC_SPA_UAT"
app_label = "DIV2_XYZ_OIDC_SPA_UAT"
grant_types = ["authorization_code", "refresh_token"]
redirect_uris = [
]
response_types = ["code"]
token_endpoint_auth_method = "none"

group_name = "DIV2_XYZ_SPA_ACCESS_UAT"
group_description = "Access group for XYZ Application Frontend (uat)"

trusted_origin_name = "DIV2_XYZ_SPA_ORIGIN_UAT"
trusted_origin_url = "https://xyz-uat.example.com"
trusted_origin_scopes = ["CORS", "REDIRECT"]

app_group_assignments = [
  {
    app_name = "DIV2_XYZ_OIDC_SPA_UAT"
    group_name = "DIV2_XYZ_SPA_ACCESS_UAT"
  }
]

bookmark_name = "DIV2_XYZ_SPA_BOOKMARK_UAT"
bookmark_label = "XYZ Application Frontend Admin (uat)"
bookmark_url = "https://xyz-uat.example.com"
