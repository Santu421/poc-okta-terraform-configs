# 3-leg Frontend Configuration for Finance Expense Tracker
app_name = "FINANCE_EXPENSE_TRACKER-3leg-frontend"
app_label = "Finance Expense Tracker Frontend"
grant_types = ["authorization_code", "refresh_token"]
redirect_uris = [
  "https://FINANCE_EXPENSE_TRACKER.lower().replace('_', '-').example.com/callback",
  "https://FINANCE_EXPENSE_TRACKER.lower().replace('_', '-').example.com/logout"
]
response_types = ["code"]
token_endpoint_auth_method = "none"
pkce_required = true
auto_submit_toolbar = false
hide_ios = false
hide_web = false
issuer_mode = "ORG_URL"

group_name = "FINANCE_EXPENSE_TRACKER-3leg-frontend-access"
group_description = "Access group for Finance Expense Tracker Frontend"

trusted_origin_name = "FINANCE_EXPENSE_TRACKER-3leg-frontend-origin"
trusted_origin_url = "https://FINANCE_EXPENSE_TRACKER.lower().replace('_', '-').example.com"
trusted_origin_scopes = ["CORS", "REDIRECT"]

app_group_assignments = [
  {
    app_name = "FINANCE_EXPENSE_TRACKER-3leg-frontend"
    group_name = "FINANCE_EXPENSE_TRACKER-3leg-frontend-access"
  }
]

bookmark_name = "FINANCE_EXPENSE_TRACKER-3leg-frontend-bookmark"
bookmark_label = "Finance Expense Tracker Frontend Admin"
bookmark_url = "https://FINANCE_EXPENSE_TRACKER.lower().replace('_', '-').example.com"
