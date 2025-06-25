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

# Function to validate folder name follows DIVISIONNAME_CMDBSHORTNAME_APPNAME pattern
validate_folder_name() {
    local folder_path="$1"
    local config_file="$2"
    
    # Extract folder name from path
    local folder_name=$(basename "$folder_path")
    
    # Get division name and CMDB short name from YAML
    local division_name_yaml=$(yq eval '.division_name' "$config_file" 2>/dev/null)
    local cmdb_short_name_yaml=$(yq eval '.cmdb_short_name' "$config_file" 2>/dev/null)
    
    if [[ -z "$division_name_yaml" || "$division_name_yaml" == "null" ]]; then
        echo "❌ Missing division_name in YAML configuration"
        return 1
    fi
    
    if [[ -z "$cmdb_short_name_yaml" || "$cmdb_short_name_yaml" == "null" ]]; then
        echo "❌ Missing cmdb_short_name in YAML configuration"
        return 1
    fi
    
    # Expected folder name pattern: DIVISIONNAME_CMDBSHORTNAME_APPNAME
    local expected_prefix="${division_name_yaml}_${cmdb_short_name_yaml}"
    
    # Check if folder name starts with expected prefix
    if [[ ! "$folder_name" =~ ^${expected_prefix}_ ]]; then
        echo "❌ Invalid folder name: $folder_name"
        echo "   Expected pattern: ${expected_prefix}_APPNAME"
        echo "   YAML division_name: $division_name_yaml"
        echo "   YAML cmdb_short_name: $cmdb_short_name_yaml"
        return 1
    fi
    
    # Validate division name is one of DIV1-DIV6
    if [[ ! "$division_name_yaml" =~ ^DIV[1-6]$ ]]; then
        echo "❌ Invalid division name in YAML: $division_name_yaml"
        echo "   Must be one of: DIV1, DIV2, DIV3, DIV4, DIV5, DIV6"
        return 1
    fi
    
    echo "✅ Folder name validation passed: $folder_name"
    echo "   Division: $division_name_yaml"
    echo "   CMDB Short Name: $cmdb_short_name_yaml"
    echo "   Expected prefix: $expected_prefix"
    return 0
}

