# Okta Terraform Configurations

This repository contains metadata-driven Okta application configurations using YAML files and Terraform variables. The system supports multiple OAuth application types with centralized metadata management and environment-specific configurations.

## 🚀 Features

- **Metadata-Driven**: Centralized metadata at app level with environment-specific configs
- **Multi-App Types**: Support for 2-leg API, 3-leg SPA, Web, and Native applications
- **Environment Isolation**: Separate configurations for dev, uat, and prod environments
- **Object-Based Variables**: Clean `.tfvars` structure using `oauth2`, `spa`, `web`, and `na` objects
- **Conditional Resources**: Optional bookmark apps and other resources
- **Validation Scripts**: Comprehensive validation and generation tools
- **Template System**: Reusable templates for different application types

## 📁 Repository Structure

```
poc-okta-terraform-configs/
├── apps/                    # Application configurations
│   ├── DIV1/               # Division 1 applications
│   │   └── TEST/           # TEST application
│   │       ├── TEST-metadata.yaml    # App-level metadata
│   │       └── dev/        # Environment-specific configs
│   │           ├── TEST-dev.yaml     # Environment config
│   │           ├── 2leg-api.tfvars   # 2-leg API variables
│   │           ├── 3leg-spa.tfvars   # 3-leg SPA variables
│   │           ├── 3leg-web.tfvars   # 3-leg Web variables
│   │           └── 3leg-native.tfvars # 3-leg Native variables
│   └── DIV2/               # Division 2 applications
├── templates/               # Template files
│   ├── oauth-2leg-api.tfvars
│   ├── oauth-3leg-spa.tfvars
│   ├── oauth-3leg-webapp.tfvars
│   ├── oauth-3leg-native.tfvars
│   └── oauth-hybrid-spa-api.tfvars
├── scripts/                 # Validation and generation scripts
│   ├── validate-all-apps.sh
│   ├── validate-app-config.sh
│   ├── generate-app-from-template.sh
│   ├── generate-terraform.sh
│   └── list-apps.sh
├── app-config-schema.yaml   # YAML schema for validation
└── app-type-mapping.example.txt # App type mapping examples
```

## 🏗️ Application Structure

### Metadata File (`{app-name}-metadata.yaml`)
Located at the app level, contains shared metadata across all environments:

```yaml
parent_cmdb_name: "Complify Application"
division: "DIV1"
cmdb_app_short_name: "TEST"
team_dl: "div4-team@company.com"
requested_by: "aadyasri@company.com"
```

### Environment Configuration (`{app-name}-{environment}.yaml`)
Located in environment folders, defines which app types to create:

```yaml
app_config:
  create_2leg: true          # 2-leg API service
  create_3leg_frontend: true # 3-leg SPA frontend
  create_3leg_backend: true  # 3-leg Web backend
  create_3leg_native: true   # 3-leg Native app
```

## 📋 Quick Start

### 1. Create Application Structure

```bash
# Create division and app folders
mkdir -p apps/DIV1/MYAPP
mkdir -p apps/DIV1/MYAPP/dev
mkdir -p apps/DIV1/MYAPP/uat
mkdir -p apps/DIV1/MYAPP/prod
```

### 2. Create Metadata File

Create `apps/DIV1/MYAPP/MYAPP-metadata.yaml`:

```yaml
parent_cmdb_name: "My Application"
division: "DIV1"
cmdb_app_short_name: "MYAPP"
team_dl: "myapp-team@company.com"
requested_by: "developer@company.com"
```

### 3. Create Environment Configuration

Create `apps/DIV1/MYAPP/dev/MYAPP-dev.yaml`:

```yaml
app_config:
  create_2leg: true
  create_3leg_frontend: true
  create_3leg_backend: false
  create_3leg_native: false
```

### 4. Generate Application Variables

```bash
# Generate from templates
./scripts/generate-app-from-template.sh apps/DIV1/MYAPP dev

# Or create manually using templates as reference
cp templates/oauth-2leg-api.tfvars apps/DIV1/MYAPP/dev/2leg-api.tfvars
cp templates/oauth-3leg-spa.tfvars apps/DIV1/MYAPP/dev/3leg-spa.tfvars
```

### 5. Customize Variables

Edit the generated `.tfvars` files:

