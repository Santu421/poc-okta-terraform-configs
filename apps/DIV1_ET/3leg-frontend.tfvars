# 3-leg Frontend Configuration for Finance Expense Tracker
app_name = "DIV1_ET_OIDC_SPA"
app_label = "DIV1_ET_OIDC_SPA"
grant_types = ["authorization_code", "refresh_token"]
redirect_uris = [
  "https://finance-expense.company.com/callback",
  "https://finance-expense.company.com/silent-renew",
  "https://finance-api.company.com/callback",
  "http://localhost:3000/callback",
  "com.company.finance://callback",
]
response_types = ["code"]
token_endpoint_auth_method = "none"

group_name = "DIV1_ET_SPA_ACCESS"
group_description = "Access group for Finance Expense Tracker Frontend"

trusted_origin_name = "DIV1_ET_SPA_ORIGIN"
trusted_origin_url = "https://div1-et.example.com"
trusted_origin_scopes = ["CORS", "REDIRECT"]

app_group_assignments = [
  {
    app_name = "DIV1_ET_OIDC_SPA"
    group_name = "DIV1_ET_SPA_ACCESS"
  }
]

bookmark_name = "DIV1_ET_SPA_BOOKMARK"
bookmark_label = "Finance Expense Tracker Frontend Admin"
bookmark_url = "https://div1-et.example.com"
