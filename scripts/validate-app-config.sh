#!/bin/bash

# Script to validate deployed Okta app configurations
# This script checks if apps have the correct grant types based on their intended use

set -e

# Configuration
OKTA_ORG_URL="${OKTA_ORG_URL:-}"
OKTA_API_TOKEN="${OKTA_API_TOKEN:-}"

# Validation rules
declare -A VALIDATION_RULES
VALIDATION_RULES["2leg-api"]="client_credentials"
VALIDATION_RULES["3leg-spa"]="authorization_code,refresh_token"
VALIDATION_RULES["3leg-webapp"]="authorization_code,refresh_token"
VALIDATION_RULES["3leg-native"]="password,refresh_token"
VALIDATION_RULES["hybrid-spa-api"]="authorization_code,refresh_token,client_credentials"

# Function to show usage
show_usage() {
    echo "Usage: $0 <app_name> <app_type> [options]"
    echo ""
    echo "App Types:"
    echo "  2leg-api      - API service (client_credentials only)"
    echo "  3leg-spa      - SPA application (authorization_code + refresh_token only)"
    echo "  3leg-webapp   - Web application (authorization_code + refresh_token only)"
    echo "  3leg-native   - Native application (password + refresh_token only)"
    echo "  hybrid-spa-api - Hybrid app (authorization_code + refresh_token + client_credentials)"
    echo ""
    echo "Options:"
    echo "  --fix         - Automatically fix violations (remove invalid grant types)"
    echo "  --dry-run     - Show what would be changed without making changes"
    echo "  --verbose     - Show detailed information"
    echo ""
    echo "Environment Variables:"
    echo "  OKTA_ORG_URL  - Your Okta organization URL"
    echo "  OKTA_API_TOKEN - Your Okta API token"
    echo ""
    echo "Examples:"
    echo "  $0 my-api 2leg-api --dry-run"
    echo "  $0 my-spa 3leg-spa --fix"
    echo "  $0 my-hybrid hybrid-spa-api --verbose"
}

# Function to validate environment
validate_environment() {
    if [[ -z "$OKTA_ORG_URL" ]]; then
        echo "Error: OKTA_ORG_URL environment variable is required"
        exit 1
    fi
    
    if [[ -z "$OKTA_API_TOKEN" ]]; then
        echo "Error: OKTA_API_TOKEN environment variable is required"
        exit 1
    fi
}

# Function to get app by name
get_app_by_name() {
    local app_name="$1"
    
    # Search for app by name
    local app_id=$(curl -s -H "Authorization: SSWS $OKTA_API_TOKEN" \
        -H "Accept: application/json" \
        -H "Content-Type: application/json" \
        "$OKTA_ORG_URL/api/v1/apps?q=$app_name" | \
        jq -r '.[] | select(.name == "'$app_name'") | .id')
    
    if [[ -z "$app_id" ]] || [[ "$app_id" == "null" ]]; then
        echo "Error: App '$app_name' not found"
        return 1
    fi
    
    echo "$app_id"
}

# Function to get app configuration
get_app_config() {
    local app_id="$1"
    
    curl -s -H "Authorization: SSWS $OKTA_API_TOKEN" \
        -H "Accept: application/json" \
        -H "Content-Type: application/json" \
        "$OKTA_ORG_URL/api/v1/apps/$app_id" | jq '.'
}

