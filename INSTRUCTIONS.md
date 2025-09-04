# Terraform Cloud Private Module Registry Publishing Workflow

🚀 **This is a GitHub template repository!** Click "Use this template" to create
your own Terraform module with automated publishing to Terraform Cloud's
private registry.

This repository demonstrates how to automatically publish Terraform modules to
Terraform Cloud's private module registry using GitHub Actions.

## 🎯 Quick Start for Template Users

1. **Create from template**: Click "Use this template" button to create your repository
2. **Rename repository**: Follow naming convention `terraform-<PROVIDER>-<NAME>`
3. **Replace example module**: Delete the example VPC module files and add your own:
   - `main.tf` - Your module's main configuration
   - `variables.tf` - Input variables for your module
   - `versions.tf` - Version constrains for terraform and providers
   - `outputs.tf` - Output values from your module
4. **Configure secrets**: Add `TFC_TOKEN` and `TFC_ORGANIZATION` to repository secrets
5. **Test your module**: Run `terraform test` to validate your module
6. **Publish**: Push a version tag like `v1.0.0` to automatically publish

## Overview

This workflow enables automated publishing of Terraform modules to your
organization's private registry whenever you create a new version tag. The
module is packaged and uploaded directly to Terraform Cloud using the API,
bypassing VCS integration.

## Repository Structure

```text
.
├── .github/
│   ├── dependabot.yml                 # Dependabot configuration
│   └── workflows/
│       └── publish-terraform-module.yml # GitHub Actions workflow
├── .pre-commit-config.yaml            # Pre-commit configuration
├── .terraform-docs.yml                # terraform-docs configuration
├── main.tf                           # Example Terraform module (replace with yours)
├── variables.tf                      # Module variables (replace with yours)  
├── outputs.tf                       # Module outputs (replace with yours)
├── tests/                           # Terraform native tests
│   ├── unit_test.tftest.hcl         # Unit tests (plan only)
│   ├── vpc_test.tftest.hcl          # VPC functionality tests
│   ├── validation_test.tftest.hcl   # Input validation tests
│   ├── integration_test.tftest.hcl  # Integration tests (apply)
│   └── README.md                    # Testing documentation
├── README.md                         # Module documentation (auto-generated)
└── INSTRUCTIONS.md                   # Setup and usage instructions
```

## Prerequisites

1. **Terraform >= 1.9.0**: Required for native testing framework and input
   validation features
2. **Terraform Cloud Account**: You need access to a Terraform Cloud
   organization
3. **API Token**: Generate a user API token from Terraform Cloud
4. **Repository Naming**: Follow the naming convention
   `terraform-<PROVIDER>-<NAME>`
5. **Pre-commit (Optional)**: For local development with automatic
   documentation generation

## Setup Instructions

### 1. Repository Naming Convention

Your repository must follow the Terraform module naming convention:

```text
terraform-<PROVIDER>-<NAME>
```

Examples:

- `terraform-aws-vpc`
- `terraform-azurerm-network`
- `terraform-google-gke`

### 2. GitHub Secrets Configuration

Add the following secrets to your GitHub repository:

| Secret Name | Description | Example |
|-------------|-------------|---------|
| `TFC_TOKEN` | Your Terraform Cloud API token | `ATxxxxxxxxxxxxx.at...` |
| `TFC_ORGANIZATION` | Your Terraform Cloud organization name | `my-org` |

**To add secrets:**

1. Go to your repository on GitHub
2. Navigate to Settings → Secrets and variables → Actions
3. Click "New repository secret"
4. Add each secret with the appropriate name and value

### 3. Generate Terraform Cloud API Token

