variables {
  name                     = "test-vpc"
  cidr_block               = "10.0.0.0/16"
  public_subnet_cidrs      = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs     = ["10.0.10.0/24", "10.0.20.0/24"]
  availability_zones       = ["us-west-2a", "us-west-2b"]
  create_internet_gateway  = true
  enable_dns_hostnames     = true
  enable_dns_support       = true
  
  tags = {
    Environment = "test"
    Project     = "terraform-test"
  }
}

run "valid_vpc_creation" {
  command = plan

  assert {
    condition     = aws_vpc.example.cidr_block == "10.0.0.0/16"
    error_message = "VPC CIDR block should be 10.0.0.0/16"
  }

  assert {
    condition     = aws_vpc.example.enable_dns_hostnames == true
    error_message = "DNS hostnames should be enabled"
  }

  assert {
    condition     = aws_vpc.example.enable_dns_support == true
    error_message = "DNS support should be enabled"
  }

  assert {
    condition     = aws_vpc.example.tags.Name == "test-vpc"
    error_message = "VPC should have correct name tag"
  }
}

run "public_subnets_configuration" {
  command = plan

  assert {
    condition     = length(aws_subnet.public) == 2
    error_message = "Should create 2 public subnets"
  }

  assert {
    condition     = aws_subnet.public[0].map_public_ip_on_launch == true
    error_message = "Public subnets should map public IP on launch"
  }

  assert {
    condition     = aws_subnet.public[0].tags.Type == "public"
    error_message = "Public subnets should have correct Type tag"
  }
}

run "private_subnets_configuration" {
  command = plan

  assert {
    condition     = length(aws_subnet.private) == 2
    error_message = "Should create 2 private subnets"
  }

  assert {
    condition     = aws_subnet.private[0].tags.Type == "private"
    error_message = "Private subnets should have correct Type tag"
  }
}

run "internet_gateway_configuration" {
  command = plan

  assert {
    condition     = length(aws_internet_gateway.example) == 1
    error_message = "Should create 1 internet gateway when enabled"
  }

  assert {
    condition     = aws_internet_gateway.example[0].tags.Name == "test-vpc-igw"
    error_message = "Internet gateway should have correct name tag"
  }
}

run "route_table_configuration" {
  command = plan

  assert {
    condition     = length(aws_route_table.public) == 1
    error_message = "Should create 1 public route table"
  }

  assert {
    condition     = length(aws_route_table_association.public) == 2
    error_message = "Should create 2 route table associations for public subnets"
  }
}

run "without_internet_gateway" {
  command = plan

  variables {
    create_internet_gateway = false
  }

  assert {
    condition     = length(aws_internet_gateway.example) == 0
    error_message = "Should not create internet gateway when disabled"
  }

  assert {
    condition     = length(aws_route_table.public) == 0
    error_message = "Should not create public route table when IGW disabled"
  }

  assert {
    condition     = length(aws_route_table_association.public) == 0
    error_message = "Should not create route table associations when IGW disabled"
  }
}