#!/bin/bash

# Script to list available apps for GitHub Actions workflow
# This helps users see what apps are available for deployment

set -e

echo "🔍 Available Okta Apps for Deployment:"
echo "======================================"

# Check if we're in the right directory
if [ ! -d "apps" ]; then
    echo "❌ Error: 'apps' directory not found. Run this script from the root of poc-okta-terraform-configs."
    exit 1
fi

# Counter for apps
app_count=0

# Loop through app directories
for app_dir in apps/*/; do
    if [ -d "$app_dir" ]; then
        app_name=$(basename "$app_dir")
        app_count=$((app_count + 1))
        
        # Check if app-config.yaml exists
        if [ -f "$app_dir/app-config.yaml" ]; then
            echo "✅ $app_count. $app_name"
            
            # Try to extract app label from YAML
            if command -v yq &> /dev/null; then
                app_label=$(yq eval '.app_label' "$app_dir/app-config.yaml" 2>/dev/null || echo "N/A")
                echo "   📝 Label: $app_label"
            fi
            
            # Check for existing .tfvars files
            tfvars_count=0
            for tfvars_file in "$app_dir"*.tfvars; do
                if [ -f "$tfvars_file" ]; then
                    tfvars_count=$((tfvars_count + 1))
                fi
            done
            
            if [ $tfvars_count -gt 0 ]; then
                echo "   📄 .tfvars files: $tfvars_count (ready for deployment)"
            else
                echo "   ⚠️  No .tfvars files (needs validation)"
            fi
            
        else
            echo "❌ $app_count. $app_name (missing app-config.yaml)"
        fi
        
        echo ""
    fi
done

if [ $app_count -eq 0 ]; then
    echo "❌ No apps found in the apps/ directory."
    exit 1
fi

echo "📊 Summary:"
echo "   Total apps found: $app_count"
echo ""
echo "🚀 To deploy an app:"
echo "   1. Use the app name (e.g., FINANCE_EXPENSE_TRACKER)"
echo "   2. Run: ./scripts/validate-yaml-config.sh apps/APP_NAME"
echo "   3. Or use GitHub Actions workflow with the app name"
echo ""
echo "💡 Tips:"
echo "   - Apps with .tfvars files are ready for deployment"
echo "   - Apps without .tfvars need validation first"
echo "   - Use the exact app name (case-sensitive) in GitHub Actions" 