```hcl
# 2leg-api.tfvars
oauth2 = {
  label = "DIV1_MYAPP_API_SVCS"
  client_id = "DIV1_MYAPP_API_SVCS"
  token_endpoint_auth_method = "client_secret_basic"
  omit_secret = true
  login_mode = "DISABLED"
  hide_ios = true
  hide_web = true
}

# 3leg-spa.tfvars
spa = {
  label = "DIV1_MYAPP_SPA"
  client_id = "DIV1_MYAPP_SPA"
  token_endpoint_auth_method = "none"
  pkce_required = true
  redirect_uris = [
    "http://localhost:3000/callback",
    "http://localhost:3000/logout"
  ]
  group_name = "DIV1_MYAPP_SPA_ACCESS_V1"
  trusted_origin_name = "DIV1_MYAPP_SPA_ORIGIN_V1"
  trusted_origin_url = "http://localhost:3002"
  # Bookmark section commented out for app limits
  # bookmark_label = "DIV1_MYAPP_SPA"
  # bookmark_url = "http://localhost:3002"
}
```

### 6. Validate Configuration

```bash
# Validate specific app
./scripts/validate-app-config.sh apps/DIV1/MYAPP/dev/MYAPP-dev.yaml

# Validate all apps
./scripts/validate-all-apps.sh
```

## 🏷️ Naming Conventions

### Application Naming
- **Pattern**: `DIVISION_CMDB_SHORT_NAME`
- **Example**: `DIV1_TEST`, `DIV2_MYAPP`

### Okta Resource Naming
| Resource Type | Pattern | Example |
|---------------|---------|---------|
| 2-leg API | `DIVISION_CMDB_API_SVCS` | `DIV1_TEST_API_SVCS` |
| 3-leg SPA | `DIVISION_CMDB_SPA` | `DIV1_TEST_SPA` |
| 3-leg Web | `DIVISION_CMDB_WEB` | `DIV1_TEST_WEB` |
| 3-leg Native | `DIVISION_CMDB_NATIVE` | `DIV1_TEST_NATIVE` |
| Groups | `DIVISION_CMDB_ACCESS_V{VERSION}` | `DIV1_TEST_SPA_ACCESS_V3` |
| Trusted Origins | `DIVISION_CMDB_ORIGIN_V{VERSION}` | `DIV1_TEST_SPA_ORIGIN_V3` |

## 🔧 Variable Structure

### Object-Based Variables
Each application type uses object-based variables for clean organization:

#### 2-Leg API (`oauth2` object)
```hcl
oauth2 = {
  label = "DIV1_TEST_API_SVCS"
  client_id = "DIV1_TEST_API_SVCS"
  token_endpoint_auth_method = "client_secret_basic"
  omit_secret = true
  auto_key_rotation = true
  login_mode = "DISABLED"
  hide_ios = true
  hide_web = true
  issuer_mode = "ORG_URL"
  consent_method = "TRUSTED"
  status = "ACTIVE"
  grant_types = ["client_credentials"]
  response_types = ["token"]
}
```

#### 3-Leg SPA (`spa` object)
```hcl
spa = {
  label = "DIV1_TEST_SPA"
  client_id = "DIV1_TEST_SPA"
  token_endpoint_auth_method = "none"
  pkce_required = true
  redirect_uris = [
    "http://localhost:3000/callback",
    "http://localhost:3000/logout"
  ]
  group_name = "DIV1_TEST_SPA_ACCESS_V3"
  group_description = "Access group for DIV1 TEST SPA"
  trusted_origin_name = "DIV1_TEST_SPA_ORIGIN_V3"
  trusted_origin_url = "http://localhost:3002"
  trusted_origin_scopes = ["CORS", "REDIRECT"]
  # Optional bookmark (commented out for app limits)
  # bookmark_label = "DIV1_TEST_SPA"
  # bookmark_url = "http://localhost:3002"
  # bookmark_status = "ACTIVE"
}
```

#### 3-Leg Web (`web` object)
```hcl
web = {
  label = "DIV1_TEST_WEB"
  client_id = "DIV1_TEST_WEB"
  token_endpoint_auth_method = "client_secret_basic"
  pkce_required = true
  redirect_uris = [
    "https://test-web-app.company.com/callback",
    "https://test-web-app.company.com/logout"
  ]
  group_name = "DIV1_TEST_WEB_ACCESS_V1"
  group_description = "Access group for DIV1 TEST Web App"
  trusted_origin_name = "DIV1_TEST_WEB_ORIGIN_V1"
  trusted_origin_url = "https://test-web-app.company.com"
  trusted_origin_scopes = ["CORS", "REDIRECT"]
}
```

#### 3-Leg Native (`na` object)
```hcl
na = {
  label = "DIV1_TEST_NATIVE"
  client_id = "DIV1_TEST_NATIVE"
  token_endpoint_auth_method = "client_secret_basic"
  pkce_required = true
  redirect_uris = [
    "com.test.app://callback",
    "com.test.app://logout"
  ]
  group_name = "DIV1_TEST_NATIVE_ACCESS_V1"
  group_description = "Access group for DIV1 TEST Native App"
  trusted_origin_name = "DIV1_TEST_NATIVE_ORIGIN_V1"
  trusted_origin_url = "http://localhost:3003"
  trusted_origin_scopes = ["CORS", "REDIRECT"]
}
```

