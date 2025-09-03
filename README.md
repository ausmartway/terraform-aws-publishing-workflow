# terraform-aws-vpc

A Terraform module for creating AWS VPC infrastructure.

## Usage

```hcl
module "vpc" {
  source = "app.terraform.io/your-org/vpc/aws"
  
  name                     = "my-vpc"
  cidr_block               = "10.0.0.0/16"
  public_subnet_cidrs      = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs     = ["10.0.10.0/24", "10.0.20.0/24"]
  availability_zones       = ["us-west-2a", "us-west-2b"]
  
  tags = {
    Environment = "dev"
    Project     = "example"
  }
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_internet_gateway.example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_route_table.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_subnet.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| availability_zones | A list of availability zones in the region | `list(string)` | <pre>[<br>  "us-west-2a",<br>  "us-west-2b"<br>]</pre> | no |
| cidr_block | The CIDR block for the VPC | `string` | `"10.0.0.0/16"` | no |
| create_internet_gateway | Controls if an Internet Gateway is created for public subnets and the related routes that connect them | `bool` | `true` | no |
| enable_dns_hostnames | Should be true to enable DNS hostnames in the VPC | `bool` | `true` | no |
| enable_dns_support | Should be true to enable DNS support in the VPC | `bool` | `true` | no |
| name | Name to be used on all resources as identifier | `string` | `"example-vpc"` | no |
| private_subnet_cidrs | A list of private subnet CIDR blocks | `list(string)` | <pre>[<br>  "10.0.10.0/24",<br>  "10.0.20.0/24"<br>]</pre> | no |
| public_subnet_cidrs | A list of public subnet CIDR blocks | `list(string)` | <pre>[<br>  "10.0.1.0/24",<br>  "10.0.2.0/24"<br>]</pre> | no |
| tags | A map of tags to add to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| internet_gateway_id | The ID of the Internet Gateway |
| private_subnet_arns | List of ARNs of the private subnets |
| private_subnet_ids | List of IDs of the private subnets |
| public_route_table_id | ID of the public route table |
| public_subnet_arns | List of ARNs of the public subnets |
| public_subnet_ids | List of IDs of the public subnets |
| vpc_arn | The ARN of the VPC |
| vpc_cidr_block | The CIDR block of the VPC |
| vpc_id | ID of the VPC |
<!-- END_TF_DOCS -->