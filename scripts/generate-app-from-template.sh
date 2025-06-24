#!/bin/bash

# Script to generate app configurations from templates
# Usage: ./generate-app-from-template.sh <template_type> <app_name> <app_label> [options]

set -e

# Template types
TEMPLATE_TYPES=("2leg-api" "3leg-spa" "3leg-webapp" "hybrid-spa-api")

# Function to show usage
show_usage() {
    echo "Usage: $0 <template_type> <app_name> <app_label> [options]"
    echo ""
    echo "Template Types:"
    echo "  2leg-api     - 2-leg OAuth (API Services, Client Credentials)"
    echo "  3leg-spa     - 3-leg OAuth (Frontend SPA, Authorization Code + PKCE)"
    echo "  3leg-webapp  - 3-leg OAuth (Web App Backend, Authorization Code)"
    echo "  hybrid-spa-api - Hybrid SPA/API application"
    echo ""
    echo "Required Parameters:"
    echo "  template_type - Type of OAuth application template"
    echo "  app_name      - Application name (e.g., my-api-service)"
    echo "  app_label     - Application display label (e.g., My API Service)"
    echo ""
    echo "Optional Parameters:"
    echo "  --redirect-uri <uri>           - Redirect URI for 3-leg apps"
    echo "  --logout-redirect-uri <uri>    - Logout redirect URI for 3-leg apps"
    echo "  --trusted-origin-url <url>     - Trusted origin URL"
    echo "  --bookmark-url <url>           - Bookmark URL for admin access"
    echo ""
    echo "Examples:"
    echo "  $0 2leg-api my-api my-api-service"
    echo "  $0 3leg-spa my-spa \"My SPA App\" --redirect-uri https://app.example.com/callback"
    echo "  $0 3leg-webapp my-webapp \"My Web App\" --redirect-uri https://app.example.com/callback --trusted-origin-url https://app.example.com"
}

# Check if template type is valid
is_valid_template() {
    local template=$1
    for valid in "${TEMPLATE_TYPES[@]}"; do
        if [[ "$valid" == "$template" ]]; then
            return 0
        fi
    done
    return 1
}

# Parse command line arguments
TEMPLATE_TYPE=""
APP_NAME=""
APP_LABEL=""
REDIRECT_URI=""
LOGOUT_REDIRECT_URI=""
TRUSTED_ORIGIN_URL=""
BOOKMARK_URL=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --help|-h)
            show_usage
            exit 0
            ;;
        --redirect-uri)
            REDIRECT_URI="$2"
            shift 2
            ;;
        --logout-redirect-uri)
            LOGOUT_REDIRECT_URI="$2"
            shift 2
            ;;
        --trusted-origin-url)
            TRUSTED_ORIGIN_URL="$2"
            shift 2
            ;;
        --bookmark-url)
            BOOKMARK_URL="$2"
            shift 2
            ;;
        *)
            if [[ -z "$TEMPLATE_TYPE" ]]; then
                TEMPLATE_TYPE="$1"
            elif [[ -z "$APP_NAME" ]]; then
                APP_NAME="$1"
            elif [[ -z "$APP_LABEL" ]]; then
                APP_LABEL="$1"
            else
                echo "Error: Unknown parameter $1"
                show_usage
                exit 1
            fi
            shift
            ;;
    esac
done

# Validate required parameters
if [[ -z "$TEMPLATE_TYPE" ]] || [[ -z "$APP_NAME" ]] || [[ -z "$APP_LABEL" ]]; then
    echo "Error: Missing required parameters"
    show_usage
    exit 1
fi

# Validate template type
if ! is_valid_template "$TEMPLATE_TYPE"; then
    echo "Error: Invalid template type '$TEMPLATE_TYPE'"
    echo "Valid types: ${TEMPLATE_TYPES[*]}"
    exit 1
fi

# Set default values for optional parameters
if [[ -z "$TRUSTED_ORIGIN_URL" ]]; then
    TRUSTED_ORIGIN_URL="https://${APP_NAME}.example.com"
fi

if [[ -z "$REDIRECT_URI" ]]; then
    REDIRECT_URI="https://${APP_NAME}.example.com/callback"
