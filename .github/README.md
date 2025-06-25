# GitHub Actions Workflow for Okta App Deployment

This workflow provides a secure, automated way to deploy Okta applications with manual approval gates.

## 🚀 How to Deploy an App

### **Step 1: List Available Apps**
```bash
# Run this locally to see available apps
./scripts/list-apps.sh
```

### **Step 2: Trigger GitHub Actions Workflow**

1. **Go to GitHub Actions tab** in your repository
2. **Select "Deploy Okta App"** workflow
3. **Click "Run workflow"**
4. **Fill in the parameters:**
   - **App name**: Enter the exact app name (e.g., `FINANCE_EXPENSE_TRACKER`)
   - **Environment**: Choose `staging` or `production`
5. **Click "Run workflow"**

## 📋 Workflow Stages

### **Stage 1: Validate and Generate**
- ✅ Validates YAML configuration
- ✅ Generates `.tfvars` files
- ✅ Copies files to terraform-modules repo
- ✅ **No approval required** (validation only)

### **Stage 2: Terraform Plan**
- 🔍 Runs `terraform plan`
- 📝 Shows what changes will be made
- ⏸️ **Requires manual approval** (environment protection)
- 📋 Plan details posted as comments

### **Stage 3: Terraform Apply**
- 🚀 Applies the changes to Okta
- ✅ Creates/updates Okta applications
- ⏸️ **Requires manual approval** (environment protection)
- 📊 Results posted as comments

## 🔧 Required Secrets

Add these secrets to your GitHub repository:

| Secret Name | Description |
|-------------|-------------|
| `OKTA_ORG_URL` | Your Okta organization URL |
| `OKTA_API_TOKEN` | Okta API token with admin permissions |

## 🛡️ Environment Protection

### **Staging Environment**
- Requires 1 reviewer approval
- Safe for testing changes

### **Production Environment**
- Requires 2 reviewer approvals
- Additional safety checks

## 📁 File Structure

```
poc-okta-terraform-configs/
├── .github/
│   └── workflows/
│       └── deploy-app.yml          # Main workflow
├── apps/
│   ├── FINANCE_EXPENSE_TRACKER/
│   │   ├── app-config.yaml         # YAML configuration
│   │   ├── 2leg-api.tfvars         # Generated .tfvars
│   │   └── 3leg-frontend.tfvars    # Generated .tfvars
│   └── ...
└── scripts/
    ├── list-apps.sh                # List available apps
    ├── validate-yaml-config.sh     # Validate and generate .tfvars
    └── generate-terraform.sh       # Generate Terraform configs
```

## 🔍 Troubleshooting

### **App Not Found**
- Check the app name is correct (case-sensitive)
- Ensure `app-config.yaml` exists in the app folder
- Run `./scripts/list-apps.sh` to see available apps

### **Validation Failed**
- Check YAML syntax in `app-config.yaml`
- Ensure required fields are present
- Verify email format is correct

### **Terraform Plan Failed**
- Check Okta API token permissions
- Verify Okta organization URL
- Review plan output for specific errors

### **Apply Failed**
- Check if resources already exist in Okta
- Verify no conflicts with existing apps
- Review apply output for specific errors

## 📞 Support

For issues with:
- **Workflow**: Check GitHub Actions logs
- **Validation**: Run `./scripts/validate-yaml-config.sh apps/APP_NAME`
- **Terraform**: Check generated files in `modules/generated/APP_NAME/`

## 🔄 Workflow Example

```yaml
# Example workflow run
name: Deploy FINANCE_EXPENSE_TRACKER
on:
  workflow_dispatch:
    inputs:
      app_name: FINANCE_EXPENSE_TRACKER
      environment: staging

# Stages:
# 1. ✅ Validate YAML → Generate .tfvars
# 2. ⏸️ Plan (requires approval)
# 3. ⏸️ Apply (requires approval)
``` 