output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.example.id
}

output "vpc_arn" {
  description = "The ARN of the VPC"
  value       = aws_vpc.example.arn
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.example.cidr_block
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = var.create_internet_gateway ? aws_internet_gateway.example[0].id : null
}

output "public_subnet_ids" {
  description = "List of IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "List of IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

output "public_subnet_arns" {
  description = "List of ARNs of the public subnets"
  value       = aws_subnet.public[*].arn
}

output "private_subnet_arns" {
  description = "List of ARNs of the private subnets"
  value       = aws_subnet.private[*].arn
}

output "public_route_table_id" {
  description = "ID of the public route table"
  value       = var.create_internet_gateway && length(var.public_subnet_cidrs) > 0 ? aws_route_table.public[0].id : null
}