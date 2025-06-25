# 2-leg API Configuration for Finance Expense Tracker
app_name = "DIV1"_"ET"_API_SVCS
app_label = "DIV1"_"ET"_API_SVCS
grant_types = ["client_credentials"]
redirect_uris = []
response_types = []
token_endpoint_auth_method = "client_secret_basic"
auto_submit_toolbar = false
hide_ios = true
hide_web = true
issuer_mode = "ORG_URL"
pkce_required = null

group_name = "DIV1"_"ET"_API_ACCESS
group_description = "Access group for Finance Expense Tracker API"

trusted_origin_name = "null"
trusted_origin_url = "null"
trusted_origin_scopes = null

app_group_assignments = [
  {
    app_name = "DIV1"_"ET"_API_SVCS
    group_name = "DIV1"_"ET"_API_ACCESS
  }
]

bookmark_name = "null"
bookmark_label = "null"
bookmark_url = "null"
