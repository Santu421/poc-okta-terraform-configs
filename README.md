# Okta Terraform Configurations

This repository contains per-application Okta configurations managed by the Ops team. Each application is defined using YAML configuration files that are validated and converted to Terraform variables.

## Quick Start

### 1. Create Application Configuration

Create a folder following the naming convention: `DIVISIONNAME_CMDBSHORTNAME_APPNAME`

```bash
# Example: Create a finance expense tracker app for Division 1
mkdir apps/DIV1_ET_FINANCE_EXPENSE_TRACKER
```

**Naming Rules:**
- Division name must be one of: `DIV1`, `DIV2`, `DIV3`, `DIV4`, `DIV5`, `DIV6`
- CMDB short name should be uppercase alphanumeric (e.g., `ET`)
- App name should be descriptive and use underscores
- Example: `DIV1_ET_FINANCE_EXPENSE_TRACKER`

### 2. Create YAML Configuration

Create `app-config.yaml` in your app folder:

```yaml
cmdb_app_name: "Finance Expense Tracker"
division_name: "DIV1"
cmdb_short_name: "ET"  # Uppercase alphanumeric only
point_of_contact_email: "finance-team@company.com"
app_owner: "Finance IT Team"
onboarding_snow_request: "SNOWREQ123456"

app_config:
  create_2leg: true              # API service
  create_3leg_frontend: true     # SPA frontend
  create_3leg_backend: false     # Web backend
  create_3leg_native: false      # Native app
  create_saml: false             # Not implemented yet
  
  scopes:
    - "openid"
    - "profile"
    - "email"
    - "finance:read"
    - "finance:write"
  
  redirect_uris:
    - "https://finance-expense.company.com/callback"
    - "http://localhost:3000/callback"
  
  post_logout_uris:
    - "https://finance-expense.company.com/logout"

trusted_origins:
  - name: "Finance Frontend"
    url: "https://finance-expense.company.com"
    scopes: ["CORS", "REDIRECT"]

bookmarks:
  - name: "Finance Admin"
    label: "Finance Expense Tracker - Admin"
    url: "https://finance-expense.company.com/admin"
```

### 3. Validate and Generate

```bash
# Validate YAML configuration and generate .tfvars files
./scripts/validate-yaml-config.sh apps/DIV1_ET_FINANCE_EXPENSE_TRACKER
```

This will:
- ✅ Validate folder naming matches `division_name_cmdb_short_name` from YAML
- ✅ Validate YAML configuration
- ✅ Generate `.tfvars` files for enabled app types
- ✅ Create proper naming for Okta resources

### 4. Generated Files

The script generates these files based on your configuration:

```
apps/DIV1_ET_FINANCE_EXPENSE_TRACKER/
├── app-config.yaml          # Your configuration
├── 2leg-api.tfvars          # 2-leg API configuration
└── 3leg-frontend.tfvars     # 3-leg frontend configuration
```

## Naming Conventions

### Folder Naming
- **Pattern**: `DIVISIONNAME_CMDBSHORTNAME_APPNAME`
- **Division Names**: Must be one of `DIV1`, `DIV2`, `DIV3`, `DIV4`, `DIV5`, `DIV6`
- **CMDB Short Name**: Uppercase alphanumeric only
- **Example**: `DIV1_ET_FINANCE_EXPENSE_TRACKER`

### Okta App Names
Based on division and CMDB short name:

| App Type | Pattern | Example |
|----------|---------|---------|
| 2-leg API | `DIVISIONNAME_CMDBNAME_API_SVCS` | `DIV1_ET_API_SVCS` |
| 3-leg Backend | `DIVISIONNAME_CMDBNAME_OIDC_WA` | `DIV1_ET_OIDC_WA` |
| 3-leg Native | `DIVISIONNAME_CMDBNAME_OIDC_NA` | `DIV1_ET_OIDC_NA` |
| 3-leg Frontend | `DIVISIONNAME_CMDBNAME_OIDC_SPA` | `DIV1_ET_OIDC_SPA` |

### CMDB Short Name
- **Format**: Uppercase alphanumeric only
- **Purpose**: Short identifier for the application
- **Example**: `ET` for "Finance Expense Tracker"

## Validation Rules

### Folder Naming
- Must match pattern: `DIVISIONNAME_CMDBSHORTNAME_APPNAME`
- Division name in YAML must match folder prefix
- CMDB short name in YAML must match folder prefix
- Example: `DIV1_ET_FINANCE_EXPENSE_TRACKER`

### YAML Configuration
- ✅ Required fields: `cmdb_app_name`, `division_name`, `cmdb_short_name`, `point_of_contact_email`, `app_owner`, `onboarding_snow_request`
- ✅ Email format validation
- ✅ Division name: must be one of DIV1-DIV6
- ✅ CMDB short name: uppercase alphanumeric only
- ✅ Only one 3-leg type can be enabled at a time
- ✅ At least one OAuth type must be enabled
- ✅ SAML must be false (not implemented yet)

### Allowed Combinations
| Combination | 2-leg | 3-leg Frontend | 3-leg Backend | 3-leg Native |
|-------------|-------|----------------|---------------|--------------|
| API Only | ✅ | ❌ | ❌ | ❌ |
| Frontend Only | ❌ | ✅ | ❌ | ❌ |
| Backend Only | ❌ | ❌ | ✅ | ❌ |
| Native Only | ❌ | ❌ | ❌ | ✅ |
| API + Frontend | ✅ | ✅ | ❌ | ❌ |
| API + Backend | ✅ | ❌ | ✅ | ❌ |
| API + Native | ✅ | ❌ | ❌ | ✅ |

## Scripts

### `validate-yaml-config.sh`
Validates YAML configuration and generates `.tfvars` files.

