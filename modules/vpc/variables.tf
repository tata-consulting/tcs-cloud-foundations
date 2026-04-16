variable "vpc_name" {
  description = "Name of the VPC. Used as a prefix for all resource names."
  type        = string
}

variable "cidr_block" {
  description = "Primary IPv4 CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "List of Availability Zone names to deploy subnets into (e.g. [\"us-east-1a\", \"us-east-1b\"])."
  type        = list(string)
}

variable "private_subnets" {
  description = "List of IPv4 CIDR blocks for private subnets. One per AZ."
  type        = list(string)
}

variable "public_subnets" {
  description = "List of IPv4 CIDR blocks for public subnets. One per AZ."
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "Whether to create NAT gateways for private subnet egress."
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use a single shared NAT gateway instead of one per AZ. Reduces cost for non-production environments."
  type        = bool
  default     = false
}

variable "enable_flow_log" {
  description = "Whether to enable VPC flow logs to CloudWatch Logs."
  type        = bool
  default     = true
}

variable "flow_log_retention_days" {
  description = "Number of days to retain VPC flow log data in CloudWatch Logs."
  type        = number
  default     = 30
}

variable "tags" {
  description = "Map of tags to apply to all resources. Expected TCS tags: Environment, CostCenter, Team, ManagedBy, Project."
  type        = map(string)
  default     = {}
}
