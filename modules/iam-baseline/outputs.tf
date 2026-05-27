output "readonly_role_arn" {
  description = "ARN of the ReadOnly IAM role."
  value       = aws_iam_role.readonly.arn
}

output "developer_role_arn" {
  description = "ARN of the Developer IAM role."
  value       = aws_iam_role.developer.arn
}

output "platform_engineer_role_arn" {
  description = "ARN of the PlatformEngineer IAM role."
  value       = aws_iam_role.platform_engineer.arn
}

output "cicd_role_arn" {
  description = "ARN of the CICD IAM role (assumed via GitHub Actions OIDC)."
  value       = aws_iam_role.cicd.arn
}

output "break_glass_role_arn" {
  description = "ARN of the BreakGlass IAM role. Handle with care - this role has AdministratorAccess."
  value       = aws_iam_role.break_glass.arn
}

output "github_actions_oidc_provider_arn" {
  description = "ARN of the GitHub Actions OIDC provider."
  value       = aws_iam_openid_connect_provider.github_actions.arn
}
