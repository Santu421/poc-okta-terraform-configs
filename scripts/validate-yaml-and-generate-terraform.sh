#!/bin/bash

# Script to validate YAML configuration files
# Enforces strict rules for app configuration
# New folder structure: apps/DIVISION/APPNAME/ENVIRONMENT/app-config.yaml

set -e

# Function to show usage
show_usage() {
    echo "Usage: $0 <app_folder>"
    echo ""
    echo "Validates YAML configuration for an app folder"
    echo "App folder must follow structure: apps/DIVISION/APPNAME/ENVIRONMENT/"
    echo ""
    echo "Example:"
    echo "  $0 apps/DIV1/ET/prod"
    echo "  $0 apps/DIV2/HR/dev"
}

# Function to validate folder structure follows apps/DIVISION/APPNAME/ENVIRONMENT pattern
validate_folder_structure() {
    local folder_path="$1"
    local config_file="$2"
    local metadata_file="$3"
    
    # Get the full path and extract components
    local full_path=$(realpath "$folder_path")
    local apps_dir=$(dirname "$(dirname "$(dirname "$full_path")")")
    local division_name=$(basename "$(dirname "$(dirname "$full_path")")")
    local app_name=$(basename "$(dirname "$full_path")")
    local environment=$(basename "$full_path")
    
    # Get values from metadata file
    local division_name_metadata=$(yq eval '.division_name' "$metadata_file" 2>/dev/null)
    local cmdb_app_short_name_metadata=$(yq eval '.cmdb_app_short_name' "$metadata_file" 2>/dev/null)
    
    # Get environment from YAML
    local environment_yaml=$(yq eval '.environment' "$config_file" 2>/dev/null)
    
    if [[ -z "$division_name_metadata" || "$division_name_metadata" == "null" ]]; then
        echo "❌ Missing division_name in metadata file"
        return 1
    fi
    
    if [[ -z "$cmdb_app_short_name_metadata" || "$cmdb_app_short_name_metadata" == "null" ]]; then
        echo "❌ Missing cmdb_app_short_name in metadata file"
        return 1
    fi
    
    if [[ -z "$environment_yaml" || "$environment_yaml" == "null" ]]; then
        echo "❌ Missing environment in YAML configuration"
        return 1
    fi
    
    # Validate division name format and match
    if [[ ! "$division_name" =~ ^DIV[1-6]$ ]]; then
        echo "❌ Invalid division folder name: $division_name"
        echo "   Must be one of: DIV1, DIV2, DIV3, DIV4, DIV5, DIV6"
        return 1
    fi
    
    if [[ "$division_name" != "$division_name_metadata" ]]; then
        echo "❌ Division name mismatch:"
        echo "   Folder: $division_name"
        echo "   Metadata: $division_name_metadata"
        return 1
    fi
    
    # Validate app name format (should match CMDB short name)
    if [[ ! "$app_name" =~ ^[A-Z0-9]+$ ]]; then
        echo "❌ Invalid app folder name: $app_name"
        echo "   Must be uppercase alphanumeric only"
        return 1
    fi
    
    if [[ "$app_name" != "$cmdb_app_short_name_metadata" ]]; then
        echo "❌ App name mismatch:"
        echo "   Folder: $app_name"
        echo "   Metadata cmdb_app_short_name: $cmdb_app_short_name_metadata"
        return 1
    fi
    
    # Validate environment format and match
    if [[ ! "$environment" =~ ^(dev|uat|prod)$ ]]; then
        echo "❌ Invalid environment folder name: $environment"
        echo "   Must be one of: dev, uat, prod"
        return 1
    fi
    
    if [[ "$environment" != "$environment_yaml" ]]; then
        echo "❌ Environment name mismatch:"
        echo "   Folder: $environment"
        echo "   YAML: $environment_yaml"
        return 1
    fi
    
    echo "✅ Folder structure validation passed:"
    echo "   Division: $division_name"
    echo "   App: $app_name"
    echo "   Environment: $environment"
    return 0
}

