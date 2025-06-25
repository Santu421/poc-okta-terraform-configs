# Okta Terraform Automation Workflow

## Overview

This document describes the workflow for managing Okta applications using Terraform automation across two repositories:

1. **`poc-okta-terraform-configs`** (Ops Team) - Per-app configurations and YAML definitions
2. **`poc-okta-terraform-modules`** (Engineering Team) - Reusable Terraform modules

## Repository Structure

### Configs Repository (`poc-okta-terraform-configs`)
```
apps/
├── DIV1_ET_FINANCE_EXPENSE_TRACKER/
│   ├── app-config.yaml          # App configuration
│   ├── 2leg-api.tfvars          # Generated 2-leg OAuth config
│   └── 3leg-frontend.tfvars     # Generated 3-leg frontend config
├── DIV2_HR_EMPLOYEE_PORTAL/
│   └── app-config.yaml
└── ...
scripts/
├── validate-yaml-config.sh      # YAML validation
├── generate-terraform.sh        # .tfvars generation
└── deploy-app.sh               # Deployment script
```

### Modules Repository (`poc-okta-terraform-modules`)
```
modules/
├── oauth_2leg/                 # 2-leg OAuth module
├── spa_oidc/                   # 3-leg SPA OIDC module
├── web_oidc/                   # 3-leg Web OIDC module
├── na_oidc/                    # 3-leg Native OIDC module
├── okta_group/                 # Group management
├── okta_trusted_origin/        # Trusted origins
├── okta_app_bookmark/          # Bookmark apps
└── okta_app_group_assignment/  # Group assignments
```

## Naming Conventions

### Folder Naming
- **Pattern**: `DIVISIONNAME_CMDBSHORTNAME_APPNAME`
- **Division Names**: Must be one of `DIV1`, `DIV2`, `DIV3`, `DIV4`, `DIV5`, `DIV6`
- **CMDB Short Name**: Uppercase alphanumeric only
- **Example**: `DIV1_ET_FINANCE_EXPENSE_TRACKER`

### Okta App Naming
Based on division and CMDB short name:

| App Type | Naming Pattern | Example |
|----------|---------------|---------|
| 2-leg API | `DIVISIONNAME_CMDBNAME_API_SVCS` | `DIV1_ET_API_SVCS` |
| 3-leg Backend | `DIVISIONNAME_CMDBNAME_OIDC_WA` | `DIV1_ET_OIDC_WA` |
| 3-leg Native | `DIVISIONNAME_CMDBNAME_OIDC_NA` | `DIV1_ET_OIDC_NA` |
| 3-leg Frontend | `DIVISIONNAME_CMDBNAME_OIDC_SPA` | `DIV1_ET_OIDC_SPA` |
| SAML Dev | `DIVISIONNAME_CMDBNAME_SAML_DEV` | `DIV1_ET_SAML_DEV` |
| SAML SI | `DIVISIONNAME_CMDBNAME_SAML_SI` | `DIV1_ET_SAML_SI` |
| SAML QA | `DIVISIONNAME_CMDBNAME_SAML_QA` | `DIV1_ET_SAML_QA` |
| SAML UAT | `DIVISIONNAME_CMDBNAME_SAML_UAT` | `DIV1_ET_SAML_UAT` |
| SAML Prod | `DIVISIONNAME_CMDBNAME_SAML_PROD` | `DIV1_ET_SAML_PROD` |

### CMDB Short Name
- **Format**: Uppercase alphanumeric only
- **Purpose**: Short identifier for the application
- **Example**: `ET` for "Finance Expense Tracker"

## YAML Configuration Schema

### Required Fields
```yaml
cmdb_app_name: "Human-readable application name"
division_name: "DIV1"  # Must be one of DIV1-DIV6
cmdb_short_name: "ET"  # Uppercase alphanumeric only
point_of_contact_email: "team@company.com"
app_owner: "Team or person responsible"
onboarding_snow_request: "SNOWREQ123456"
```

### App Configuration
```yaml
app_config:
  create_2leg: true              # Client credentials flow
  create_3leg_frontend: true     # SPA with PKCE
  create_3leg_backend: false     # Web app with client secret
  create_3leg_native: false      # Native app with password grant
  create_saml: false             # Not implemented yet
  
  scopes:
    - "openid"
    - "profile"
    - "email"
  
  redirect_uris:
    - "https://app.company.com/callback"
    - "http://localhost:3000/callback"
  
  post_logout_uris:
    - "https://app.company.com/logout"
```

## Validation Layers

### Layer 1: YAML Validation (Ops Team)
**Script**: `scripts/validate-yaml-config.sh`

**Validates**:
- ✅ Folder naming matches `division_name_cmdb_short_name` from YAML
- ✅ Division name is one of `DIV1-DIV6`
- ✅ Required fields present (cmdb_app_name, division_name, cmdb_short_name, etc.)
- ✅ Email format validation
- ✅ CMDB short name format (uppercase alphanumeric)
- ✅ App configuration rules
- ✅ Only one 3-leg type enabled at a time
- ✅ SAML must be false (not implemented)
- ✅ At least one OAuth type enabled

### Layer 2: Terraform Validation (Engineering Team)
**Script**: `scripts/validate-tfvars-combination.sh`

