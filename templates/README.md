# OAuth Application Templates

This directory contains templated configurations for different types of OAuth applications in Okta. These templates provide standardized configurations for common OAuth patterns.

## Template Types

### 1. **2-Leg OAuth (API Services)** - `oauth-2leg-api.tfvars`
**Use Case**: Server-to-server API authentication
- **Grant Type**: `client_credentials`
- **Authentication**: `client_secret_basic`
- **Flow**: No user interaction, direct API access
- **Best For**: Microservices, API gateways, backend services

**Key Features**:
- No redirect URIs needed
- Client secret authentication
- Hidden from user portal
- Ideal for machine-to-machine communication

### 2. **3-Leg OAuth (Frontend SPA)** - `oauth-3leg-spa.tfvars`
**Use Case**: Single Page Applications
- **Grant Type**: `authorization_code`, `refresh_token`
- **Authentication**: `none` (PKCE required)
- **Flow**: User authorization with PKCE
- **Best For**: React, Angular, Vue.js applications

**Key Features**:
- PKCE (Proof Key for Code Exchange) required
- No client secret (public client)
- Refresh token support
- Secure for browser-based applications

### 3. **3-Leg OAuth (Web App Backend)** - `oauth-3leg-webapp.tfvars`
**Use Case**: Traditional web applications
- **Grant Type**: `authorization_code`, `refresh_token`
- **Authentication**: `client_secret_basic`
- **Flow**: User authorization with client secret
- **Best For**: Server-side web applications

**Key Features**:
- Client secret authentication
- Refresh token support
- Secure server-side token handling
- Traditional web application pattern

## Usage

### Quick Start

Generate a new application configuration using the template script:

```bash
# Generate a 2-leg API service
./scripts/generate-app-from-template.sh 2leg-api my-api "My API Service"

# Generate a 3-leg SPA
./scripts/generate-app-from-template.sh 3leg-spa my-spa "My SPA App" \
  --redirect-uri https://app.example.com/callback \
  --trusted-origin-url https://app.example.com

# Generate a 3-leg web app
./scripts/generate-app-from-template.sh 3leg-webapp my-webapp "My Web App" \
  --redirect-uri https://app.example.com/callback \
  --trusted-origin-url https://app.example.com
```

### Template Variables

All templates use the following placeholder variables:

| Variable | Description | Example |
|----------|-------------|---------|
| `{{APP_NAME}}` | Application name (internal) | `my-api-service` |
| `{{APP_LABEL}}` | Application display name | `My API Service` |
| `{{GROUP_NAME}}` | Access group name | `my-api-service-access` |
| `{{TRUSTED_ORIGIN_NAME}}` | Trusted origin name | `my-api-service-origin` |
| `{{TRUSTED_ORIGIN_URL}}` | Trusted origin URL | `https://api.example.com` |
| `{{REDIRECT_URI}}` | OAuth redirect URI | `https://app.example.com/callback` |
| `{{LOGOUT_REDIRECT_URI}}` | Logout redirect URI | `https://app.example.com/logout` |
| `{{BOOKMARK_NAME}}` | Bookmark app name | `my-api-service-bookmark` |
| `{{BOOKMARK_LABEL}}` | Bookmark display name | `My API Service Admin` |
| `{{BOOKMARK_URL}}` | Bookmark URL | `https://admin.example.com` |

## OAuth Flow Comparison

| Aspect | 2-Leg API | 3-Leg SPA | 3-Leg Web App |
|--------|-----------|-----------|---------------|
| **User Interaction** | None | Required | Required |
| **Client Secret** | Required | None | Required |
| **PKCE** | Not applicable | Required | Optional |
| **Refresh Tokens** | Not applicable | Supported | Supported |
| **Use Case** | Server-to-server | Browser apps | Server apps |
| **Security Level** | High | Medium | High |

## Security Considerations

### 2-Leg API Services
- ✅ Client secret provides strong authentication
- ✅ No user interaction reduces attack surface
- ⚠️ Client secret must be securely stored
- ⚠️ Limited to server-side use

### 3-Leg SPA Applications
- ✅ PKCE prevents authorization code interception
- ✅ No client secret in browser
- ⚠️ Tokens stored in browser (use secure storage)
- ⚠️ Vulnerable to XSS attacks

### 3-Leg Web Applications
- ✅ Client secret provides strong authentication
- ✅ Tokens stored server-side
- ⚠️ Client secret must be securely stored
- ⚠️ Requires server-side session management

## Deployment Workflow

1. **Generate Configuration**:
   ```bash
   ./scripts/generate-app-from-template.sh <template_type> <app_name> <app_label>
   ```

2. **Generate Terraform**:
   ```bash
   ./scripts/generate-terraform.sh apps/<app_name> <app_name>
   ```

3. **Deploy**:
   ```bash
   cd generated/<app_name>
   terraform init
   terraform plan
   terraform apply
   ```

## Customization

### Adding Custom Templates

1. Create a new template file: `templates/oauth-custom.tfvars`
2. Use placeholder variables: `{{VARIABLE_NAME}}`
3. Add template type to the script: `TEMPLATE_TYPES=("2leg-api" "3leg-spa" "3leg-webapp" "custom")`

### Modifying Existing Templates

Templates can be customized for your organization's needs:
- Add custom scopes
- Modify default settings
- Include organization-specific configurations
- Add additional resource types

## Best Practices

1. **Naming Convention**: Use consistent naming patterns
2. **Security**: Always use HTTPS for redirect URIs
3. **Scopes**: Limit scopes to minimum required permissions
4. **Groups**: Create specific access groups for each application
5. **Documentation**: Document custom configurations
6. **Testing**: Test templates in non-production environment first

## Troubleshooting

### Common Issues

1. **Template not found**: Ensure template file exists in `templates/` directory
2. **Invalid parameters**: Check required parameters are provided
3. **Permission errors**: Ensure script is executable (`chmod +x`)
4. **Terraform errors**: Validate generated configuration before deployment

### Validation

Use the validation script to check generated configurations:
```bash
./scripts/validate-config.sh apps/<app_name>
``` 