# Okta OAuth App Module

This module creates an Okta OAuth/OIDC application.

## Usage

```hcl
module "okta_oauth_app" {
  source = "git::https://github.com/your-org/poc-okta-terraform-modules.git//modules/okta_app_oauth?ref=v1.0.0"
  
  app = {
    name         = "my-app"
    label        = "My OAuth App"
    grant_types  = ["authorization_code"]
    redirect_uris = ["https://my-app.example.com/callback"]
    response_types = ["code"]
    token_endpoint_auth_method = "client_secret_basic"
    auto_submit_toolbar = false
    hide_ios = false
    hide_web = false
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| okta | ~> 4.0 |

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|:--------:|
| app | OAuth application configuration | `object` | Yes |

### App Object

| Name | Description | Type | Required |
|------|-------------|------|:--------:|
| name | Application name (for reference) | `string` | Yes |
| label | Application label | `string` | Yes |
| grant_types | OAuth grant types | `list(string)` | Yes |
| redirect_uris | OAuth redirect URIs | `list(string)` | Yes |
| response_types | OAuth response types | `list(string)` | Yes |
| token_endpoint_auth_method | Token endpoint authentication method | `string` | No |
| auto_submit_toolbar | Auto submit toolbar | `bool` | No |
| hide_ios | Hide from iOS | `bool` | No |
| hide_web | Hide from web | `bool` | No |
| issuer_mode | Issuer mode | `string` | No |
| login_uri | Login URI | `string` | No |
| login_uri_redirect | Login URI redirect | `bool` | No |
| logout_uri | Logout URI | `string` | No |
| post_logout_redirect_uri | Post logout redirect URI | `string` | No |
| profile_editable | Profile editable | `bool` | No |
| refresh_token_leeway | Refresh token leeway | `number` | No |
| refresh_token_rotation | Refresh token rotation | `string` | No |
| client_secret | Client secret | `string` | No |
| client_id | Client ID | `string` | No |
| pkce_required | PKCE required | `bool` | No |
| wildcard_redirect | Wildcard redirect | `string` | No |
| accessibility_error_redirect_url | Accessibility error redirect URL | `string` | No |
| accessibility_login_redirect_url | Accessibility login redirect URL | `string` | No |
| accessibility_self_service | Accessibility self service | `bool` | No |

## Outputs

| Name | Description |
|------|-------------|
| app_id | The ID of the OAuth application |
| client_id | The OAuth client ID |
| client_secret | The OAuth client secret |
| app_name | The name of the OAuth application |
| app_label | The label of the OAuth application |

## Examples

### Basic OAuth App
```hcl
app = {
  name         = "basic-app"
  label        = "Basic OAuth App"
  grant_types  = ["authorization_code"]
  redirect_uris = ["https://basic-app.example.com/callback"]
  response_types = ["code"]
}
```

### Advanced OAuth App
```hcl
app = {
  name         = "advanced-app"
  label        = "Advanced OAuth App"
  grant_types  = ["authorization_code", "refresh_token"]
  redirect_uris = ["https://advanced-app.example.com/callback"]
  response_types = ["code"]
  token_endpoint_auth_method = "client_secret_basic"
  auto_submit_toolbar = false
  hide_ios = false
  hide_web = false
  issuer_mode = "ORG_URL"
  pkce_required = true
}
``` 