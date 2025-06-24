#!/bin/bash

# Deployment script for Okta Terraform configurations
# This script orchestrates the entire pipeline: checkout, generate, deploy

set -e

# Configuration
APP_PATH="$1"
APP_NAME="$2"
ENVIRONMENT="$3"
ACTION="$4"  # plan, apply, destroy

if [ -z "$APP_PATH" ] || [ -z "$APP_NAME" ] || [ -z "$ENVIRONMENT" ] || [ -z "$ACTION" ]; then
    echo "Usage: $0 <app_path> <app_name> <environment> <action>"
    echo "Example: $0 apps/app1 app1 dev plan"
    echo "Actions: plan, apply, destroy"
    exit 1
fi

echo "=== Okta Terraform Deployment Pipeline ==="
echo "App: $APP_NAME"
echo "Path: $APP_PATH"
echo "Environment: $ENVIRONMENT"
echo "Action: $ACTION"
echo ""

# Step 1: Checkout modules repo (if not already present)
if [ ! -d "../poc-okta-terraform-modules" ]; then
    echo "Step 1: Checking out modules repository..."
    git clone https://github.com/your-org/poc-okta-terraform-modules.git ../poc-okta-terraform-modules
else
    echo "Step 1: Modules repository already exists, pulling latest..."
    cd ../poc-okta-terraform-modules
    git pull origin main
    cd ../poc-okta-terraform-configs
fi

# Step 2: Generate Terraform configuration
echo ""
echo "Step 2: Generating Terraform configuration..."
chmod +x scripts/generate-terraform.sh
./scripts/generate-terraform.sh "$APP_PATH" "$APP_NAME"

# Step 3: Navigate to generated directory
WORK_DIR="$(pwd)/generated/$APP_NAME"
cd "$WORK_DIR"

# Step 4: Set up environment-specific backend (if needed)
if [ -f "../../environments/$ENVIRONMENT/backend.tf" ]; then
    echo ""
    echo "Step 4: Setting up environment-specific backend..."
    cp "../../environments/$ENVIRONMENT/backend.tf" .
fi

# Step 5: Initialize Terraform
echo ""
echo "Step 5: Initializing Terraform..."
terraform init

# Step 6: Execute Terraform action
echo ""
echo "Step 6: Executing Terraform $ACTION..."

case $ACTION in
    "plan")
        terraform plan
        ;;
    "apply")
        terraform apply -auto-approve
        ;;
    "destroy")
        terraform destroy -auto-approve
        ;;
    *)
        echo "Invalid action: $ACTION"
        echo "Valid actions: plan, apply, destroy"
        exit 1
        ;;
esac

echo ""
echo "=== Deployment completed successfully ==="
echo "Generated files are in: $WORK_DIR" 