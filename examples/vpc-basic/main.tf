terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Basic VPC for a development environment.
# Uses single_nat_gateway = true to reduce NAT costs in non-production.
module "vpc" {
  source = "../../modules/vpc"

  vpc_name        = "tcs-example-dev"
  cidr_block      = "10.0.0.0/16"
  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.10.0/24", "10.0.11.0/24"]
  public_subnets  = ["10.0.0.0/24", "10.0.1.0/24"]

  # Single NAT saves ~$32/month per AZ in dev. Use single_nat_gateway = false in production.
  enable_nat_gateway      = true
  single_nat_gateway      = true
  enable_flow_log         = true
  flow_log_retention_days = 7

  tags = {
    Environment = "development"
    CostCenter  = "platform-001"
    Team        = "platform"
    ManagedBy   = "terraform"
    Project     = "tcs-cloud-foundations"
  }
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}
