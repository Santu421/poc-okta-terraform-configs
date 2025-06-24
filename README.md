# Okta Terraform Configurations

This repository contains per-app, per-policy, and per-group configurations for Okta resources. The pipeline automatically composes these configurations with modules from `poc-okta-terraform-modules` at build time.

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