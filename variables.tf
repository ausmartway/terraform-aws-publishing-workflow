variable "name" {
  description = "Name to be used on all resources as identifier"
  type        = string
  default     = "example-vpc"
  
  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-]*[a-zA-Z0-9]$", var.name)) && length(var.name) >= 2 && length(var.name) <= 255
    error_message = "Name must start with a letter, contain only alphanumeric characters and hyphens, end with alphanumeric character, and be 2-255 characters long."
  }
}

variable "cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
  
  validation {
    condition     = can(cidrhost(var.cidr_block, 0))
    error_message = "CIDR block must be a valid IPv4 CIDR notation (e.g., 10.0.0.0/16)."
  }
  
  validation {
    condition = alltrue([
      tonumber(split("/", var.cidr_block)[1]) >= 8,
      tonumber(split("/", var.cidr_block)[1]) <= 28
    ])
    error_message = "CIDR block prefix must be between /8 and /28."
  }
}

variable "enable_dns_hostnames" {
  description = "Should be true to enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Should be true to enable DNS support in the VPC"
  type        = bool
  default     = true
}

variable "create_internet_gateway" {
  description = "Controls if an Internet Gateway is created for public subnets and the related routes that connect them"
  type        = bool
  default     = true
}

variable "public_subnet_cidrs" {
  description = "A list of public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
  
  validation {
    condition = alltrue([
      for cidr in var.public_subnet_cidrs : can(cidrhost(cidr, 0))
    ])
    error_message = "All public subnet CIDR blocks must be valid IPv4 CIDR notation."
  }
  
  validation {
    condition     = length(var.public_subnet_cidrs) <= 16
    error_message = "Maximum of 16 public subnets are allowed."
  }
}

variable "private_subnet_cidrs" {
  description = "A list of private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24"]
  
  validation {
    condition = alltrue([
      for cidr in var.private_subnet_cidrs : can(cidrhost(cidr, 0))
    ])
    error_message = "All private subnet CIDR blocks must be valid IPv4 CIDR notation."
  }
  
  validation {
    condition     = length(var.private_subnet_cidrs) <= 16
    error_message = "Maximum of 16 private subnets are allowed."
  }
}

variable "availability_zones" {
  description = "A list of availability zones in the region"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b"]
  
  validation {
    condition     = length(var.availability_zones) > 0 && length(var.availability_zones) <= 16
    error_message = "Must specify between 1 and 16 availability zones."
  }
  
  validation {
    condition = alltrue([
      for az in var.availability_zones : can(regex("^[a-z]{2}-[a-z]+-[0-9]+[a-z]$", az))
    ])
    error_message = "Availability zones must be in valid AWS format (e.g., us-west-2a)."
  }
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
  
  validation {
    condition = alltrue([
      for key, value in var.tags : length(key) <= 128 && length(value) <= 256
    ])
    error_message = "Tag keys must be 128 characters or less, tag values must be 256 characters or less."
  }
  
  validation {
    condition = alltrue([
      for key in keys(var.tags) : !startswith(key, "aws:") && !startswith(key, "AWS:")
    ])
    error_message = "Tag keys cannot start with 'aws:' or 'AWS:' as these are reserved for AWS use."
  }
}

# Cross-validation checks
locals {
  # Validate subnet count matches AZ count
  public_subnet_count  = length(var.public_subnet_cidrs)
  private_subnet_count = length(var.private_subnet_cidrs)
  az_count             = length(var.availability_zones)
  
  # Validation: If subnets are defined, they should match AZ count
  subnet_az_validation = alltrue([
    local.public_subnet_count == 0 || local.public_subnet_count == local.az_count,
    local.private_subnet_count == 0 || local.private_subnet_count == local.az_count
  ])
}

# Cross-validation assertion
resource "null_resource" "validate_subnet_az_alignment" {
  count = local.subnet_az_validation ? 0 : 1
  
  lifecycle {
    precondition {
      condition = local.subnet_az_validation
      error_message = "The number of public and private subnet CIDRs must match the number of availability zones, or be empty."
    }
  }
}