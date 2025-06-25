# 2-leg API Configuration for Finance Expense Tracker
app_name = "FINANCE_EXPENSE_TRACKER-2leg"
app_label = "Finance Expense Tracker API"
grant_types = ["client_credentials"]
redirect_uris = []
response_types = []
token_endpoint_auth_method = "client_secret_basic"
auto_submit_toolbar = false
hide_ios = true
hide_web = true
issuer_mode = "ORG_URL"
pkce_required = null

group_name = "FINANCE_EXPENSE_TRACKER-2leg-access"
group_description = "Access group for Finance Expense Tracker API"

trusted_origin_name = "FINANCE_EXPENSE_TRACKER-2leg-origin"
trusted_origin_url = "https://api.FINANCE_EXPENSE_TRACKER.lower().replace('_', '-').example.com"
trusted_origin_scopes = ["CORS"]

app_group_assignments = [
  {
    app_name = "FINANCE_EXPENSE_TRACKER-2leg"
    group_name = "FINANCE_EXPENSE_TRACKER-2leg-access"
  }
]

bookmark_name = "FINANCE_EXPENSE_TRACKER-2leg-bookmark"
bookmark_label = "Finance Expense Tracker API Admin"
bookmark_url = "https://admin.FINANCE_EXPENSE_TRACKER.lower().replace('_', '-').example.com"
