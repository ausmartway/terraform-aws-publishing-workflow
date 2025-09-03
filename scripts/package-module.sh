#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

MODULE_NAME=""
PROVIDER=""
VERSION=""
OUTPUT_FILE="module.tar.gz"

usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Package a Terraform module for upload to Terraform Cloud private registry"
    echo ""
    echo "Options:"
    echo "  -n, --name NAME      Module name"
    echo "  -p, --provider PROVIDER  Provider name"
    echo "  -v, --version VERSION    Module version (semantic versioning)"
    echo "  -o, --output FILE    Output file name (default: module.tar.gz)"
    echo "  -h, --help          Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 -n vpc -p aws -v 1.0.0"
    echo "  $0 --name vpc --provider aws --version 1.0.0 --output my-module.tar.gz"
}

validate_version() {
    local version=$1
    if ! echo "$version" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z-]+(\.[0-9A-Za-z-]+)*)?(\+[0-9A-Za-z-]+(\.[0-9A-Za-z-]+)*)?$'; then
        echo "Error: Version '$version' is not a valid semantic version" >&2
        echo "Valid examples: 1.0.0, 1.0.0-alpha.1, 1.0.0+build.1" >&2
        return 1
    fi
}

validate_name() {
    local name=$1
    if ! echo "$name" | grep -qE '^[a-z0-9_-]+$'; then
        echo "Error: Module name '$name' contains invalid characters" >&2
        echo "Module names must contain only lowercase letters, numbers, hyphens, and underscores" >&2
        return 1
    fi
}

validate_provider() {
    local provider=$1
    if ! echo "$provider" | grep -qE '^[a-z0-9_]+$'; then
        echo "Error: Provider name '$provider' contains invalid characters" >&2
        echo "Provider names must contain only lowercase letters, numbers, and underscores" >&2
        return 1
    fi
}

check_terraform_files() {
    if [ ! -f "main.tf" ] && [ ! -f "variables.tf" ] && [ ! -f "outputs.tf" ]; then
        echo "Warning: No standard Terraform files (main.tf, variables.tf, outputs.tf) found in current directory" >&2
    fi
}

create_package() {
    local output_file=$1
    
    echo "Creating module package..."
    echo "Working directory: $(pwd)"
    
    check_terraform_files
    
    if [ -f "$output_file" ]; then
        echo "Removing existing package: $output_file"
        rm "$output_file"
    fi
    
    echo "Creating tarball with module files..."
    
    tar --exclude='.git' \
        --exclude='.github' \
        --exclude='*.tar.gz' \
        --exclude='*.tgz' \
        --exclude='.terraform' \
        --exclude='.terraform.lock.hcl' \
        --exclude='.env*' \
        --exclude='scripts' \
        --exclude='.DS_Store' \
        --exclude='Thumbs.db' \
        --exclude='.vscode' \
        --exclude='.idea' \
        -zcf "$output_file" .
    
    if [ $? -eq 0 ]; then
        echo "Package created successfully: $output_file"
        echo "Package size: $(du -h "$output_file" | cut -f1)"
        
        echo ""
        echo "Package contents (first 20 files):"
        tar -tzf "$output_file" | head -20
        
        echo ""
        echo "Package is ready for upload to Terraform Cloud private registry"
    else
        echo "Error: Failed to create package" >&2
        return 1
    fi
}

while [[ $# -gt 0 ]]; do
    case $1 in
        -n|--name)
            MODULE_NAME="$2"
            shift 2
            ;;
        -p|--provider)
            PROVIDER="$2"
            shift 2
            ;;
        -v|--version)
            VERSION="$2"
            shift 2
            ;;
        -o|--output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            usage
            exit 1
            ;;
    esac
done

cd "$PROJECT_ROOT"

if [ -n "$MODULE_NAME" ]; then
    validate_name "$MODULE_NAME"
fi

if [ -n "$PROVIDER" ]; then
    validate_provider "$PROVIDER"
fi

if [ -n "$VERSION" ]; then
    validate_version "$VERSION"
fi

create_package "$OUTPUT_FILE"

echo ""
echo "Module packaging completed successfully!"

if [ -n "$MODULE_NAME" ] && [ -n "$PROVIDER" ] && [ -n "$VERSION" ]; then
    echo ""
    echo "Module Information:"
    echo "  Name: $MODULE_NAME"
    echo "  Provider: $PROVIDER"  
    echo "  Version: $VERSION"
    echo "  Package: $OUTPUT_FILE"
fi