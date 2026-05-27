output "vpc_id" {
  description = "The ID of the VPC."
  value       = aws_vpc.this.id
}

output "vpc_cidr_block" {
  description = "The primary IPv4 CIDR block of the VPC."
  value       = aws_vpc.this.cidr_block
}

output "private_subnet_ids" {
  description = "List of IDs of the private subnets."
  value       = aws_subnet.private[*].id
}

output "public_subnet_ids" {
  description = "List of IDs of the public subnets."
  value       = aws_subnet.public[*].id
}

output "nat_gateway_ids" {
  description = "List of NAT gateway IDs. Empty when enable_nat_gateway is false."
  value       = aws_nat_gateway.this[*].id
}

output "private_route_table_ids" {
  description = "List of IDs of the private route tables. Used by callers attaching VPC endpoints."
  value       = aws_route_table.private[*].id
}