# Function to validate grant types
validate_grant_types() {
    local app_config="$1"
    local app_type="$2"
    local app_name="$3"
    
    # Get current grant types
    local current_grant_types=$(echo "$app_config" | jq -r '.settings.oauthClient.grantTypes[]?' | sort | tr '\n' ',' | sed 's/,$//')
    
    # Get expected grant types
    local expected_grant_types="${VALIDATION_RULES[$app_type]}"
    
    if [[ -z "$expected_grant_types" ]]; then
        echo "Error: Unknown app type '$app_type'"
        return 1
    fi
    
    echo "App: $app_name"
    echo "Type: $app_type"
    echo "Current grant types: $current_grant_types"
    echo "Expected grant types: $expected_grant_types"
    echo ""
    
    # Check for violations
    local violations=()
    local current_array=($(echo "$current_grant_types" | tr ',' ' '))
    local expected_array=($(echo "$expected_grant_types" | tr ',' ' '))
    
    # Check for unexpected grant types
    for grant_type in "${current_array[@]}"; do
        if [[ ! " ${expected_array[@]} " =~ " ${grant_type} " ]]; then
            violations+=("Unexpected grant type: $grant_type")
        fi
    done
    
    # Check for missing required grant types
    for grant_type in "${expected_array[@]}"; do
        if [[ ! " ${current_array[@]} " =~ " ${grant_type} " ]]; then
            violations+=("Missing required grant type: $grant_type")
        fi
    done
    
    if [[ ${#violations[@]} -eq 0 ]]; then
        echo "✅ Validation passed: Grant types are correct"
        return 0
    else
        echo "❌ Validation failed:"
        for violation in "${violations[@]}"; do
            echo "  - $violation"
        done
        return 1
    fi
}

# Function to fix grant types
fix_grant_types() {
    local app_id="$1"
    local app_type="$2"
    local app_name="$3"
    local dry_run="$4"
    
    local expected_grant_types="${VALIDATION_RULES[$app_type]}"
    local grant_types_array=($(echo "$expected_grant_types" | tr ',' ' '))
    
    # Create JSON array for grant types
    local grant_types_json="["
    for i in "${!grant_types_array[@]}"; do
        if [[ $i -gt 0 ]]; then
            grant_types_json+=","
        fi
        grant_types_json+="\"${grant_types_array[$i]}\""
    done
    grant_types_json+="]"
    
    # Create update payload
    local update_payload=$(cat <<EOF
{
  "settings": {
    "oauthClient": {
      "grantTypes": $grant_types_json
    }
  }
}
EOF
)
    
    if [[ "$dry_run" == "true" ]]; then
        echo "🔍 Dry run - Would update app '$app_name' with grant types: $expected_grant_types"
        echo "Update payload:"
        echo "$update_payload" | jq '.'
    else
        echo "🔧 Fixing grant types for app '$app_name'..."
        local response=$(curl -s -X PUT \
            -H "Authorization: SSWS $OKTA_API_TOKEN" \
            -H "Accept: application/json" \
            -H "Content-Type: application/json" \
            -d "$update_payload" \
            "$OKTA_ORG_URL/api/v1/apps/$app_id")
        
        if echo "$response" | jq -e '.errorSummary' > /dev/null; then
            echo "❌ Error updating app:"
            echo "$response" | jq -r '.errorSummary'
            return 1
        else
            echo "✅ Successfully updated app '$app_name'"
        fi
    fi
}

# Main execution
main() {
    local app_name=""
    local app_type=""
    local fix_mode=false
    local dry_run=false
    local verbose=false
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --help|-h)
                show_usage
                exit 0
                ;;
            --fix)
                fix_mode=true
                shift
                ;;
            --dry-run)
                dry_run=true
                shift
                ;;
            --verbose)
                verbose=true
                shift
                ;;
            *)
                if [[ -z "$app_name" ]]; then
                    app_name="$1"
                elif [[ -z "$app_type" ]]; then
                    app_type="$1"
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
    if [[ -z "$app_name" ]] || [[ -z "$app_type" ]]; then
        echo "Error: Missing required parameters"
        show_usage
        exit 1
    fi
    
    # Validate environment
    validate_environment
    
    echo "🔍 Validating app configuration..."
    echo "App: $app_name"
    echo "Type: $app_type"
    echo ""
    
    # Get app ID
    local app_id=$(get_app_by_name "$app_name")
    if [[ $? -ne 0 ]]; then
        exit 1
    fi
    
    # Get app configuration
    local app_config=$(get_app_config "$app_id")
    
    if [[ "$verbose" == "true" ]]; then
        echo "📋 App Configuration:"
        echo "$app_config" | jq '.'
        echo ""
    fi
    
    # Validate grant types
    if validate_grant_types "$app_config" "$app_type" "$app_name"; then
        echo "🎉 All validations passed!"
        exit 0
    else
        if [[ "$fix_mode" == "true" ]]; then
            echo ""
            fix_grant_types "$app_id" "$app_type" "$app_name" "$dry_run"
        else
            echo ""
            echo "💡 To fix violations, run:"
            echo "  $0 $app_name $app_type --fix"
            echo ""
            echo "💡 To see what would be changed:"
            echo "  $0 $app_name $app_type --fix --dry-run"
            exit 1
        fi
    fi
}

# Run main function
main "$@" 