# Function to validate YAML configuration
validate_yaml_config() {
    local config_file="$1"
    
    echo "🔍 Validating YAML configuration..."
    
    # Check if yq is available
    if ! command -v yq &> /dev/null; then
        echo "❌ yq is required for YAML validation but not installed"
        echo "   Install yq: https://github.com/mikefarah/yq"
        return 1
    fi
    
    # Check if file exists
    if [[ ! -f "$config_file" ]]; then
        echo "❌ YAML configuration file not found: $config_file"
        return 1
    fi
    
    # Validate required fields
    local required_fields=("cmdb_app_name" "division_name" "cmdb_short_name" "point_of_contact_email" "app_owner" "onboarding_snow_request")
    
    for field in "${required_fields[@]}"; do
        local value=$(yq eval ".$field" "$config_file" 2>/dev/null)
        if [[ -z "$value" || "$value" == "null" ]]; then
            echo "❌ Required field missing: $field"
            return 1
        fi
    done
    
    # Validate email format
    local email=$(yq eval '.point_of_contact_email' "$config_file")
    if [[ ! "$email" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
        echo "❌ point_of_contact_email is not a valid email address: $email"
        return 1
    fi
    
    # Validate division name format
    local division_name=$(yq eval '.division_name' "$config_file")
    if [[ ! "$division_name" =~ ^DIV[1-6]$ ]]; then
        echo "❌ division_name must be one of DIV1-DIV6: $division_name"
        return 1
    fi
    
    # Validate CMDB short name format (uppercase alphanumeric only)
    local cmdb_short_name=$(yq eval '.cmdb_short_name' "$config_file")
    if [[ ! "$cmdb_short_name" =~ ^[A-Z0-9]+$ ]]; then
        echo "❌ cmdb_short_name must be uppercase alphanumeric only: $cmdb_short_name"
        return 1
    fi
    
    # Validate app configuration
    local create_2leg=$(yq eval '.app_config.create_2leg' "$config_file")
    local create_3leg_frontend=$(yq eval '.app_config.create_3leg_frontend' "$config_file")
    local create_3leg_backend=$(yq eval '.app_config.create_3leg_backend' "$config_file")
    local create_3leg_native=$(yq eval '.app_config.create_3leg_native' "$config_file")
    local create_saml=$(yq eval '.app_config.create_saml' "$config_file")
    
    # Count enabled 3-leg types
    local three_leg_count=0
    [[ "$create_3leg_frontend" == "true" ]] && ((three_leg_count++))
    [[ "$create_3leg_backend" == "true" ]] && ((three_leg_count++))
    [[ "$create_3leg_native" == "true" ]] && ((three_leg_count++))
    
    # Validate only one 3-leg type is enabled
    if [[ $three_leg_count -gt 1 ]]; then
        echo "❌ Only one 3-leg app type can be enabled at a time"
        echo "   Frontend: $create_3leg_frontend"
        echo "   Backend: $create_3leg_backend"
        echo "   Native: $create_3leg_native"
        return 1
    fi
    
    # Validate SAML is false (not implemented)
    if [[ "$create_saml" == "true" ]]; then
        echo "❌ SAML is not implemented yet. Set create_saml: false"
        return 1
    fi
    
    # Validate at least one OAuth type is enabled
    if [[ "$create_2leg" != "true" && "$create_3leg_frontend" != "true" && "$create_3leg_backend" != "true" && "$create_3leg_native" != "true" ]]; then
        echo "❌ At least one OAuth app type must be enabled"
        return 1
    fi
    
    echo "✅ App configuration validation passed"
    echo "   - 2-leg: $create_2leg"
    echo "   - 3-leg frontend: $create_3leg_frontend"
    echo "   - 3-leg backend: $create_3leg_backend"
    echo "   - 3-leg native: $create_3leg_native"
    echo "   - SAML: $create_saml"
    
    echo "✅ YAML configuration validation passed"
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
    
    # Use folder name as technical app name
    local app_name=$(basename "$app_folder")
    # Get cmdb_app_name (CMDB name) from YAML
    local cmdb_app_name=$(yq eval '.cmdb_app_name' "$config_file")
    # Get CMDB short name from YAML
    local cmdb_short_name=$(yq eval '.cmdb_short_name' "$config_file")
    # Get division name from YAML
    local division_name=$(yq eval '.division_name' "$config_file")
    
    # Get app configuration
    local create_2leg=$(yq eval '.app_config.create_2leg' "$config_file")
    local create_3leg_frontend=$(yq eval '.app_config.create_3leg_frontend' "$config_file")
    local create_3leg_backend=$(yq eval '.app_config.create_3leg_backend' "$config_file")
    local create_3leg_native=$(yq eval '.app_config.create_3leg_native' "$config_file")
    
    # Get redirect URIs from YAML (single array)
    local redirect_uris=$(yq eval '.app_config.redirect_uris[]?' "$config_file" 2>/dev/null | tr '\n' ' ' | sed 's/ $//')
    
    # Get post-logout URIs from YAML (single array)
    local post_logout_uris=$(yq eval '.app_config.post_logout_uris[]?' "$config_file" 2>/dev/null | tr '\n' ' ' | sed 's/ $//')
    
    # Get trusted origins from YAML
    local trusted_origins=$(yq eval '.trusted_origins[]?' "$config_file" 2>/dev/null)
    
    # Get bookmarks from YAML
    local bookmarks=$(yq eval '.bookmarks[]?' "$config_file" 2>/dev/null)
    
    # Generate .tfvars files for each enabled app type
    if [[ "$create_2leg" == "true" ]]; then
        echo "📝 Generating 2-leg API configuration..."
        generate_2leg_tfvars "$app_folder" "$app_name" "$cmdb_app_name" "$division_name" "$cmdb_short_name" "$trusted_origins" "$bookmarks"
    fi
    
    if [[ "$create_3leg_frontend" == "true" ]]; then
        echo "📝 Generating 3-leg frontend configuration..."
        generate_3leg_frontend_tfvars "$app_folder" "$app_name" "$cmdb_app_name" "$division_name" "$cmdb_short_name" "$redirect_uris" "$post_logout_uris" "$trusted_origins" "$bookmarks"
    fi
    
    if [[ "$create_3leg_backend" == "true" ]]; then
        echo "📝 Generating 3-leg backend configuration..."
        generate_3leg_backend_tfvars "$app_folder" "$app_name" "$cmdb_app_name" "$division_name" "$cmdb_short_name" "$redirect_uris" "$post_logout_uris" "$trusted_origins" "$bookmarks"
    fi
    
    if [[ "$create_3leg_native" == "true" ]]; then
        echo "📝 Generating 3-leg native configuration..."
        generate_3leg_native_tfvars "$app_folder" "$app_name" "$cmdb_app_name" "$division_name" "$cmdb_short_name" "$redirect_uris" "$post_logout_uris" "$trusted_origins" "$bookmarks"
    fi
    
    echo "✅ .tfvars files generated successfully"
}

# Function to generate 2-leg API .tfvars
generate_2leg_tfvars() {
    local app_folder="$1"
    local app_name="$2"
    local cmdb_app_name="$3"
    local division_name="$4"
    local cmdb_short_name="$5"
    local trusted_origins="$6"
    local bookmarks="$7"
    
    # Convert app_name to lowercase and replace underscores with hyphens
    local app_name_lower=$(echo "$app_name" | tr '[:upper:]' '[:lower:]' | tr '_' '-')
    
    # Format redirect URIs (2-leg doesn't use redirect URIs)
    local redirect_uris="[]"
    
    # Format trusted origins
    local trusted_origin_name="$division_name"_"$cmdb_short_name"_API_ORIGIN
    local trusted_origin_url="https://api.$app_name_lower.example.com"
    local trusted_origin_scopes='["CORS"]'
    
    # Use first trusted origin from YAML if available
    if [[ -n "$trusted_origins" ]]; then
        trusted_origin_name=$(echo "$trusted_origins" | yq eval '.[0].name' - 2>/dev/null || echo "$trusted_origin_name")
        trusted_origin_url=$(echo "$trusted_origins" | yq eval '.[0].url' - 2>/dev/null || echo "$trusted_origin_url")
        trusted_origin_scopes=$(echo "$trusted_origins" | yq eval '.[0].scopes' - 2>/dev/null || echo "$trusted_origin_scopes")
    fi
    
    # Format bookmarks
    local bookmark_name="$division_name"_"$cmdb_short_name"_API_BOOKMARK
    local bookmark_label="$cmdb_app_name API Admin"
    local bookmark_url="https://admin.$app_name_lower.example.com"
    
    # Use first bookmark from YAML if available
    if [[ -n "$bookmarks" ]]; then
        bookmark_name=$(echo "$bookmarks" | yq eval '.[0].name' - 2>/dev/null || echo "$bookmark_name")
        bookmark_label=$(echo "$bookmarks" | yq eval '.[0].label' - 2>/dev/null || echo "$bookmark_label")
        bookmark_url=$(echo "$bookmarks" | yq eval '.[0].url' - 2>/dev/null || echo "$bookmark_url")
    fi
    
    cat > "$app_folder/2leg-api.tfvars" << EOF
# 2-leg API Configuration for $cmdb_app_name
app_name = "$division_name"_"$cmdb_short_name"_API_SVCS
app_label = "$division_name"_"$cmdb_short_name"_API_SVCS
grant_types = ["client_credentials"]
redirect_uris = $redirect_uris
response_types = []
token_endpoint_auth_method = "client_secret_basic"
auto_submit_toolbar = false
hide_ios = true
hide_web = true
issuer_mode = "ORG_URL"
pkce_required = null

group_name = "$division_name"_"$cmdb_short_name"_API_ACCESS
group_description = "Access group for $cmdb_app_name API"

trusted_origin_name = "$trusted_origin_name"
trusted_origin_url = "$trusted_origin_url"
trusted_origin_scopes = $trusted_origin_scopes

app_group_assignments = [
  {
    app_name = "$division_name"_"$cmdb_short_name"_API_SVCS
    group_name = "$division_name"_"$cmdb_short_name"_API_ACCESS
  }
]

bookmark_name = "$bookmark_name"
bookmark_label = "$bookmark_label"
bookmark_url = "$bookmark_url"
EOF
}

# Function to generate 3-leg frontend .tfvars
generate_3leg_frontend_tfvars() {
    local app_folder="$1"
    local app_name="$2"
    local cmdb_app_name="$3"
    local division_name="$4"
    local cmdb_short_name="$5"
    local redirect_uris="$6"
    local post_logout_uris="$7"
    local trusted_origins="$8"
    local bookmarks="$9"
    
    # Convert app_name to lowercase and replace underscores with hyphens
    local app_name_lower=$(echo "$app_name" | tr '[:upper:]' '[:lower:]' | tr '_' '-')
    
    # Format redirect URIs for Terraform
    local formatted_redirect_uris=""
    if [[ -n "$redirect_uris" ]]; then
        formatted_redirect_uris=$(echo "$redirect_uris" | sed 's/ /",\n  "/g' | sed 's/^/  "/' | sed 's/$/"/')
    fi
    
    cat > "$app_folder/3leg-frontend.tfvars" << EOF
# 3-leg Frontend Configuration for $cmdb_app_name
app_name = "$division_name"_"$cmdb_short_name"_OIDC_SPA
app_label = "$division_name"_"$cmdb_short_name"_OIDC_SPA
grant_types = ["authorization_code", "refresh_token"]
redirect_uris = [
$formatted_redirect_uris
]
response_types = ["code"]
token_endpoint_auth_method = "none"
pkce_required = true
auto_submit_toolbar = false
hide_ios = false
hide_web = false
issuer_mode = "ORG_URL"

group_name = "$division_name"_"$cmdb_short_name"_SPA_ACCESS
group_description = "Access group for $cmdb_app_name Frontend"

trusted_origin_name = "$division_name"_"$cmdb_short_name"_SPA_ORIGIN
trusted_origin_url = "https://$app_name_lower.example.com"
trusted_origin_scopes = ["CORS", "REDIRECT"]

app_group_assignments = [
  {
    app_name = "$division_name"_"$cmdb_short_name"_OIDC_SPA
    group_name = "$division_name"_"$cmdb_short_name"_SPA_ACCESS
  }
]

bookmark_name = "$division_name"_"$cmdb_short_name"_SPA_BOOKMARK
bookmark_label = "$cmdb_app_name Frontend Admin"
bookmark_url = "https://$app_name_lower.example.com"
EOF
}

# Function to generate 3-leg backend .tfvars
generate_3leg_backend_tfvars() {
    local app_folder="$1"
    local app_name="$2"
    local cmdb_app_name="$3"
    local division_name="$4"
    local cmdb_short_name="$5"
    local redirect_uris="$6"
    local post_logout_uris="$7"
    local trusted_origins="$8"
    local bookmarks="$9"
    
    # Convert app_name to lowercase and replace underscores with hyphens
    local app_name_lower=$(echo "$app_name" | tr '[:upper:]' '[:lower:]' | tr '_' '-')
    
    # Format redirect URIs for Terraform
    local formatted_redirect_uris=""
    if [[ -n "$redirect_uris" ]]; then
        formatted_redirect_uris=$(echo "$redirect_uris" | sed 's/ /",\n  "/g' | sed 's/^/  "/' | sed 's/$/"/')
    fi
    
    cat > "$app_folder/3leg-backend.tfvars" << EOF
# 3-leg Backend Configuration for $cmdb_app_name
app_name = "$division_name"_"$cmdb_short_name"_OIDC_WA
app_label = "$division_name"_"$cmdb_short_name"_OIDC_WA
grant_types = ["authorization_code", "refresh_token"]
redirect_uris = [
$formatted_redirect_uris
]
response_types = ["code"]
token_endpoint_auth_method = "client_secret_basic"
pkce_required = false
auto_submit_toolbar = false
hide_ios = false
hide_web = false
issuer_mode = "ORG_URL"

group_name = "$division_name"_"$cmdb_short_name"_WA_ACCESS
group_description = "Access group for $cmdb_app_name Backend"

trusted_origin_name = "$division_name"_"$cmdb_short_name"_WA_ORIGIN
trusted_origin_url = "https://$app_name_lower.example.com"
trusted_origin_scopes = ["CORS", "REDIRECT"]

app_group_assignments = [
  {
    app_name = "$division_name"_"$cmdb_short_name"_OIDC_WA
    group_name = "$division_name"_"$cmdb_short_name"_WA_ACCESS
  }
]

bookmark_name = "$division_name"_"$cmdb_short_name"_WA_BOOKMARK
bookmark_label = "$cmdb_app_name Backend Admin"
bookmark_url = "https://$app_name_lower.example.com"
EOF
}

# Function to generate 3-leg native .tfvars
generate_3leg_native_tfvars() {
    local app_folder="$1"
    local app_name="$2"
    local cmdb_app_name="$3"
    local division_name="$4"
    local cmdb_short_name="$5"
    local redirect_uris="$6"
    local post_logout_uris="$7"
    local trusted_origins="$8"
    local bookmarks="$9"
    
    # Convert app_name to lowercase and replace underscores with hyphens
    local app_name_lower=$(echo "$app_name" | tr '[:upper:]' '[:lower:]' | tr '_' '-')
    
    # Format redirect URIs for Terraform
    local formatted_redirect_uris=""
    if [[ -n "$redirect_uris" ]]; then
        formatted_redirect_uris=$(echo "$redirect_uris" | sed 's/ /",\n  "/g' | sed 's/^/  "/' | sed 's/$/"/')
    fi
    
    cat > "$app_folder/3leg-native.tfvars" << EOF
# 3-leg Native Configuration for $cmdb_app_name
app_name = "$division_name"_"$cmdb_short_name"_OIDC_NA
app_label = "$division_name"_"$cmdb_short_name"_OIDC_NA
grant_types = ["password", "refresh_token", "authorization_code"]
redirect_uris = [
$formatted_redirect_uris
]
response_types = ["code"]
token_endpoint_auth_method = "client_secret_basic"
pkce_required = true
auto_submit_toolbar = false
hide_ios = false
hide_web = true
issuer_mode = "ORG_URL"

group_name = "$division_name"_"$cmdb_short_name"_NA_ACCESS
group_description = "Access group for $cmdb_app_name Native"

trusted_origin_name = "$division_name"_"$cmdb_short_name"_NA_ORIGIN
trusted_origin_url = "https://$app_name_lower.example.com"
trusted_origin_scopes = ["CORS", "REDIRECT"]

app_group_assignments = [
  {
    app_name = "$division_name"_"$cmdb_short_name"_OIDC_NA
    group_name = "$division_name"_"$cmdb_short_name"_NA_ACCESS
  }
]

bookmark_name = "$division_name"_"$cmdb_short_name"_NA_BOOKMARK
bookmark_label = "$cmdb_app_name Native Admin"
bookmark_url = "https://$app_name_lower.example.com"
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
    if ! validate_folder_name "$app_folder" "$config_file"; then
        exit 1
    fi
    
    echo ""
    
    # Validate YAML configuration
    if ! validate_yaml_config "$config_file"; then
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