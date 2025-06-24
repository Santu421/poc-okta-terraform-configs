#!/bin/bash

# Script to validate YAML configuration files
# Enforces strict rules for app configuration

set -e

# Function to show usage
show_usage() {
    echo "Usage: $0 <app_folder>"
    echo ""
    echo "Validates YAML configuration for an app folder"
    echo "App folder must follow pattern: DIVISIONNAME_APPNAME"
    echo ""
    echo "Example:"
    echo "  $0 apps/FINANCE_EXPENSE_TRACKER"
}

# Function to validate folder name pattern
validate_folder_name() {
    local folder_name="$1"
    
    # Extract folder name from path
    local app_name=$(basename "$folder_name")
    
    # Check pattern: DIVISIONNAME_APPNAME (uppercase, underscores)
    if [[ ! "$app_name" =~ ^[A-Z0-9_]+$ ]]; then
        echo "❌ Invalid folder name: $app_name"
        echo "   Must follow pattern: DIVISIONNAME_APPNAME (uppercase, underscores only)"
        return 1
    fi
    
    # Check for at least one underscore
    if [[ ! "$app_name" =~ _ ]]; then
        echo "❌ Invalid folder name: $app_name"
        echo "   Must contain at least one underscore (DIVISIONNAME_APPNAME)"
        return 1
    fi
    
    echo "✅ Folder name validation passed: $app_name"
    return 0
}