```bash
./scripts/validate-yaml-config.sh apps/DIV1_ET_FINANCE_EXPENSE_TRACKER
```

### `validate-all-apps.sh`
Validates all applications in the `apps/` directory.

```bash
./scripts/validate-all-apps.sh
```

### `list-apps.sh`
Lists all available applications.

```bash
./scripts/list-apps.sh
```

## Examples

See `apps/DIV1_ET_FINANCE_EXPENSE_TRACKER/` for a complete example including:
- YAML configuration
- Generated `.tfvars` files
- Trusted origins and bookmarks

## Workflow

For complete workflow documentation, see [WORKFLOW.md](WORKFLOW.md).

## Troubleshooting

### Common Issues

1. **Invalid folder name**
   ```
   ❌ Invalid folder name: DIV1_FINANCE_EXPENSE_TRACKER
   Expected pattern: DIV1_ET_APPNAME
   YAML division_name: DIV1
   YAML cmdb_short_name: ET
   ```
   **Solution**: Rename to `DIV1_ET_FINANCE_EXPENSE_TRACKER`

2. **Invalid division name**
   ```
   ❌ division_name must be one of DIV1-DIV6: DIV7
   ```
   **Solution**: Use a valid division name (DIV1-DIV6)

3. **Invalid CMDB short name**
   ```
   ❌ cmdb_short_name must be uppercase alphanumeric only: et
   ```
   **Solution**: Use uppercase alphanumeric only (e.g., "ET")

4. **Multiple 3-leg types**
   ```
   ❌ Only one 3-leg app type can be enabled at a time
   ```
   **Solution**: Enable only one of frontend/backend/native

## Team Responsibilities

- **Ops Team**: Creates YAML configurations, validates, generates `.tfvars`
- **Engineering Team**: Maintains Terraform modules, enforces business rules

## Future Enhancements

- [ ] SAML app support
- [ ] Multi-environment support (DEV, SI, QA, UAT, PROD)
- [ ] Automated deployment pipelines
- [ ] Advanced validation rules

## Architecture

```
Pipeline Flow:
1. Checkout poc-okta-terraform-modules
2. Checkout poc-okta-terraform-configs  
3. Run shell script to:
   - Copy .tfvars content into module variables
   - Generate main.tf from templates
4. Run terraform plan/apply
```

## Structure

```
poc-okta-terraform-configs/
├── apps/                    # Per-app configurations
│   ├── app1/               # Each app gets its own folder
│   │   ├── app1.tfvars     # OAuth app configuration
│   │   ├── bookmark1.tfvars # Bookmark app configuration
│   │   ├── group1.tfvars   # Group configuration
│   │   ├── assignments.tfvars # App-group assignments
│   │   └── trusted_origin1.tfvars # Trusted origin
│   └── app2/
│       └── ...
├── scripts/                 # Build and deployment scripts
│   ├── generate-terraform.sh # Generates Terraform from .tfvars
│   └── deploy-app.sh        # Main deployment pipeline
├── shared/                  # Shared resources across apps
│   ├── groups/             # Common groups
│   ├── policies/           # Common policies
│   └── trusted_origins/    # Common trusted origins
├── environments/           # Environment-specific configurations
│   ├── dev/
│   ├── staging/
│   └── prod/
└── generated/              # Auto-generated Terraform files (created by pipeline)
```

## Usage

### Deploy a Single App

```bash
# Make scripts executable
chmod +x scripts/*.sh

# Deploy app1 to dev environment
./scripts/deploy-app.sh apps/app1 app1 dev plan
./scripts/deploy-app.sh apps/app1 app1 dev apply
```

### Manual Generation (for testing)

```bash
# Generate Terraform files without deploying
./scripts/generate-terraform.sh apps/app1 app1

# Navigate to generated directory
cd generated/app1

# Run Terraform manually
terraform init
terraform plan
terraform apply
```

## Configuration Format

### OAuth App (.tfvars)
```hcl
# OAuth App Configuration
app_name = "app1"
app_label = "My OAuth App"
grant_types = ["authorization_code"]
redirect_uris = ["https://app1.example.com/callback"]
response_types = ["code"]
token_endpoint_auth_method = "client_secret_basic"
auto_submit_toolbar = false
hide_ios = false
hide_web = false
issuer_mode = "ORG_URL"
pkce_required = true
```

### Bookmark App (.tfvars)
```hcl
# Bookmark App Configuration
bookmark_name = "bookmark1"
bookmark_label = "App1 Bookmark"
bookmark_url = "https://bookmark1.example.com"
bookmark_status = "ACTIVE"
auto_submit_toolbar = false
hide_ios = false
hide_web = false
```

### Group (.tfvars)
```hcl
# Group Configuration
group_name = "App1 Users"
group_description = "Users who have access to App1"
group_type = "OKTA_GROUP"
```

## Pipeline Features

- **Build-time Composition**: Configs are composed with modules at build time
- **Environment Support**: Different backends and configurations per environment
- **Isolation**: Each app is deployed independently
- **Automation**: Full pipeline from config to deployment
- **Version Control**: Modules are versioned and pinned

## Best Practices

1. **One folder per app** - Each app gets its own directory for isolation
2. **Simple .tfvars format** - No complex objects, just simple key-value pairs
3. **Shared resources** - Common groups, policies in shared/ directory
4. **Environment separation** - Use environments/ for different environments
5. **Pipeline automation** - Use scripts for consistent deployments

## Examples

See the `apps/app1/` directory for a complete example configuration.

## Adding a New App

1. Create a new folder: `apps/app2/`
2. Create .tfvars files for each resource type
3. Run the deployment script:
   ```bash
   ./scripts/deploy-app.sh apps/app2 app2 dev plan
   ``` 