**Validates**:
- ✅ Business rules on app type combinations
- ✅ Allowed grant types per app type
- ✅ Required fields in .tfvars files
- ✅ Terraform syntax validation

## Allowed App Type Combinations

| Combination | 2-leg | 3-leg Frontend | 3-leg Backend | 3-leg Native | Description |
|-------------|-------|----------------|---------------|--------------|-------------|
| API Only | ✅ | ❌ | ❌ | ❌ | Server-to-server API |
| Frontend Only | ❌ | ✅ | ❌ | ❌ | SPA application |
| Backend Only | ❌ | ❌ | ✅ | ❌ | Web application |
| Native Only | ❌ | ❌ | ❌ | ✅ | Mobile/desktop app |
| Hybrid API + Frontend | ✅ | ✅ | ❌ | ❌ | API + SPA frontend |
| Hybrid API + Backend | ✅ | ❌ | ✅ | ❌ | API + web backend |
| Hybrid API + Native | ✅ | ❌ | ❌ | ✅ | API + native app |

## Workflow Steps

### 1. App Creation (Ops Team)
```bash
# Create app folder with proper naming
mkdir apps/DIV1_NA_NEW_APP

# Create YAML configuration
cat > apps/DIV1_NA_NEW_APP/app-config.yaml << EOF
cmdb_app_name: "New Application"
division_name: "DIV1"
cmdb_short_name: "NA"
point_of_contact_email: "team@company.com"
app_owner: "Development Team"
onboarding_snow_request: "SNOWREQ123456"
app_config:
  create_2leg: true
  create_3leg_frontend: true
  create_3leg_backend: false
  create_3leg_native: false
  create_saml: false
  scopes: ["openid", "profile", "email"]
  redirect_uris: ["https://new-app.company.com/callback"]
  post_logout_uris: ["https://new-app.company.com/logout"]
EOF

# Validate configuration
./scripts/validate-yaml-config.sh apps/DIV1_NA_NEW_APP
```

### 2. .tfvars Generation (Ops Team)
```bash
# Generate .tfvars files from YAML
./scripts/validate-yaml-config.sh apps/DIV1_NA_NEW_APP

# This creates:
# - 2leg-api.tfvars (if create_2leg: true)
# - 3leg-frontend.tfvars (if create_3leg_frontend: true)
# - 3leg-backend.tfvars (if create_3leg_backend: true)
# - 3leg-native.tfvars (if create_3leg_native: true)
```

### 3. Terraform Generation (Engineering Team)
```bash
# Copy .tfvars to modules repo
cp apps/DIV1_NA_NEW_APP/*.tfvars ../poc-okta-terraform-modules/

# Generate Terraform configuration
./scripts/generate-terraform.sh

# This creates:
# - main.tf (calls appropriate modules)
# - modules/ (only for enabled app types)
```

### 4. Deployment (Engineering Team)
```bash
# Plan changes
terraform plan -var-file=2leg-api.tfvars -var-file=3leg-frontend.tfvars

# Apply changes (with approval)
terraform apply -var-file=2leg-api.tfvars -var-file=3leg-frontend.tfvars
```

## GitHub Actions Workflow

### Manual App Selection
```yaml
# .github/workflows/deploy-apps.yml
- name: List Available Apps
  run: ./scripts/list-apps.sh

- name: Select Apps to Deploy
  uses: actions/github-script@v6
  with:
    script: |
      // Manual selection interface
```

### Validation Gates
1. **YAML Validation**: Ensures proper configuration
2. **Terraform Plan**: Shows what will be created
3. **Manual Approval**: Requires human approval
4. **Terraform Apply**: Creates resources in Okta

## Future Enhancements

### SAML Support
- [ ] Implement SAML app modules
- [ ] Add SAML configuration to YAML schema
- [ ] Update validation rules
- [ ] Add environment-specific naming (DEV, SI, QA, UAT, PROD)

### Advanced Features
- [ ] Multi-environment support
- [ ] Automated testing
- [ ] Rollback capabilities
- [ ] Monitoring and alerting
- [ ] Cost optimization

## Troubleshooting

### Common Issues

1. **Invalid folder name**
   ```
   ❌ Invalid folder name: DIV1_FINANCE_EXPENSE_TRACKER
   Expected pattern: DIV1_ET_APPNAME
   YAML division_name: DIV1
   YAML cmdb_short_name: ET
   ```
   **Solution**: Rename folder to `DIV1_ET_FINANCE_EXPENSE_TRACKER`

2. **Invalid division name**
   ```
   ❌ division_name must be one of DIV1-DIV6: DIV7
   ```
   **Solution**: Use a valid division name

3. **Multiple 3-leg types enabled**
   ```
   ❌ Only one 3-leg app type can be enabled at a time
   ```
   **Solution**: Enable only one of frontend/backend/native

4. **Invalid CMDB short name**
   ```
   ❌ cmdb_short_name must be uppercase alphanumeric only: et
   ```
   **Solution**: Use uppercase alphanumeric only (e.g., "ET")

### Getting Help

- **Ops Team**: Contact for YAML configuration issues
- **Engineering Team**: Contact for Terraform/module issues
- **Documentation**: Check this file and README.md
- **Examples**: See `apps/DIV1_ET_FINANCE_EXPENSE_TRACKER/` for reference 