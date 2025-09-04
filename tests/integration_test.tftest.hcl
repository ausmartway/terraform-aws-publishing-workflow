variables {
  name                = "integration-test-vpc"
  cidr_block          = "172.16.0.0/16"
  public_subnet_cidrs = ["172.16.1.0/24"]
  private_subnet_cidrs = ["172.16.10.0/24"]
  availability_zones  = ["us-west-2a"]
  
  tags = {
    Environment = "test"
    TestType    = "integration"
  }
}

provider "aws" {
  region = "us-west-2"
}

run "integration_test_vpc_creation" {
  command = apply

  assert {
    condition     = can(aws_vpc.example.id)
    error_message = "VPC should be created successfully"
  }

  assert {
    condition     = aws_vpc.example.cidr_block == "172.16.0.0/16"
    error_message = "VPC should have the correct CIDR block"
  }

  assert {
    condition     = length(aws_subnet.public) == 1
    error_message = "Should create 1 public subnet"
  }

  assert {
    condition     = length(aws_subnet.private) == 1
    error_message = "Should create 1 private subnet"
  }

  assert {
    condition     = can(aws_internet_gateway.example[0].id)
    error_message = "Internet gateway should be created"
  }
}

run "validate_vpc_connectivity" {
  command = apply

  assert {
    condition     = aws_route_table.public[0].route[0].cidr_block == "0.0.0.0/0"
    error_message = "Public route table should have default route to IGW"
  }

  assert {
    condition     = aws_route_table.public[0].route[0].gateway_id == aws_internet_gateway.example[0].id
    error_message = "Default route should point to the internet gateway"
  }
}

run "validate_subnet_associations" {
  command = apply

  assert {
    condition     = aws_route_table_association.public[0].subnet_id == aws_subnet.public[0].id
    error_message = "Public subnet should be associated with public route table"
  }

  assert {
    condition     = aws_route_table_association.public[0].route_table_id == aws_route_table.public[0].id
    error_message = "Route table association should reference the correct route table"
  }
}