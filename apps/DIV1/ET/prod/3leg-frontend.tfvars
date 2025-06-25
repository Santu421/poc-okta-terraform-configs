# 3-leg Frontend Configuration for Finance Expense Tracker (prod)
app_name = "DIV1_ET_OIDC_SPA_PROD"
app_label = "DIV1_ET_OIDC_SPA_PROD"
grant_types = ["authorization_code", "refresh_token"]
redirect_uris = [
  "https://finance-expense.company.com/callback",
  "https://finance-expense.company.com/silent-renew",
  "https://finance-api.company.com/callback",
  "com.company.finance://callback",
]
response_types = ["code"]
token_endpoint_auth_method = "none"

group_name = "DIV1_ET_SPA_ACCESS_PROD"
group_description = "Access group for Finance Expense Tracker Frontend (prod)"

trusted_origin_name = "DIV1_ET_SPA_ORIGIN_PROD"
trusted_origin_url = "https://et-prod.example.com"
trusted_origin_scopes = ["CORS", "REDIRECT"]

app_group_assignments = [
  {
    app_name = "DIV1_ET_OIDC_SPA_PROD"
    group_name = "DIV1_ET_SPA_ACCESS_PROD"
  }
]

bookmark_name = "DIV1_ET_SPA_BOOKMARK_PROD"
bookmark_label = "Finance Expense Tracker Frontend Admin (prod)"
bookmark_url = "https://et-prod.example.com"