1. Log in to [Terraform Cloud](https://app.terraform.io)
2. Go to User Settings → Tokens
3. Click "Create an API token"
4. Give it a description and click "Create"
5. Copy the token and add it as the `TFC_TOKEN` secret

### 4. Pre-commit Setup (Optional)

For local development with automatic documentation generation and validation:

```bash
# Install pre-commit
pip install pre-commit

# Install the git hook scripts
pre-commit install

# (Optional) Run against all files
pre-commit run --all-files
```

The pre-commit hooks will automatically:

- Format Terraform code with `terraform fmt`
- Validate Terraform configuration
- Generate/update documentation with `terraform-docs`
- Run `tflint` checks for best practices and potential issues

### 5. Dependency Management

The repository includes Dependabot configuration to automatically:

- Monitor GitHub Actions for updates (weekly on Mondays)
- Monitor pre-commit hooks for updates (weekly on Mondays)
- Create pull requests for dependency updates
- Automatically assign you as a reviewer

Dependabot will create PRs for:

- terraform-docs version updates in GitHub Actions
- pre-commit-terraform hook updates
- Other GitHub Actions used in the workflow

## Usage

### Automatic Publishing (Recommended)

The workflow automatically triggers when you push a version tag:

```bash
# Create and push a version tag
git tag v1.0.0
git push origin v1.0.0
```

Supported tag formats:

- `v1.0.0` (with 'v' prefix)
- `1.0.0` (without prefix)
- `1.0.0-alpha.1` (pre-release)
- `1.0.0+build.1` (with build metadata)

### Manual Publishing

You can also trigger the workflow manually:

1. Go to the Actions tab in your GitHub repository
2. Select "Publish Terraform Module to Private Registry"
3. Click "Run workflow"
4. Enter the version and optionally enable force publish

## Workflow Details

The GitHub Actions workflow performs the following steps:

1. **Validation**: Checks required secrets and validates version format
2. **Module Information Extraction**: Parses provider and module name from
   repository name
3. **Terraform Validation**: Runs `terraform fmt -check` and `terraform validate`
4. **Module Packaging**: Creates a gzip tarball with module files
5. **Registry Operations**:
   - Creates module in private registry (if it doesn't exist)
   - Creates a new version
   - Uploads the module package

## Module Structure Requirements

Your module should follow standard Terraform module conventions:

- `main.tf` - Main configuration
- `variables.tf` - Input variables with comprehensive validation rules
- `outputs.tf` - Output values
- `README.md` - Documentation
- `tests/` - Test cases using Terraform's native testing framework

## Testing Your Module

This template includes comprehensive test cases using Terraform's native testing
framework. The tests are organized in the `tests/` directory:

### Test Types

- **Unit Tests** (`unit_test.tftest.hcl`) - Fast tests using `terraform plan`
  - Validate default values and variable handling
  - Test conditional logic and edge cases
  - No AWS resources created

- **Module Tests** (`vpc_test.tftest.hcl`) - Comprehensive module validation
  - Test all module functionality with `terraform plan`
  - Validate resource configuration and relationships
  - No AWS resources created

- **Integration Tests** (`integration_test.tftest.hcl`) - Real resource testing
  - Create actual AWS resources with `terraform apply`
  - Test resource functionality and connectivity
  - **Note**: These tests incur AWS costs

### Running Tests

```bash
# Run all tests
terraform test

# Run specific test file
terraform test -filter=tests/unit_test.tftest.hcl

# Run only plan-based tests (no resource creation)
terraform test -filter=tests/unit_test.tftest.hcl
terraform test -filter=tests/vpc_test.tftest.hcl
```

### Customizing Tests for Your Module

When replacing the example VPC module with your own:

1. Update test variables to match your module's inputs
2. Modify assertions to validate your specific resources
3. Add test cases for your module's unique functionality
4. Consider both positive and negative test scenarios

See `tests/README.md` for detailed testing documentation.

## Input Validation

This template includes comprehensive input validation using Terraform 1.9.0+
features to ensure reliable and secure module usage:

### Validation Rules Included

- **Resource Names**: Validates naming conventions and length constraints
- **CIDR Blocks**: Validates IPv4 CIDR notation and prefix ranges
- **Subnet Lists**: Validates CIDR format and count limits
- **Availability Zones**: Validates AWS AZ format and reasonable limits
- **Tags**: Validates tag key/value length and prevents AWS reserved prefixes
- **Cross-validation**: Ensures subnet counts match availability zone counts

### Example Validation

```hcl
variable "name" {
  validation {
    condition = can(regex("^[a-zA-Z][a-zA-Z0-9-]*[a-zA-Z0-9]$", var.name))
    error_message = "Name must start with a letter and contain only 
                     alphanumeric characters and hyphens."
  }
}
```

### Customizing Validation for Your Module

When adapting this template:

1. Update validation rules to match your module's specific requirements
2. Add domain-specific validation (e.g., port ranges, specific formats)
3. Include cross-validation between related variables
4. Test validation with both valid and invalid inputs

## Troubleshooting

### Common Issues

#### "Repository name does not follow terraform-PROVIDER-NAME convention"

- Ensure your repository name follows the exact pattern
- Provider and name should contain only lowercase letters, numbers, and
  underscores/hyphens

#### "TFC_TOKEN secret is not set"

- Verify the secret name is exactly `TFC_TOKEN`
- Ensure the token has appropriate permissions

#### "Version already exists"

- Use the manual workflow with "force_publish" enabled to overwrite
- Or increment the version number for a new release

#### "No upload URL received"

- Check if your API token has permissions to publish modules
- Verify your organization name is correct

### Debugging

Enable debug logging by adding this to your workflow run:

1. Go to Actions → Re-run workflow
2. Check "Enable debug logging"

## Advanced Configuration

### Custom File Exclusions

Modify the `tar` command in `.github/workflows/publish-terraform-module.yml`
to exclude additional files:

```bash
tar --exclude='.git' \
    --exclude='.github' \
    --exclude='*.tar.gz' \
    --exclude='.terraform' \
    --exclude='.env*' \
    --exclude='docs' \        # Exclude docs directory
    --exclude='examples' \    # Exclude examples
    -zcf module.tar.gz .
```

### Environment-Specific Configurations

You can configure different settings per environment by modifying the workflow
or using different secrets for different branches.

## Security Best Practices

- Never commit API tokens to the repository
- Use GitHub secrets for all sensitive information
- Regularly rotate your Terraform Cloud API tokens
- Limit API token permissions to only what's necessary

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test the module packaging locally
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for
details.
