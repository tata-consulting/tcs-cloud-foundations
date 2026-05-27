variable "account_id" {
  description = "AWS account ID where the IAM roles are being created."
  type        = string
}

variable "environment" {
  description = "Environment name (e.g. production, staging, development). Used in role names and tags."
  type        = string
}

variable "github_org" {
  description = "GitHub organization name for OIDC trust on the CICD role."
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name (without org prefix) for OIDC trust on the CICD role."
  type        = string
}

variable "allowed_passrole_prefix" {
  description = "IAM role name prefix that the Developer role is permitted to pass. Defaults to 'tcs-' to cover TCS-managed Lambda execution roles."
  type        = string
  default     = "tcs-"
}

variable "enable_breakglass_alarm" {
  description = "Whether to create a CloudWatch alarm that fires when the BreakGlass role is assumed."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Map of tags to apply to all IAM resources."
  type        = map(string)
  default     = {}
}
