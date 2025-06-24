# Okta App Validation Scripts

This directory contains scripts for validating and enforcing OAuth grant type restrictions on deployed Okta applications.

## Overview

The validation system ensures that deployed applications only have the appropriate OAuth grant types based on their intended use case. This prevents security issues like:

- SPAs having client credentials (which could be exposed in browser)
- API services having authorization code (which requires user interaction)
- Web apps having unnecessary grant types

## Scripts

### 1. `validate-app-config.sh` - Single App Validation

Validates and optionally fixes a single application's OAuth configuration.

#### Usage

```bash
# Validate an app (read-only)
./scripts/validate-app-config.sh <app_name> <app_type>

# Validate with detailed output
./scripts/validate-app-config.sh <app_name> <app_type> --verbose

# See what would be changed (dry run)
./scripts/validate-app-config.sh <app_name> <app_type> --fix --dry-run

# Automatically fix violations
./scripts/validate-app-config.sh <app_name> <app_type> --fix
```

#### Examples

```bash
# Validate a 2-leg API service
./scripts/validate-app-config.sh my-api-service 2leg-api --verbose

# Fix violations in a SPA
./scripts/validate-app-config.sh my-spa-app 3leg-spa --fix

# Check what would be changed
./scripts/validate-app-config.sh my-web-app 3leg-webapp --fix --dry-run
```

### 2. `validate-all-apps.sh` - Bulk Validation

Validates all applications in your Okta organization against their expected configurations.

#### Usage

```bash
# Validate all apps (read-only)
./scripts/validate-all-apps.sh

# Validate with detailed output
./scripts/validate-all-apps.sh --verbose

# See what would be changed (dry run)
./scripts/validate-all-apps.sh --fix --dry-run

# Automatically fix all violations
./scripts/validate-all-apps.sh --fix

# Validate specific apps only
./scripts/validate-all-apps.sh --apps app1,app2,app3

# Create app type mapping file
./scripts/validate-all-apps.sh --create-mapping
```

#### Examples

```bash
# Check all apps without making changes
./scripts/validate-all-apps.sh --dry-run

# Fix all violations automatically
./scripts/validate-all-apps.sh --fix --verbose

# Validate only specific apps
./scripts/validate-all-apps.sh --apps my-api,my-spa,my-webapp
```

## App Types and Grant Type Restrictions

| App Type | Allowed Grant Types | Use Case |
|----------|-------------------|----------|
| `2leg-api` | `client_credentials` | Server-to-server API services |
| `3leg-spa` | `authorization_code`, `refresh_token` | Single Page Applications |
| `3leg-webapp` | `authorization_code`, `refresh_token` | Traditional web applications |
| `hybrid-spa-api` | `authorization_code`, `refresh_token`, `client_credentials` | Hybrid applications |

## Configuration

### Environment Variables

Set these environment variables before running the scripts:

```bash
export OKTA_ORG_URL="https://your-org.okta.com"
export OKTA_API_TOKEN="your-api-token"
```

### App Type Mapping

The bulk validation script uses an app type mapping file (`app-type-mapping.txt`) to determine the expected configuration for each app.

#### Creating the Mapping File

```bash
# Create initial mapping based on naming conventions
./scripts/validate-all-apps.sh --create-mapping
```

#### Manual Mapping File Format

Create a file named `app-type-mapping.txt` with the following format:

```
# App Type Mapping File
# Format: app_name=app_type

# API Services
my-api-service=2leg-api
internal-api=2leg-api

# SPAs
my-spa-app=3leg-spa
react-dashboard=3leg-spa

# Web Apps
my-web-app=3leg-webapp
admin-portal=3leg-webapp

# Hybrid Apps
my-hybrid-app=hybrid-spa-api
```

#### Naming Convention Rules

If no mapping file exists, the script uses these naming conventions:

- Apps ending with `-api` or `_api` → `2leg-api`
- Apps ending with `-spa` or `_spa` → `3leg-spa`
- Apps ending with `-web`, `_web`, or `-webapp` → `3leg-webapp`
- Apps ending with `-hybrid` or `_hybrid` → `hybrid-spa-api`
- All others → `3leg-webapp` (default)

## Security Benefits

### 1. **Prevents OAuth Misconfigurations**
- Ensures SPAs don't have client secrets (which could be exposed)
- Prevents API services from having unnecessary user interaction flows
- Maintains proper separation of concerns

### 2. **Enforces Security Best Practices**
- PKCE for SPAs (prevents authorization code interception)
- Client secrets only where needed (server-side applications)
- Proper token endpoint authentication methods

### 3. **Compliance and Auditing**
- Provides clear validation reports
- Documents expected vs. actual configurations
- Enables automated compliance checking

## Integration with CI/CD

### GitHub Actions Integration

Add this to your workflow:

```yaml
- name: Validate Okta Apps
  env:
    OKTA_ORG_URL: ${{ secrets.OKTA_ORG_URL }}
    OKTA_API_TOKEN: ${{ secrets.OKTA_API_TOKEN }}
  run: |
    ./scripts/validate-all-apps.sh --dry-run
```

### Azure DevOps Integration

Add this to your pipeline:

```yaml
- script: |
    ./scripts/validate-all-apps.sh --dry-run
  env:
    OKTA_ORG_URL: $(OKTA_ORG_URL)
    OKTA_API_TOKEN: $(OKTA_API_TOKEN)
  displayName: 'Validate Okta Apps'
```

## Troubleshooting

### Common Issues

1. **App Not Found**
   ```
   Error: App 'my-app' not found
   ```
   - Verify the app name exists in Okta
   - Check for typos in the app name

2. **Invalid App Type**
   ```
   Error: Unknown app type 'invalid-type'
   ```
   - Use one of: `2leg-api`, `3leg-spa`, `3leg-webapp`, `hybrid-spa-api`

3. **API Token Issues**
   ```
   Error: OKTA_API_TOKEN environment variable is required
   ```
   - Set the environment variable
   - Ensure the token has appropriate permissions

4. **Permission Denied**
   ```
   Error updating app: Insufficient permissions
   ```
   - Ensure the API token has app management permissions
   - Check that the token is valid and not expired

### Debug Mode

Use the `--verbose` flag for detailed output:

```bash
./scripts/validate-app-config.sh my-app 3leg-spa --verbose
```

This will show:
- Current app configuration
- Expected configuration
- Detailed validation results
- API responses (if fixing)

## Best Practices

1. **Run Validation Regularly**
   - Include in CI/CD pipelines
   - Schedule periodic checks
   - Validate after deployments

2. **Use Dry Run First**
   - Always test with `--dry-run` before fixing
   - Review proposed changes
   - Understand the impact

3. **Maintain Mapping File**
   - Keep app type mapping up to date
   - Document app purposes
   - Review mapping regularly

4. **Monitor Validation Results**
   - Track validation failures
   - Investigate unexpected configurations
   - Use results for security audits

## Example Workflow

```bash
# 1. Set up environment
export OKTA_ORG_URL="https://your-org.okta.com"
export OKTA_API_TOKEN="your-api-token"

# 2. Create app type mapping
./scripts/validate-all-apps.sh --create-mapping

# 3. Edit mapping file to ensure accuracy
vim app-type-mapping.txt

# 4. Run initial validation (dry run)
./scripts/validate-all-apps.sh --dry-run --verbose

# 5. Fix violations
./scripts/validate-all-apps.sh --fix

# 6. Verify fixes
./scripts/validate-all-apps.sh --verbose
``` 