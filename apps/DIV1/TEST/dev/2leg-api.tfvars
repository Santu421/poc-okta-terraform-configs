# 2-Leg OAuth API Configuration for TEST App

oauth2 = {
  label = "DIV1_TEST_API_SVCS"
  client_id = "DIV1_TEST_API_SVCS"
  client_basic_secret = "test-secret-123"
  omit_secret = true
  type = "service"
  token_endpoint_auth_method = "client_secret_basic"
  pkce_required = false
  grant_types = ["client_credentials"]
  response_types = ["token"]
  hide_ios = true
  hide_web = true
  login_mode = "DISABLED"
  status = "ACTIVE"
}
