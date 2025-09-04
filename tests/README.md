# Terraform Tests

This directory contains test cases for the Terraform module using Terraform's
native testing framework.

## Test Files

- **`unit_test.tftest.hcl`** - Unit tests that validate configuration without
  creating resources
  - Tests default values
  - Tests variable validation
  - Tests edge cases and conditional logic
  
- **`vpc_test.tftest.hcl`** - Comprehensive tests for VPC module
  functionality
  - Tests VPC configuration
  - Tests subnet creation and configuration  
  - Tests internet gateway setup
  - Tests routing configuration
  
- **`integration_test.tftest.hcl`** - Integration tests that actually create resources
  - Tests real resource creation in AWS
  - Validates resource relationships
  - Tests connectivity configuration

- **`validation_test.tftest.hcl`** - Input validation tests
  - Tests variable validation rules
  - Validates both positive and negative cases
  - Tests cross-validation between variables

## Running Tests

### Run All Tests

```bash
terraform test
```

### Run Specific Test File

```bash
terraform test -filter=tests/unit_test.tftest.hcl
terraform test -filter=tests/vpc_test.tftest.hcl
terraform test -filter=tests/validation_test.tftest.hcl
terraform test -filter=tests/integration_test.tftest.hcl
```

### Run Only Plan Tests (No Resource Creation)

```bash
terraform test -filter=tests/unit_test.tftest.hcl
terraform test -filter=tests/vpc_test.tftest.hcl
terraform test -filter=tests/validation_test.tftest.hcl
```

## Test Types

### Unit Tests (`command = plan`)

- Fast execution
- No AWS resources created
- Validates configuration logic
- Tests variable handling and defaults

### Integration Tests (`command = apply`)

- Slower execution
- Creates actual AWS resources
- Validates real-world functionality
- **Note**: Integration tests will incur AWS costs

## Prerequisites for Integration Tests

1. **AWS Credentials**: Ensure you have valid AWS credentials configured
2. **AWS Permissions**: Your credentials need permissions to create VPCs,
   subnets, IGWs, and route tables
3. **AWS Region**: Tests are configured for `us-west-2` region

## Customizing Tests for Your Module

When adapting these tests for your own module:

1. **Update variable values** in each test file to match your module's variables
2. **Modify assertions** to validate your module's specific resources and outputs
3. **Adjust provider configuration** if using a different cloud provider
4. **Update test scenarios** to cover your module's unique functionality

## Best Practices

- Keep unit tests fast by using `command = plan`
- Use integration tests sparingly due to cost and time
- Test both positive and negative scenarios
- Validate important resource attributes and relationships
- Include tests for optional features and edge cases