# Function to validate YAML configuration
validate_yaml_config() {
    local config_file="$1"
    local metadata_file="$2"
    
    echo "🔍 Validating YAML configuration..."
    
    # Check if yq is available
    if ! command -v yq &> /dev/null; then
        echo "❌ yq is required for YAML validation but not installed"
        echo "   Install yq: https://github.com/mikefarah/yq"
        return 1
    fi
    
    # Check if files exist
    if [[ ! -f "$config_file" ]]; then
        echo "❌ YAML configuration file not found: $config_file"
        return 1
    fi
    
    if [[ ! -f "$metadata_file" ]]; then
        echo "❌ Metadata file not found: $metadata_file"
        return 1
    fi
    
    # Validate metadata file
    local metadata_required_fields=("parent_cmdb_name" "division_name" "cmdb_app_short_name" "team_dl" "requested_by")
    
    for field in "${metadata_required_fields[@]}"; do
        local value=$(yq eval ".$field" "$metadata_file" 2>/dev/null)
        if [[ -z "$value" || "$value" == "null" ]]; then
            echo "❌ Required field missing in metadata: $field"
            return 1
        fi
    done
    
    # Validate email format in metadata
    local team_dl=$(yq eval '.team_dl' "$metadata_file")
    if [[ ! "$team_dl" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
        echo "❌ team_dl is not a valid email address: $team_dl"
        return 1
    fi
    
    local requested_by=$(yq eval '.requested_by' "$metadata_file")
    if [[ ! "$requested_by" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
        echo "❌ requested_by is not a valid email address: $requested_by"
        return 1
    fi
    
    # Validate division name format in metadata
    local division_name=$(yq eval '.division_name' "$metadata_file")
    if [[ ! "$division_name" =~ ^DIV[1-6]$ ]]; then
        echo "❌ division_name must be one of DIV1-DIV6: $division_name"
        return 1
    fi
    
    # Validate CMDB short name format in metadata (uppercase alphanumeric only)
    local cmdb_app_short_name=$(yq eval '.cmdb_app_short_name' "$metadata_file")
    if [[ ! "$cmdb_app_short_name" =~ ^[A-Z0-9]+$ ]]; then
        echo "❌ cmdb_app_short_name must be uppercase alphanumeric only: $cmdb_app_short_name"
        return 1
    fi
    
    # Validate environment-specific config
    local environment=$(yq eval '.environment' "$config_file")
    if [[ ! "$environment" =~ ^(dev|uat|prod)$ ]]; then
        echo "❌ environment must be one of dev, uat, prod: $environment"
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
    local metadata_file="$3"
    
    echo "🔧 Generating .tfvars files from YAML configuration..."
    
    # Extract components from folder structure
    local full_path=$(realpath "$app_folder")
    local division_name=$(basename "$(dirname "$(dirname "$full_path")")")
    local app_name=$(basename "$(dirname "$full_path")")
    local environment=$(basename "$full_path")
    
    # Get cmdb_app_name (CMDB name) from metadata
    local cmdb_app_name=$(yq eval '.parent_cmdb_name' "$metadata_file")
    # Get CMDB short name from metadata
    local cmdb_short_name=$(yq eval '.cmdb_app_short_name' "$metadata_file")
    # Get environment from YAML
    local environment_yaml=$(yq eval '.environment' "$config_file")
    
    # Get app configuration
    local create_2leg=$(yq eval '.app_config.create_2leg' "$config_file")
    local create_3leg_frontend=$(yq eval '.app_config.create_3leg_frontend' "$config_file")
    local create_3leg_backend=$(yq eval '.app_config.create_3leg_backend' "$config_file")
    local create_3leg_native=$(yq eval '.app_config.create_3leg_native' "$config_file")
    
    # Get redirect URIs from YAML (correct path: oauth_config.redirect_uris)
    local redirect_uris=$(yq eval '.oauth_config.redirect_uris[]?' "$config_file" 2>/dev/null | tr '\n' ' ' | sed 's/ $//')
    
    # Get post-logout URIs from YAML (correct path: oauth_config.post_logout_uris)
    local post_logout_uris=$(yq eval '.oauth_config.post_logout_uris[]?' "$config_file" 2>/dev/null | tr '\n' ' ' | sed 's/ $//')
    
    # Get trusted origins from YAML
    local trusted_origins=$(yq eval '.trusted_origins[]?' "$config_file" 2>/dev/null)
    
    # Get bookmarks from YAML
    local bookmarks=$(yq eval '.bookmarks[]?' "$config_file" 2>/dev/null)
    
    # Generate .tfvars files for each enabled app type
    if [[ "$create_2leg" == "true" ]]; then
        echo "📝 Generating 2-leg API configuration..."
        generate_2leg_tfvars "$app_folder" "$app_name" "$cmdb_app_name" "$division_name" "$cmdb_short_name" "$environment" "$trusted_origins" "$bookmarks"
    fi
    
    if [[ "$create_3leg_frontend" == "true" ]]; then
        echo "📝 Generating 3-leg frontend configuration..."
        generate_3leg_frontend_tfvars "$app_folder" "$app_name" "$cmdb_app_name" "$division_name" "$cmdb_short_name" "$environment" "$redirect_uris" "$post_logout_uris" "$trusted_origins" "$bookmarks"
    fi
    
    if [[ "$create_3leg_backend" == "true" ]]; then
        echo "📝 Generating 3-leg backend configuration..."
        generate_3leg_backend_tfvars "$app_folder" "$app_name" "$cmdb_app_name" "$division_name" "$cmdb_short_name" "$environment" "$redirect_uris" "$post_logout_uris" "$trusted_origins" "$bookmarks"
    fi
    
    if [[ "$create_3leg_native" == "true" ]]; then
        echo "📝 Generating 3-leg native configuration..."
        generate_3leg_native_tfvars "$app_folder" "$app_name" "$cmdb_app_name" "$division_name" "$cmdb_short_name" "$environment" "$redirect_uris" "$post_logout_uris" "$trusted_origins" "$bookmarks"
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
    local environment="$6"
    local trusted_origins="$7"
    local bookmarks="$8"
    local app_name_lower=$(echo "$app_name" | tr '[:upper:]' '[:lower:]' | tr '_' '-')
    local environment_upper=$(echo "$environment" | tr '[:lower:]' '[:upper:]')
    local output_file="$app_folder/2leg-api.tfvars"
    cat > "$output_file" << EOF
# 2-leg API Configuration for $cmdb_app_name ($environment)
app_name = "${division_name}_${cmdb_short_name}_API_SVCS_${environment_upper}"
app_label = "${division_name}_${cmdb_short_name}_API_SVCS_${environment_upper}"
token_endpoint_auth_method = "client_secret_basic"
EOF
    # Only add trusted origin if present in YAML
    if [[ -n "$trusted_origins" ]]; then
        local trusted_origin_name=$(echo "$trusted_origins" | yq eval '.[0].name' - 2>/dev/null)
        local trusted_origin_url=$(echo "$trusted_origins" | yq eval '.[0].url' - 2>/dev/null)
        local trusted_origin_scopes=$(echo "$trusted_origins" | yq eval '.[0].scopes' - 2>/dev/null)
        if [[ -n "$trusted_origin_name" && "$trusted_origin_name" != "null" ]]; then
            echo "trusted_origin_name = \"$trusted_origin_name\"" >> "$output_file"
        fi
        if [[ -n "$trusted_origin_url" && "$trusted_origin_url" != "null" ]]; then
            echo "trusted_origin_url = \"$trusted_origin_url\"" >> "$output_file"
        fi
        if [[ -n "$trusted_origin_scopes" && "$trusted_origin_scopes" != "null" ]]; then
            echo "trusted_origin_scopes = $trusted_origin_scopes" >> "$output_file"
        fi
    fi
    # Only add bookmark if present in YAML
    if [[ -n "$bookmarks" ]]; then
        local bookmark_name=$(echo "$bookmarks" | yq eval '.[0].name' - 2>/dev/null)
        local bookmark_label=$(echo "$bookmarks" | yq eval '.[0].label' - 2>/dev/null)
        local bookmark_url=$(echo "$bookmarks" | yq eval '.[0].url' - 2>/dev/null)
        if [[ -n "$bookmark_name" && "$bookmark_name" != "null" ]]; then
            echo "bookmark_name = \"$bookmark_name\"" >> "$output_file"
        fi
        if [[ -n "$bookmark_label" && "$bookmark_label" != "null" ]]; then
            echo "bookmark_label = \"$bookmark_label\"" >> "$output_file"
        fi
        if [[ -n "$bookmark_url" && "$bookmark_url" != "null" ]]; then
            echo "bookmark_url = \"$bookmark_url\"" >> "$output_file"
        fi
    fi
}

# Function to generate 3-leg frontend .tfvars
generate_3leg_frontend_tfvars() {
    local app_folder="$1"
    local app_name="$2"
    local cmdb_app_name="$3"
    local division_name="$4"
    local cmdb_short_name="$5"
    local environment="$6"
    local redirect_uris="$7"
    local post_logout_uris="$8"
    local trusted_origins="$9"
    local bookmarks="${10}"
    
    # Convert app_name to lowercase and replace underscores with hyphens
    local app_name_lower=$(echo "$app_name" | tr '[:upper:]' '[:lower:]' | tr '_' '-')
    local environment_upper=$(echo "$environment" | tr '[:lower:]' '[:upper:]')
    
    # Create the .tfvars file
    cat > "$app_folder/3leg-frontend.tfvars" << EOF
# 3-leg Frontend Configuration for $cmdb_app_name ($environment)
app_name = "${division_name}_${cmdb_short_name}_OIDC_SPA_${environment_upper}"
app_label = "${division_name}_${cmdb_short_name}_OIDC_SPA_${environment_upper}"
grant_types = ["authorization_code", "refresh_token"]
redirect_uris = [
EOF
    
    # Add redirect URIs
    if [[ -n "$redirect_uris" ]]; then
        echo "$redirect_uris" | tr ' ' '\n' | sed 's/^/  "/' | sed 's/$/",/' >> "$app_folder/3leg-frontend.tfvars"
    fi
    
    # Complete the file
    cat >> "$app_folder/3leg-frontend.tfvars" << EOF
]
response_types = ["code"]
token_endpoint_auth_method = "none"

group_name = "${division_name}_${cmdb_short_name}_SPA_ACCESS_${environment_upper}"
group_description = "Access group for $cmdb_app_name Frontend ($environment)"

trusted_origin_name = "${division_name}_${cmdb_short_name}_SPA_ORIGIN_${environment_upper}"
trusted_origin_url = "https://$app_name_lower-${environment}.example.com"
trusted_origin_scopes = ["CORS", "REDIRECT"]

app_group_assignments = [
  {
    app_name = "${division_name}_${cmdb_short_name}_OIDC_SPA_${environment_upper}"
    group_name = "${division_name}_${cmdb_short_name}_SPA_ACCESS_${environment_upper}"
  }
]

bookmark_name = "${division_name}_${cmdb_short_name}_SPA_BOOKMARK_${environment_upper}"
bookmark_label = "$cmdb_app_name Frontend Admin ($environment)"
bookmark_url = "https://$app_name_lower-${environment}.example.com"
EOF
}

# Function to generate 3-leg backend .tfvars
generate_3leg_backend_tfvars() {
    local app_folder="$1"
    local app_name="$2"
    local cmdb_app_name="$3"
    local division_name="$4"
    local cmdb_short_name="$5"
    local environment="$6"
    local redirect_uris="$7"
    local post_logout_uris="$8"
    local trusted_origins="$9"
    local bookmarks="${10}"
    local app_name_lower=$(echo "$app_name" | tr '[:upper:]' '[:lower:]' | tr '_' '-')
    local environment_upper=$(echo "$environment" | tr '[:lower:]' '[:upper:]')
    cat > "$app_folder/3leg-backend.tfvars" << EOF
# 3-leg Backend Configuration for $cmdb_app_name ($environment)
app_name = "${division_name}_${cmdb_short_name}_OIDC_WA_${environment_upper}"
app_label = "${division_name}_${cmdb_short_name}_OIDC_WA_${environment_upper}"
grant_types = ["authorization_code", "refresh_token"]
redirect_uris = [
EOF
    if [[ -n "$redirect_uris" ]]; then
        echo "$redirect_uris" | tr ' ' '\n' | sed 's/^/  "/' | sed 's/$/",/' >> "$app_folder/3leg-backend.tfvars"
    fi
    cat >> "$app_folder/3leg-backend.tfvars" << EOF
]
response_types = ["code"]
token_endpoint_auth_method = "client_secret_basic"

group_name = "${division_name}_${cmdb_short_name}_WA_ACCESS_${environment_upper}"
group_description = "Access group for $cmdb_app_name Backend ($environment)"

trusted_origin_name = "${division_name}_${cmdb_short_name}_WA_ORIGIN_${environment_upper}"
trusted_origin_url = "https://$app_name_lower-${environment}.example.com"
trusted_origin_scopes = ["CORS", "REDIRECT"]

app_group_assignments = [
  {
    app_name = "${division_name}_${cmdb_short_name}_OIDC_WA_${environment_upper}"
    group_name = "${division_name}_${cmdb_short_name}_WA_ACCESS_${environment_upper}"
  }
]

bookmark_name = "${division_name}_${cmdb_short_name}_WA_BOOKMARK_${environment_upper}"
bookmark_label = "$cmdb_app_name Backend Admin ($environment)"
bookmark_url = "https://$app_name_lower-${environment}.example.com"
EOF
}

# Function to generate 3-leg native .tfvars
generate_3leg_native_tfvars() {
    local app_folder="$1"
    local app_name="$2"
    local cmdb_app_name="$3"
    local division_name="$4"
    local cmdb_short_name="$5"
    local environment="$6"
    local redirect_uris="$7"
    local post_logout_uris="$8"
    local trusted_origins="$9"
    local bookmarks="${10}"
    local app_name_lower=$(echo "$app_name" | tr '[:upper:]' '[:lower:]' | tr '_' '-')
    local environment_upper=$(echo "$environment" | tr '[:lower:]' '[:upper:]')
    cat > "$app_folder/3leg-native.tfvars" << EOF
# 3-leg Native Configuration for $cmdb_app_name ($environment)
app_name = "${division_name}_${cmdb_short_name}_OIDC_NA_${environment_upper}"
app_label = "${division_name}_${cmdb_short_name}_OIDC_NA_${environment_upper}"
grant_types = ["password", "refresh_token", "authorization_code"]
redirect_uris = [
EOF
    if [[ -n "$redirect_uris" ]]; then
        echo "$redirect_uris" | tr ' ' '\n' | sed 's/^/  "/' | sed 's/$/",/' >> "$app_folder/3leg-native.tfvars"
    fi
    cat >> "$app_folder/3leg-native.tfvars" << EOF
]
response_types = ["code"]
token_endpoint_auth_method = "client_secret_basic"

group_name = "${division_name}_${cmdb_short_name}_NA_ACCESS_${environment_upper}"
group_description = "Access group for $cmdb_app_name Native ($environment)"

trusted_origin_name = "${division_name}_${cmdb_short_name}_NA_ORIGIN_${environment_upper}"
trusted_origin_url = "https://$app_name_lower-${environment}.example.com"
trusted_origin_scopes = ["CORS", "REDIRECT"]

app_group_assignments = [
  {
    app_name = "${division_name}_${cmdb_short_name}_OIDC_NA_${environment_upper}"
    group_name = "${division_name}_${cmdb_short_name}_NA_ACCESS_${environment_upper}"
  }
]

bookmark_name = "${division_name}_${cmdb_short_name}_NA_BOOKMARK_${environment_upper}"
bookmark_label = "$cmdb_app_name Native Admin ($environment)"
bookmark_url = "https://$app_name_lower-${environment}.example.com"
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
    
    # Extract app name from folder structure
    local app_name=$(basename "$(dirname "$app_folder")")
    local environment=$(basename "$app_folder")
    
    # Define file paths using app-specific naming
    local config_file="$app_folder/${app_name}-${environment}.yaml"
    local metadata_file="$(dirname "$app_folder")/${app_name}-metadata.yaml"
    
    echo "🔍 Validating app configuration: $environment"
    echo ""
    
    # Validate folder structure
    if ! validate_folder_structure "$app_folder" "$config_file" "$metadata_file"; then
        exit 1
    fi
    
    echo ""
    
    # Validate YAML configuration
    if ! validate_yaml_config "$config_file" "$metadata_file"; then
        exit 1
    fi
    
    echo ""
    
    # Generate .tfvars files
    if command -v yq &> /dev/null; then
        generate_tfvars_from_yaml "$config_file" "$app_folder" "$metadata_file"
    else
        echo "⚠️  Skipping .tfvars generation (yq not available)"
    fi
    
    echo ""
    echo "🎉 Validation completed successfully!"
}

# Run main function
main "$@" 