# Function to validate YAML configuration
validate_yaml_config() {
    local config_file="$1"
    local app_name="$2"
    
    if [[ ! -f "$config_file" ]]; then
        echo "❌ Configuration file not found: $config_file"
        return 1
    fi
    
    echo "🔍 Validating YAML configuration..."
    
    # Check if yq is available
    if ! command -v yq &> /dev/null; then
        echo "⚠️  yq not found. Installing basic validation..."
        validate_yaml_basic "$config_file"
        return 0
    fi
    
    # Validate required fields
    local app_name_yaml=$(yq eval '.app_name' "$config_file")
    local app_label=$(yq eval '.app_label' "$config_file")
    local point_of_contact_email=$(yq eval '.point_of_contact_email' "$config_file")
    local app_owner=$(yq eval '.app_owner' "$config_file")
    local onboarding_snow_request=$(yq eval '.onboarding_snow_request' "$config_file")
    
    if [[ "$app_name_yaml" == "null" ]] || [[ -z "$app_name_yaml" ]]; then
        echo "❌ Missing required field: app_name"
        return 1
    fi
    
    if [[ "$app_label" == "null" ]] || [[ -z "$app_label" ]]; then
        echo "❌ Missing required field: app_label"
        return 1
    fi
    
    if [[ "$point_of_contact_email" == "null" ]] || [[ -z "$point_of_contact_email" ]]; then
        echo "❌ Missing required field: point_of_contact_email"
        return 1
    fi
    # Email format validation
    if ! [[ "$point_of_contact_email" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
        echo "❌ point_of_contact_email is not a valid email address: $point_of_contact_email"
        return 1
    fi
    
    if [[ "$app_owner" == "null" ]] || [[ -z "$app_owner" ]]; then
        echo "❌ Missing required field: app_owner"
        return 1
    fi
    
    if [[ "$onboarding_snow_request" == "null" ]] || [[ -z "$onboarding_snow_request" ]]; then
        echo "❌ Missing required field: onboarding_snow_request"
        return 1
    fi
    
    # Validate app_name matches folder name
    if [[ "$app_name_yaml" != "$app_name" ]]; then
        echo "❌ app_name in YAML ($app_name_yaml) doesn't match folder name ($app_name)"
        return 1
    fi
    
    # Validate OAuth configuration
    validate_oauth_config "$config_file"
    
    echo "✅ YAML configuration validation passed"
    return 0
}

# Function to validate OAuth configuration
validate_oauth_config() {
    local config_file="$1"
    
    # Get OAuth configuration values
    local create_2leg=$(yq eval '.oauth_config.create_2leg' "$config_file")
    local create_3leg_frontend=$(yq eval '.oauth_config.create_3leg_frontend' "$config_file")
    local create_3leg_backend=$(yq eval '.oauth_config.create_3leg_backend' "$config_file")
    local create_3leg_native=$(yq eval '.oauth_config.create_3leg_native' "$config_file")
    local create_saml=$(yq eval '.oauth_config.create_saml' "$config_file")
    
    # Check for required fields
    if [[ "$create_2leg" == "null" ]] || [[ "$create_3leg_frontend" == "null" ]] || \
       [[ "$create_3leg_backend" == "null" ]] || [[ "$create_3leg_native" == "null" ]] || \
       [[ "$create_saml" == "null" ]]; then
        echo "❌ Missing required OAuth configuration fields"
        return 1
    fi
    
    # Rule 1: SAML must be false (not implemented)
    if [[ "$create_saml" == "true" ]]; then
        echo "❌ SAML apps are not implemented yet. create_saml must be false"
        return 1
    fi
    
    # Rule 2: At least one OAuth type must be true
    local oauth_count=0
    [[ "$create_2leg" == "true" ]] && ((oauth_count++))
    [[ "$create_3leg_frontend" == "true" ]] && ((oauth_count++))
    [[ "$create_3leg_backend" == "true" ]] && ((oauth_count++))
    [[ "$create_3leg_native" == "true" ]] && ((oauth_count++))
    
    if [[ $oauth_count -eq 0 ]]; then
        echo "❌ At least one OAuth app type must be enabled"
        return 1
    fi
    
    # Rule 3: Only one 3-leg app type can be true at a time
    local three_leg_count=0
    [[ "$create_3leg_frontend" == "true" ]] && ((three_leg_count++))
    [[ "$create_3leg_backend" == "true" ]] && ((three_leg_count++))
    [[ "$create_3leg_native" == "true" ]] && ((three_leg_count++))
    
    if [[ $three_leg_count -gt 1 ]]; then
        echo "❌ Only one 3-leg app type can be enabled at a time"
        echo "   Current: frontend=$create_3leg_frontend, backend=$create_3leg_backend, native=$create_3leg_native"
        return 1
    fi
    
    # Rule 4: 2-leg and 3-leg can be combined (hybrid)
    # This is allowed, so no validation needed
    
    echo "✅ OAuth configuration validation passed"
    echo "   - 2-leg: $create_2leg"
    echo "   - 3-leg frontend: $create_3leg_frontend"
    echo "   - 3-leg backend: $create_3leg_backend"
    echo "   - 3-leg native: $create_3leg_native"
    echo "   - SAML: $create_saml"
    
    return 0
}

# Function for basic YAML validation (without yq)
validate_yaml_basic() {
    local config_file="$1"
    
    echo "⚠️  Using basic YAML validation (yq not available)"
    
    # Check for required fields using grep
    if ! grep -q "app_name:" "$config_file"; then
        echo "❌ Missing required field: app_name"
        return 1
    fi
    
    if ! grep -q "app_label:" "$config_file"; then
        echo "❌ Missing required field: app_label"
        return 1
    fi
    
    if ! grep -q "oauth_config:" "$config_file"; then
        echo "❌ Missing required field: oauth_config"
        return 1
    fi
    
    # Check for SAML being true
    if grep -q "create_saml: true" "$config_file"; then
        echo "❌ SAML apps are not implemented yet. create_saml must be false"
        return 1
    fi
    
    echo "✅ Basic YAML validation passed"
    return 0
}

# Function to generate .tfvars files based on YAML
generate_tfvars_from_yaml() {
    local config_file="$1"
    local app_folder="$2"
    
    echo "🔧 Generating .tfvars files from YAML configuration..."
    
    # Get app name and label
    local app_name=$(yq eval '.app_name' "$config_file")
    local app_label=$(yq eval '.app_label' "$config_file")
    
    # Get OAuth configuration
    local create_2leg=$(yq eval '.oauth_config.create_2leg' "$config_file")
    local create_3leg_frontend=$(yq eval '.oauth_config.create_3leg_frontend' "$config_file")
    local create_3leg_backend=$(yq eval '.oauth_config.create_3leg_backend' "$config_file")
    local create_3leg_native=$(yq eval '.oauth_config.create_3leg_native' "$config_file")
    
    # Generate .tfvars files for each enabled app type
    if [[ "$create_2leg" == "true" ]]; then
        echo "📝 Generating 2-leg API configuration..."
        generate_2leg_tfvars "$app_folder" "$app_name" "$app_label"
    fi
    
    if [[ "$create_3leg_frontend" == "true" ]]; then
        echo "📝 Generating 3-leg frontend configuration..."
        generate_3leg_frontend_tfvars "$app_folder" "$app_name" "$app_label"
    fi
    
    if [[ "$create_3leg_backend" == "true" ]]; then
        echo "📝 Generating 3-leg backend configuration..."
        generate_3leg_backend_tfvars "$app_folder" "$app_name" "$app_label"
    fi
    
    if [[ "$create_3leg_native" == "true" ]]; then
        echo "📝 Generating 3-leg native configuration..."
        generate_3leg_native_tfvars "$app_folder" "$app_name" "$app_label"
    fi
    
    echo "✅ .tfvars files generated successfully"
}

# Function to generate 2-leg API .tfvars
generate_2leg_tfvars() {
    local app_folder="$1"
    local app_name="$2"
    local app_label="$3"
    
    cat > "$app_folder/2leg-api.tfvars" << EOF
# 2-leg API Configuration for $app_label
app_name = "$app_name-2leg"
app_label = "$app_label API"
grant_types = ["client_credentials"]
redirect_uris = []
response_types = []
token_endpoint_auth_method = "client_secret_basic"
auto_submit_toolbar = false
hide_ios = true
hide_web = true
issuer_mode = "ORG_URL"
pkce_required = null

group_name = "$app_name-2leg-access"
group_description = "Access group for $app_label API"

trusted_origin_name = "$app_name-2leg-origin"
trusted_origin_url = "https://api.$app_name.lower().replace('_', '-').example.com"
trusted_origin_scopes = ["CORS"]

app_group_assignments = [
  {
    app_name = "$app_name-2leg"
    group_name = "$app_name-2leg-access"
  }
]

bookmark_name = "$app_name-2leg-bookmark"
bookmark_label = "$app_label API Admin"
bookmark_url = "https://admin.$app_name.lower().replace('_', '-').example.com"
EOF
}

# Function to generate 3-leg frontend .tfvars
generate_3leg_frontend_tfvars() {
    local app_folder="$1"
    local app_name="$2"
    local app_label="$3"
    
    cat > "$app_folder/3leg-frontend.tfvars" << EOF
# 3-leg Frontend Configuration for $app_label
app_name = "$app_name-3leg-frontend"
app_label = "$app_label Frontend"
grant_types = ["authorization_code", "refresh_token"]
redirect_uris = [
  "https://$app_name.lower().replace('_', '-').example.com/callback",
  "https://$app_name.lower().replace('_', '-').example.com/logout"
]
response_types = ["code"]
token_endpoint_auth_method = "none"
pkce_required = true
auto_submit_toolbar = false
hide_ios = false
hide_web = false
issuer_mode = "ORG_URL"

group_name = "$app_name-3leg-frontend-access"
group_description = "Access group for $app_label Frontend"

trusted_origin_name = "$app_name-3leg-frontend-origin"
trusted_origin_url = "https://$app_name.lower().replace('_', '-').example.com"
trusted_origin_scopes = ["CORS", "REDIRECT"]

app_group_assignments = [
  {
    app_name = "$app_name-3leg-frontend"
    group_name = "$app_name-3leg-frontend-access"
  }
]

bookmark_name = "$app_name-3leg-frontend-bookmark"
bookmark_label = "$app_label Frontend Admin"
bookmark_url = "https://$app_name.lower().replace('_', '-').example.com"
EOF
}

# Function to generate 3-leg backend .tfvars
generate_3leg_backend_tfvars() {
    local app_folder="$1"
    local app_name="$2"
    local app_label="$3"
    
    cat > "$app_folder/3leg-backend.tfvars" << EOF
# 3-leg Backend Configuration for $app_label
app_name = "$app_name-3leg-backend"
app_label = "$app_label Backend"
grant_types = ["authorization_code", "refresh_token"]
redirect_uris = [
  "https://$app_name.lower().replace('_', '-').example.com/callback",
  "https://$app_name.lower().replace('_', '-').example.com/logout"
]
response_types = ["code"]
token_endpoint_auth_method = "client_secret_basic"
pkce_required = false
auto_submit_toolbar = false
hide_ios = false
hide_web = false
issuer_mode = "ORG_URL"

group_name = "$app_name-3leg-backend-access"
group_description = "Access group for $app_label Backend"

trusted_origin_name = "$app_name-3leg-backend-origin"
trusted_origin_url = "https://$app_name.lower().replace('_', '-').example.com"
trusted_origin_scopes = ["CORS", "REDIRECT"]

app_group_assignments = [
  {
    app_name = "$app_name-3leg-backend"
    group_name = "$app_name-3leg-backend-access"
  }
]

bookmark_name = "$app_name-3leg-backend-bookmark"
bookmark_label = "$app_label Backend Admin"
bookmark_url = "https://$app_name.lower().replace('_', '-').example.com"
EOF
}

# Function to generate 3-leg native .tfvars
generate_3leg_native_tfvars() {
    local app_folder="$1"
    local app_name="$2"
    local app_label="$3"
    
    cat > "$app_folder/3leg-native.tfvars" << EOF
# 3-leg Native Configuration for $app_label
app_name = "$app_name-3leg-native"
app_label = "$app_label Native"
grant_types = ["password", "refresh_token"]
redirect_uris = [
  "https://$app_name.lower().replace('_', '-').example.com/logout"
]
response_types = []
token_endpoint_auth_method = "client_secret_basic"
pkce_required = false
auto_submit_toolbar = false
hide_ios = false
hide_web = false
issuer_mode = "ORG_URL"

group_name = "$app_name-3leg-native-access"
group_description = "Access group for $app_label Native"

trusted_origin_name = "$app_name-3leg-native-origin"
trusted_origin_url = "https://api.$app_name.lower().replace('_', '-').example.com"
trusted_origin_scopes = ["CORS"]

app_group_assignments = [
  {
    app_name = "$app_name-3leg-native"
    group_name = "$app_name-3leg-native-access"
  }
]

bookmark_name = "$app_name-3leg-native-bookmark"
bookmark_label = "$app_label Native Admin"
bookmark_url = "https://admin.$app_name.lower().replace('_', '-').example.com"
EOF
}

# Main execution
main() {
    local app_folder="$1"
    
    if [[ -z "$app_folder" ]]; then
        echo "Error: App folder path is required"
        show_usage
        exit 1
    fi
    
    if [[ ! -d "$app_folder" ]]; then
        echo "Error: App folder not found: $app_folder"
        exit 1
    fi
    
    local config_file="$app_folder/app-config.yaml"
    local app_name=$(basename "$app_folder")
    
    echo "🔍 Validating app configuration: $app_name"
    echo ""
    
    # Validate folder name
    if ! validate_folder_name "$app_folder"; then
        exit 1
    fi
    
    echo ""
    
    # Validate YAML configuration
    if ! validate_yaml_config "$config_file" "$app_name"; then
        exit 1
    fi
    
    echo ""
    
    # Generate .tfvars files
    if command -v yq &> /dev/null; then
        generate_tfvars_from_yaml "$config_file" "$app_folder"
    else
        echo "⚠️  Skipping .tfvars generation (yq not available)"
    fi
    
    echo ""
    echo "🎉 Validation completed successfully!"
}

# Run main function
main "$@" 