## 🛠️ Scripts

### Validation Scripts
```bash
# Validate all applications
./scripts/validate-all-apps.sh

# Validate specific app configuration
./scripts/validate-app-config.sh apps/DIV1/TEST/dev/TEST-dev.yaml

# Validate YAML and generate Terraform
./scripts/validate-yaml-and-generate-terraform.sh apps/DIV1/TEST/dev/TEST-dev.yaml
```

### Generation Scripts
```bash
# Generate app from template
./scripts/generate-app-from-template.sh apps/DIV1/MYAPP dev

# Generate Terraform from YAML
./scripts/generate-terraform.sh apps/DIV1/TEST/dev/TEST-dev.yaml

# List all applications
./scripts/list-apps.sh
```

### Deployment Scripts
```bash
# Deploy application
./scripts/deploy-app.sh apps/DIV1/TEST dev
```

## 📚 Templates

### Available Templates
- `oauth-2leg-api.tfvars` - 2-leg API service template
- `oauth-3leg-spa.tfvars` - 3-leg SPA template
- `oauth-3leg-webapp.tfvars` - 3-leg Web app template
- `oauth-3leg-native.tfvars` - 3-leg Native app template
- `oauth-hybrid-spa-api.tfvars` - Hybrid SPA + API template

### Using Templates
```bash
# Copy template to app directory
cp templates/oauth-3leg-spa.tfvars apps/DIV1/MYAPP/dev/3leg-spa.tfvars

# Edit the copied file with your specific values
# Update label, client_id, redirect_uris, etc.
```

## 🔍 Validation Rules

### Metadata Validation
- ✅ Required fields: `parent_cmdb_name`, `division`, `cmdb_app_short_name`, `team_dl`, `requested_by`
- ✅ Division format: Must be one of `DIV1`, `DIV2`, `DIV3`, `DIV4`, `DIV5`, `DIV6`
- ✅ CMDB short name: Uppercase alphanumeric only
- ✅ Email format validation for `team_dl` and `requested_by`

### Environment Configuration Validation
- ✅ At least one app type must be enabled
- ✅ Valid app types: `create_2leg`, `create_3leg_frontend`, `create_3leg_backend`, `create_3leg_native`
- ✅ Environment name must match folder structure

### Variable File Validation
- ✅ Required fields for each app type
- ✅ Valid OAuth settings (grant_types, response_types, etc.)
- ✅ Unique resource names across applications
- ✅ Valid URLs for redirect_uris and trusted origins

## 🚀 Deployment

### Complete Deployment Example
```bash
# Deploy all app types for TEST application
cd ../poc-okta-terraform-modules
terraform apply \
  -var-file="../poc-okta-terraform-configs/apps/DIV1/TEST/dev/2leg-api.tfvars" \
  -var-file="../poc-okta-terraform-configs/apps/DIV1/TEST/dev/3leg-spa.tfvars" \
  -var-file="../poc-okta-terraform-configs/apps/DIV1/TEST/dev/3leg-web.tfvars" \
  -var-file="../poc-okta-terraform-configs/apps/DIV1/TEST/dev/3leg-native.tfvars" \
  -var-file="vars/dev.tfvars" \
  -var="app_config_path=../poc-okta-terraform-configs/apps/DIV1/TEST" \
  -var="environment=dev" \
  -auto-approve
```

### Environment-Specific Deployment
```bash
# Development
terraform apply -var-file="vars/dev.tfvars" -var="environment=dev" ...

# UAT
terraform apply -var-file="vars/uat.tfvars" -var="environment=uat" ...

# Production
terraform apply -var-file="vars/prod.tfvars" -var="environment=prod" ...
```

## 🔒 Security Considerations

- **API Tokens**: Never commit API tokens to version control
- **Client Secrets**: Use `omit_secret = true` for public clients (SPA)
- **Environment Isolation**: Separate configurations per environment
- **Access Control**: Groups created automatically for access management
- **Validation**: All configurations validated before deployment

## 📝 Notes

- **App Limits**: Some Okta tenants have app limits (e.g., 5 apps for dev)
- **Bookmark Apps**: Can be disabled by commenting out bookmark sections
- **Metadata Path**: Must point to app directory, not environment directory
- **State Management**: Use separate state files per environment
- **Cleanup**: Always destroy resources before recreating to avoid conflicts

## 🔗 Related Repositories

- [poc-okta-terraform-modules](https://github.com/Santu421/poc-okta-terraform-modules) - Terraform modules for Okta resources

## 📖 Documentation

- [WORKFLOW.md](WORKFLOW.md) - Complete workflow documentation
- [Templates README](templates/README.md) - Template usage guide
- [Scripts README](scripts/README.md) - Script documentation 