run "test_valid_name" {
  command = plan

  variables {
    name = "valid-vpc-name"
  }

  assert {
    condition     = aws_vpc.example.tags.Name == "valid-vpc-name"
    error_message = "VPC should use valid name"
  }
}

run "test_invalid_name_starting_with_number" {
  command = plan
  
  variables {
    name = "1invalid-name"
  }

  expect_failures = [
    var.name,
  ]
}

run "test_invalid_name_ending_with_hyphen" {
  command = plan
  
  variables {
    name = "invalid-name-"
  }

  expect_failures = [
    var.name,
  ]
}

run "test_invalid_cidr_block" {
  command = plan
  
  variables {
    cidr_block = "invalid-cidr"
  }

  expect_failures = [
    var.cidr_block,
  ]
}

run "test_invalid_cidr_prefix_too_large" {
  command = plan
  
  variables {
    cidr_block = "10.0.0.0/30"
  }

  expect_failures = [
    var.cidr_block,
  ]
}

run "test_invalid_cidr_prefix_too_small" {
  command = plan
  
  variables {
    cidr_block = "10.0.0.0/7"
  }

  expect_failures = [
    var.cidr_block,
  ]
}

run "test_invalid_public_subnet_cidr" {
  command = plan
  
  variables {
    public_subnet_cidrs = ["invalid-cidr", "10.0.2.0/24"]
  }

  expect_failures = [
    var.public_subnet_cidrs,
  ]
}

run "test_invalid_availability_zone_format" {
  command = plan
  
  variables {
    availability_zones = ["invalid-az", "us-west-2b"]
  }

  expect_failures = [
    var.availability_zones,
  ]
}

run "test_reserved_tag_prefix" {
  command = plan
  
  variables {
    tags = {
      "aws:CreatedBy" = "terraform"
      "Environment"   = "test"
    }
  }

  expect_failures = [
    var.tags,
  ]
}

run "test_subnet_az_mismatch" {
  command = plan
  
  variables {
    public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
    availability_zones  = ["us-west-2a", "us-west-2b"]
  }

  expect_failures = [
    null_resource.validate_subnet_az_alignment,
  ]
}

run "test_valid_edge_cases" {
  command = plan

  variables {
    public_subnet_cidrs  = []
    private_subnet_cidrs = []
    availability_zones   = ["us-east-1a"]
    create_internet_gateway = false
  }

  assert {
    condition     = length(aws_subnet.public) == 0
    error_message = "Should create no public subnets when list is empty"
  }

  assert {
    condition     = length(aws_subnet.private) == 0
    error_message = "Should create no private subnets when list is empty"
  }
}