fi

if [[ -z "$LOGOUT_REDIRECT_URI" ]]; then
    LOGOUT_REDIRECT_URI="https://${APP_NAME}.example.com/logout"
fi

if [[ -z "$BOOKMARK_URL" ]]; then
    BOOKMARK_URL="https://${APP_NAME}.example.com"
fi

# Create app directory
APP_DIR="apps/${APP_NAME}"
mkdir -p "$APP_DIR"

echo "Generating app configuration for '$APP_NAME' using template '$TEMPLATE_TYPE'..."

# Template file path
TEMPLATE_FILE="templates/oauth-${TEMPLATE_TYPE}.tfvars"

if [[ ! -f "$TEMPLATE_FILE" ]]; then
    echo "Error: Template file '$TEMPLATE_FILE' not found"
    exit 1
fi

# Generate the main configuration file
echo "Creating main configuration file..."
sed -e "s/{{APP_NAME}}/$APP_NAME/g" \
    -e "s/{{APP_LABEL}}/$APP_LABEL/g" \
    -e "s/{{GROUP_NAME}}/${APP_NAME}-access/g" \
    -e "s/{{TRUSTED_ORIGIN_NAME}}/${APP_NAME}-origin/g" \
    -e "s|{{TRUSTED_ORIGIN_URL}}|$TRUSTED_ORIGIN_URL|g" \
    -e "s|{{REDIRECT_URI}}|$REDIRECT_URI|g" \
    -e "s|{{LOGOUT_REDIRECT_URI}}|$LOGOUT_REDIRECT_URI|g" \
    -e "s/{{BOOKMARK_NAME}}/${APP_NAME}-bookmark/g" \
    -e "s/{{BOOKMARK_LABEL}}/${APP_LABEL} Admin/g" \
    -e "s|{{BOOKMARK_URL}}|$BOOKMARK_URL|g" \
    "$TEMPLATE_FILE" > "$APP_DIR/app.tfvars"

# Create separate .tfvars files for each resource type
echo "Creating resource-specific configuration files..."

# Extract OAuth app configuration
grep -E "^(app_name|app_label|grant_types|response_types|token_endpoint_auth_method|auto_submit_toolbar|hide_ios|hide_web|issuer_mode|pkce_required)" "$APP_DIR/app.tfvars" > "$APP_DIR/oauth.tfvars"

# Extract redirect_uris separately (multi-line)
echo "" >> "$APP_DIR/oauth.tfvars"
grep -A 10 "redirect_uris" "$APP_DIR/app.tfvars" | head -10 >> "$APP_DIR/oauth.tfvars"

# Extract group configuration
grep -E "^(group_name|group_description)" "$APP_DIR/app.tfvars" > "$APP_DIR/group.tfvars"

# Extract trusted origin configuration
grep -E "^(trusted_origin_name|trusted_origin_url|trusted_origin_scopes)" "$APP_DIR/app.tfvars" > "$APP_DIR/trusted_origin.tfvars"

# Extract bookmark configuration
grep -E "^(bookmark_name|bookmark_label|bookmark_url)" "$APP_DIR/app.tfvars" > "$APP_DIR/bookmark.tfvars"

# Extract assignments configuration
grep -A 10 "app_group_assignments" "$APP_DIR/app.tfvars" > "$APP_DIR/assignments.tfvars"

echo "✅ App configuration generated successfully!"
echo ""
echo "📁 Generated files in: $APP_DIR"
echo "   - app.tfvars (complete configuration)"
echo "   - oauth.tfvars (OAuth app settings)"
echo "   - group.tfvars (group settings)"
echo "   - trusted_origin.tfvars (trusted origin settings)"
echo "   - bookmark.tfvars (bookmark app settings)"
echo "   - assignments.tfvars (app-group assignments)"
echo ""
echo "🚀 To deploy this app:"
echo "   ./scripts/generate-terraform.sh apps/$APP_NAME $APP_NAME"
echo "   cd generated/$APP_NAME"
echo "   terraform init"
echo "   terraform plan"
echo "   terraform apply" 