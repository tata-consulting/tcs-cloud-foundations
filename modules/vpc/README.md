# TCS AWS VPC Module

Reusable Terraform module for provisioning a production-ready VPC with public/private subnet tiers, NAT gateways, and VPC flow logs. Designed for consistent multi-region deployments across TCS client accounts.

## Usage

```hcl
module "vpc" {
  source = "../../modules/vpc"

  vpc_name        = "tcs-client-prod"
  cidr_block      = "10.0.0.0/16"
  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.10.0/24", "10.0.11.0/24"]
  public_subnets  = ["10.0.0.0/24", "10.0.1.0/24"]

  enable_nat_gateway      = true
  single_nat_gateway      = false  # true for dev to reduce NAT costs
  enable_flow_log         = true
  flow_log_retention_days = 30

  tags = {
    Environment = "production"
    CostCenter  = "platform-001"
    Team        = "platform"
    ManagedBy   = "terraform"
    Project     = "tcs-cloud-foundations"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.3.0 |
| aws | ~> 5.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| vpc_name | Name of the VPC. Used as a prefix for all resource names. | `string` | n/a | yes |
| cidr_block | Primary IPv4 CIDR block for the VPC. | `string` | `"10.0.0.0/16"` | no |
| azs | List of Availability Zone names to deploy subnets into. | `list(string)` | n/a | yes |
| private_subnets | List of IPv4 CIDR blocks for private subnets. One per AZ. | `list(string)` | n/a | yes |
| public_subnets | List of IPv4 CIDR blocks for public subnets. One per AZ. | `list(string)` | n/a | yes |
| enable_nat_gateway | Whether to create NAT gateways for private subnet egress. | `bool` | `true` | no |
| single_nat_gateway | Use a single shared NAT gateway instead of one per AZ. Reduces cost for non-production. | `bool` | `false` | no |
| enable_flow_log | Whether to enable VPC flow logs to CloudWatch Logs. | `bool` | `true` | no |
| flow_log_retention_days | Number of days to retain VPC flow log data in CloudWatch Logs. | `number` | `30` | no |
| tags | Map of tags to apply to all resources. | `map(string)` | `{}` | no |

### Required TCS Tags

The following tags must be present in the `tags` variable for TCS compliance:

| Tag | Description |
|-----|-------------|
| `Environment` | e.g. `production`, `staging`, `development` |
| `CostCenter` | TCS cost center code |
| `Team` | Owning team |
| `ManagedBy` | Always `terraform` for IaC-managed resources |
| `Project` | Project identifier |

Optional tags: `DataClassification`, `BackupPolicy`.

## Outputs

| Name | Description |
|------|-------------|
| vpc_id | The ID of the VPC. |
| vpc_cidr_block | The primary IPv4 CIDR block of the VPC. |
| private_subnet_ids | List of IDs of the private subnets. |
| public_subnet_ids | List of IDs of the public subnets. |
| nat_gateway_ids | List of NAT gateway IDs. Empty when `enable_nat_gateway` is false. |
| private_route_table_ids | List of IDs of the private route tables. Needed for VPC endpoint route table associations. |

## NAT Gateway Modes

| `single_nat_gateway` | `enable_nat_gateway` | Behaviour |
|---------------------|---------------------|-----------|
| `false` | `true` | One NAT gateway per AZ (HA mode - recommended for production) |
| `true` | `true` | Single shared NAT gateway (cost-optimised for dev/staging) |
| n/a | `false` | No NAT gateways - private subnets have no internet egress |

## Flow Logs

When `enable_flow_log = true`, the module creates:
- A CloudWatch Log Group at `/aws/vpc/flow-logs/<vpc_name>`
- An IAM role named `<vpc_name>-flow-log-role` for the VPC flow log service principal
- A VPC flow log capturing ALL traffic (accepted and rejected)

The IAM role name includes `vpc_name` to prevent collision when this module is instantiated multiple times in the same account.
