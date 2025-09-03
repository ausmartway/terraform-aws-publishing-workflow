# Terraform Cloud Private Module Registry Publishing Workflow

This repository demonstrates how to automatically publish Terraform modules to
Terraform Cloud's private module registry using GitHub Actions.

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
├── main.tf                           # Example Terraform module
├── variables.tf                      # Module variables
├── outputs.tf                       # Module outputs
├── README.md                         # Module documentation
└── INSTRUCTIONS.md                   # Setup and usage instructions
```

## Prerequisites

1. **Terraform Cloud Account**: You need access to a Terraform Cloud
   organization
2. **API Token**: Generate a user API token from Terraform Cloud
3. **Repository Naming**: Follow the naming convention
   `terraform-<PROVIDER>-<NAME>`
4. **Pre-commit (Optional)**: For local development with automatic
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
- `variables.tf` - Input variables
- `outputs.tf` - Output values
- `README.md` - Documentation

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
