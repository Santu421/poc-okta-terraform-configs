# Okta App Onboarding Workflow

This document describes the complete workflow for onboarding Okta applications with clear separation of responsibilities between Ops and Engineering teams.

## Team Responsibilities

### **Ops Team** (owns `poc-okta-terraform-configs`)
- Creates app folders with YAML configurations
- Runs validation scripts
- Generates .tfvars files
- Deploys applications using Terraform

### **Engineering Team** (owns `poc-okta-terraform-modules`)
- Maintains reusable Terraform modules
- Enforces business rules and validation
- Defines allowed app type combinations
- Ensures security and compliance

## Complete Workflow

### **Step 1: Ops Team - Create App Configuration**

1. **Create app folder** following naming convention:
   ```bash
   mkdir apps/DIVISIONNAME_APPNAME
   # Example: apps/FINANCE_EXPENSE_TRACKER
   ```

2. **Create YAML configuration** (`app-config.yaml`):
   ```yaml
   app_name: "FINANCE_EXPENSE_TRACKER"
   app_label: "Finance Expense Tracker"
   point_of_contact_email: "finance-team@company.com"
   app_owner: "Finance IT Team"
   onboarding_snow_request: "SNOWREQ123456"
   
   oauth_config:
     create_2leg: true
     create_3leg_frontend: true
     create_3leg_backend: false
     create_3leg_native: false
     create_saml: false
     scopes:
       - "openid"
       - "profile"
       - "email"
       - "finance:read"
       - "finance:write"
   ```

### **Step 2: Ops Team - Validate YAML Configuration**

```bash
# Validate YAML configuration and folder naming
./scripts/validate-yaml-config.sh apps/FINANCE_EXPENSE_TRACKER
```

**This validates:**
- ✅ Folder name follows `DIVISIONNAME_APPNAME` pattern
- ✅ Required fields: `app_name`, `app_label`, `point_of_contact_email`, `app_owner`, `onboarding_snow_request`
- ✅ Email format is valid
- ✅ Only one 3-leg app type is enabled
- ✅ At least one OAuth type is enabled
- ✅ SAML is false (not implemented)

### **Step 3: Ops Team - Generate .tfvars Files**

The validation script automatically generates .tfvars files for each enabled app type:

```bash
# Generated files:
apps/FINANCE_EXPENSE_TRACKER/
├── app-config.yaml
├── 2leg-api.tfvars          # Generated for 2-leg API
└── 3leg-frontend.tfvars     # Generated for 3-leg Frontend
```

### **Step 4: Engineering Team - Validate .tfvars Combinations**

```bash
# Validate .tfvars combinations (Engineering Team validation)
../poc-okta-terraform-modules/scripts/validate-tfvars-combination.sh apps/FINANCE_EXPENSE_TRACKER
```

**This validates business rules:**
- ✅ Only one 3-leg app type per application
- ✅ Allowed combinations:
  - `2-leg + 3-leg-frontend` (hybrid) ✅
  - `2-leg only` ✅
  - `3-leg-frontend only` ✅
  - `3-leg-backend only` ✅
  - `3-leg-native only` ✅
- ❌ Forbidden combinations:
  - `2-leg + 3-leg-backend` ❌
  - `2-leg + 3-leg-native` ❌
  - Multiple 3-leg types ❌

### **Step 5: Ops Team - Deploy Application**

```bash
# Generate Terraform configuration
./scripts/generate-terraform.sh apps/FINANCE_EXPENSE_TRACKER FINANCE_EXPENSE_TRACKER

# Deploy to Okta
cd generated/FINANCE_EXPENSE_TRACKER
terraform init
terraform plan
terraform apply
```

## Validation Rules Summary

### **Ops Team Validation (YAML Level)**
| Rule | Description |
|------|-------------|
| Folder Naming | Must follow `DIVISIONNAME_APPNAME` pattern |
| Required Fields | `app_name`, `app_label`, `point_of_contact_email`, `app_owner`, `onboarding_snow_request` |
| Email Format | Valid email address format |
| OAuth Types | Only one 3-leg type can be true |
| SAML | Must be false (not implemented) |
| Scopes | At least one OAuth type must be enabled |

### **Engineering Team Validation (.tfvars Level)**
| Rule | Description |
|------|-------------|
| App Combinations | Enforces business rules for app type combinations |
| File Structure | Validates .tfvars files have required fields |
| Business Logic | Prevents invalid combinations like `2-leg + 3-leg-backend` |

## Allowed App Type Combinations

| Combination | Description | Use Case |
|-------------|-------------|----------|
| `2-leg only` | API service | Server-to-server communication |
| `3-leg-frontend only` | SPA application | Browser-based applications |
| `3-leg-backend only` | Web application | Server-side web apps |
| `3-leg-native only` | Native application | Mobile/desktop apps |
| `2-leg + 3-leg-frontend` | Hybrid application | Full-stack applications |

## Example Workflows

### **Example 1: Simple SPA**
```bash
# Ops Team
mkdir apps/HR_EMPLOYEE_PORTAL
# Create app-config.yaml with create_3leg_frontend: true
./scripts/validate-yaml-config.sh apps/HR_EMPLOYEE_PORTAL

# Engineering Team
../poc-okta-terraform-modules/scripts/validate-tfvars-combination.sh apps/HR_EMPLOYEE_PORTAL

# Ops Team
./scripts/generate-terraform.sh apps/HR_EMPLOYEE_PORTAL HR_EMPLOYEE_PORTAL
cd generated/HR_EMPLOYEE_PORTAL && terraform apply
```

### **Example 2: Hybrid Application**
```bash
# Ops Team
mkdir apps/FINANCE_EXPENSE_TRACKER
# Create app-config.yaml with create_2leg: true, create_3leg_frontend: true
./scripts/validate-yaml-config.sh apps/FINANCE_EXPENSE_TRACKER

# Engineering Team
../poc-okta-terraform-modules/scripts/validate-tfvars-combination.sh apps/FINANCE_EXPENSE_TRACKER

# Ops Team
./scripts/generate-terraform.sh apps/FINANCE_EXPENSE_TRACKER FINANCE_EXPENSE_TRACKER
cd generated/FINANCE_EXPENSE_TRACKER && terraform apply
```

## Error Handling

### **Common Validation Errors**

1. **Invalid Folder Name**:
   ```
   ❌ Invalid folder name: my-app
   Must follow pattern: DIVISIONNAME_APPNAME (uppercase, underscores only)
   ```

2. **Invalid Email**:
   ```
   ❌ point_of_contact_email is not a valid email address: invalid-email
   ```

3. **Multiple 3-leg Types**:
   ```
   ❌ Only one 3-leg app type can be enabled at a time
   ```

4. **Invalid Combination**:
   ```
   ❌ Validation Failed: Invalid combination
   2-leg API cannot be combined with 3-leg Backend
   ```

## Security and Compliance

- **Separation of Concerns**: Ops team manages configurations, Engineering team enforces rules
- **Audit Trail**: Every app has SNOW request tracking
- **Contact Information**: Clear ownership and contact details for each app
- **Business Rules**: Engineering team prevents invalid app combinations
- **Validation**: Multiple layers of validation ensure compliance

## Troubleshooting

### **If YAML validation fails:**
1. Check folder naming convention
2. Ensure all required fields are present
3. Validate email format
4. Review OAuth configuration

### **If .tfvars validation fails:**
1. Check app type combinations
2. Ensure only allowed combinations are used
3. Contact Engineering team for rule clarification

### **If deployment fails:**
1. Check Okta API credentials
2. Verify app names don't conflict
3. Review Terraform logs for specific errors 