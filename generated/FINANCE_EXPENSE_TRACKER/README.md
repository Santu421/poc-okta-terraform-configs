# Okta Terraform Modules

This repository contains reusable Terraform modules for managing Okta resources.

## Modules

### Application Modules
- `okta_app_oauth` - OAuth/OIDC applications
- `okta_app_saml` - SAML applications  
- `okta_app_bookmark` - Bookmark applications

### Group & Assignment Modules
- `okta_group` - Okta groups
- `okta_app_group_assignment` - Assign groups to applications
- `okta_app_user_assignment` - Assign users to applications

### Policy Modules
- `okta_policy_signon` - Sign-on policies
- `okta_policy_rule_signon` - Sign-on policy rules

### Security Modules
- `okta_trusted_origin` - Trusted origins for CORS and redirects
- `okta_network_zone` - Network zones
- `okta_auth_server` - Authorization servers

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
  }
}
```

## Requirements

- Terraform >= 1.0
- Okta Provider >= 4.0

## Examples

See the `examples/` directory for usage examples.

## Contributing

1. Create a feature branch
2. Make your changes
3. Update documentation
4. Submit a pull request 