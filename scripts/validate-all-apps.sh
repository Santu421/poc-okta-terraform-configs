#!/bin/bash

# Script to validate all deployed Okta apps
# This script checks all apps and validates their grant types based on app type

set -e

# Configuration
OKTA_ORG_URL="${OKTA_ORG_URL:-}"
OKTA_API_TOKEN="${OKTA_API_TOKEN:-}"

# App type mapping (you can customize this based on your naming conventions)
declare -A APP_TYPE_MAPPING

# Function to load app type mapping from file
load_app_type_mapping() {
    local mapping_file="app-type-mapping.txt"
    
    if [[ -f "$mapping_file" ]]; then
        echo "📋 Loading app type mapping from $mapping_file..."
        while IFS='=' read -r app_name app_type; do
            # Skip comments and empty lines
            [[ "$app_name" =~ ^#.*$ ]] && continue
            [[ -z "$app_name" ]] && continue
            
            APP_TYPE_MAPPING["$app_name"]="$app_type"
        done < "$mapping_file"
    else
        echo "⚠️  No app type mapping file found. Creating default mapping based on naming conventions..."
        create_default_mapping
    fi
}

# Function to create default mapping based on naming conventions
create_default_mapping() {
    # Get all apps from Okta
    local apps=$(curl -s -H "Authorization: SSWS $OKTA_API_TOKEN" \
        -H "Accept: application/json" \
        -H "Content-Type: application/json" \
        "$OKTA_ORG_URL/api/v1/apps" | jq -r '.[].name')
    
    for app_name in $apps; do
        # Apply naming convention rules
        if [[ "$app_name" =~ -api$ ]] || [[ "$app_name" =~ _api$ ]]; then
            APP_TYPE_MAPPING["$app_name"]="2leg-api"
        elif [[ "$app_name" =~ -spa$ ]] || [[ "$app_name" =~ _spa$ ]]; then
            APP_TYPE_MAPPING["$app_name"]="3leg-spa"
        elif [[ "$app_name" =~ -web$ ]] || [[ "$app_name" =~ _web$ ]] || [[ "$app_name" =~ -webapp$ ]]; then
            APP_TYPE_MAPPING["$app_name"]="3leg-webapp"
        elif [[ "$app_name" =~ -hybrid$ ]] || [[ "$app_name" =~ _hybrid$ ]]; then
            APP_TYPE_MAPPING["$app_name"]="hybrid-spa-api"
        else
            # Default to web app for unknown patterns
            APP_TYPE_MAPPING["$app_name"]="3leg-webapp"
        fi
    done
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  --fix         - Automatically fix violations"
    echo "  --dry-run     - Show what would be changed without making changes"
    echo "  --verbose     - Show detailed information"
    echo "  --create-mapping - Create app type mapping file"
    echo "  --apps <list> - Comma-separated list of specific apps to validate"
    echo ""
    echo "Environment Variables:"
    echo "  OKTA_ORG_URL  - Your Okta organization URL"
    echo "  OKTA_API_TOKEN - Your Okta API token"
    echo ""
    echo "Examples:"
    echo "  $0 --dry-run"
    echo "  $0 --fix --verbose"
    echo "  $0 --apps app1,app2,app3"
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

# Function to create app type mapping file
create_mapping_file() {
    local mapping_file="app-type-mapping.txt"
    
    echo "📝 Creating app type mapping file..."
    echo "# App Type Mapping File" > "$mapping_file"
    echo "# Format: app_name=app_type" >> "$mapping_file"
    echo "# App types: 2leg-api, 3leg-spa, 3leg-webapp, hybrid-spa-api" >> "$mapping_file"
    echo "" >> "$mapping_file"
    
    # Get all apps from Okta
    local apps=$(curl -s -H "Authorization: SSWS $OKTA_API_TOKEN" \
        -H "Accept: application/json" \
        -H "Content-Type: application/json" \
        "$OKTA_ORG_URL/api/v1/apps" | jq -r '.[].name')
    
    for app_name in $apps; do
        # Apply naming convention rules
        if [[ "$app_name" =~ -api$ ]] || [[ "$app_name" =~ _api$ ]]; then
            echo "$app_name=2leg-api" >> "$mapping_file"
        elif [[ "$app_name" =~ -spa$ ]] || [[ "$app_name" =~ _spa$ ]]; then
            echo "$app_name=3leg-spa" >> "$mapping_file"
        elif [[ "$app_name" =~ -web$ ]] || [[ "$app_name" =~ _web$ ]] || [[ "$app_name" =~ -webapp$ ]]; then
            echo "$app_name=3leg-webapp" >> "$mapping_file"
        elif [[ "$app_name" =~ -hybrid$ ]] || [[ "$app_name" =~ _hybrid$ ]]; then
            echo "$app_name=hybrid-spa-api" >> "$mapping_file"
        else
            # Default to web app for unknown patterns
            echo "$app_name=3leg-webapp" >> "$mapping_file"
        fi
    done
    
    echo "✅ Created mapping file: $mapping_file"
    echo "📝 Please review and edit the file to ensure correct app types"
}

# Function to validate a single app
validate_single_app() {
    local app_name="$1"
    local app_type="$2"
    local fix_mode="$3"
    local dry_run="$4"
    local verbose="$5"
    
    echo "🔍 Validating app: $app_name (type: $app_type)"
    
    # Call the single app validation script
    if ./scripts/validate-app-config.sh "$app_name" "$app_type" \
        $([[ "$fix_mode" == "true" ]] && echo "--fix") \
        $([[ "$dry_run" == "true" ]] && echo "--dry-run") \
        $([[ "$verbose" == "true" ]] && echo "--verbose"); then
        echo "✅ $app_name: PASSED"
        return 0
    else
        echo "❌ $app_name: FAILED"
        return 1
    fi
}

# Main execution
main() {
    local fix_mode=false
    local dry_run=false
    local verbose=false
    local create_mapping=false
    local specific_apps=""
    
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
            --create-mapping)
                create_mapping=true
                shift
                ;;
            --apps)
                specific_apps="$2"
                shift 2
                ;;
            *)
                echo "Error: Unknown parameter $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    # Validate environment
    validate_environment
    
    # Create mapping file if requested
    if [[ "$create_mapping" == "true" ]]; then
        create_mapping_file
        exit 0
    fi
    
    echo "🔍 Starting bulk app validation..."
    echo ""
    
    # Load app type mapping
    load_app_type_mapping
    
    # Determine which apps to validate
    local apps_to_validate=""
    
    if [[ -n "$specific_apps" ]]; then
        # Use specific apps provided
        apps_to_validate=$(echo "$specific_apps" | tr ',' ' ')
    else
        # Use all apps from mapping
        apps_to_validate="${!APP_TYPE_MAPPING[@]}"
    fi
    
    # Validation counters
    local total_apps=0
    local passed_apps=0
    local failed_apps=0
    
    # Validate each app
    for app_name in $apps_to_validate; do
        local app_type="${APP_TYPE_MAPPING[$app_name]}"
        
        if [[ -z "$app_type" ]]; then
            echo "⚠️  Skipping $app_name: No app type mapping found"
            continue
        fi
        
        ((total_apps++))
        
        if validate_single_app "$app_name" "$app_type" "$fix_mode" "$dry_run" "$verbose"; then
            ((passed_apps++))
        else
            ((failed_apps++))
        fi
        
        echo ""
    done
    
    # Summary
    echo "📊 Validation Summary:"
    echo "  Total apps: $total_apps"
    echo "  Passed: $passed_apps"
    echo "  Failed: $failed_apps"
    echo ""
    
    if [[ $failed_apps -eq 0 ]]; then
        echo "🎉 All apps passed validation!"
        exit 0
    else
        echo "❌ $failed_apps app(s) failed validation"
        if [[ "$fix_mode" != "true" ]]; then
            echo "💡 Run with --fix to automatically fix violations"
        fi
        exit 1
    fi
}

# Run main function
main "$@" 