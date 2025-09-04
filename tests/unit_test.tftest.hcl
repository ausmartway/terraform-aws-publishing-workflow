run "test_default_values" {
  command = plan

  assert {
    condition     = aws_vpc.example.cidr_block == "10.0.0.0/16"
    error_message = "Default CIDR should be 10.0.0.0/16"
  }

  assert {
    condition     = aws_vpc.example.enable_dns_hostnames == true
    error_message = "DNS hostnames should be enabled by default"
  }

  assert {
    condition     = aws_vpc.example.enable_dns_support == true
    error_message = "DNS support should be enabled by default"
  }

  assert {
    condition     = aws_vpc.example.tags.Name == "example-vpc"
    error_message = "Default VPC name should be example-vpc"
  }
}

run "test_custom_cidr" {
  command = plan

  variables {
    cidr_block = "192.168.0.0/16"
  }

  assert {
    condition     = aws_vpc.example.cidr_block == "192.168.0.0/16"
    error_message = "VPC should use custom CIDR block"
  }
}

run "test_no_public_subnets" {
  command = plan

  variables {
    public_subnet_cidrs = []
  }

  assert {
    condition     = length(aws_subnet.public) == 0
    error_message = "Should create no public subnets when list is empty"
  }

  assert {
    condition     = length(aws_route_table_association.public) == 0
    error_message = "Should create no route table associations when no public subnets"
  }
}

run "test_no_private_subnets" {
  command = plan

  variables {
    private_subnet_cidrs = []
  }

  assert {
    condition     = length(aws_subnet.private) == 0
    error_message = "Should create no private subnets when list is empty"
  }
}

run "test_dns_disabled" {
  command = plan

  variables {
    enable_dns_hostnames = false
    enable_dns_support   = false
  }

  assert {
    condition     = aws_vpc.example.enable_dns_hostnames == false
    error_message = "DNS hostnames should be disabled when set to false"
  }

  assert {
    condition     = aws_vpc.example.enable_dns_support == false
    error_message = "DNS support should be disabled when set to false"
  }
}

run "test_custom_tags" {
  command = plan

  variables {
    name = "custom-vpc"
    tags = {
      Environment = "staging"
      Owner       = "team-platform"
      CostCenter  = "engineering"
    }
  }

  assert {
    condition     = aws_vpc.example.tags.Name == "custom-vpc"
    error_message = "VPC should have custom name"
  }

  assert {
    condition     = aws_vpc.example.tags.Environment == "staging"
    error_message = "VPC should have custom Environment tag"
  }

  assert {
    condition     = aws_vpc.example.tags.Owner == "team-platform"
    error_message = "VPC should have custom Owner tag"
  }
}