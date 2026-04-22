locals {
  mfa_condition = {
    Bool = {
      "aws:MultiFactorAuthPresent" = "true"
    }
  }

  account_trust_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { AWS = "arn:aws:iam::${var.account_id}:root" }
      Action    = "sts:AssumeRole"
      Condition = local.mfa_condition
    }]
  })
}

# ------------------------------------------------------------
# ReadOnly Role
# ------------------------------------------------------------
resource "aws_iam_role" "readonly" {
  name                 = "tcs-${var.environment}-readonly"
  max_session_duration = 3600
  assume_role_policy   = local.account_trust_policy

  tags = merge(var.tags, {
    Name      = "tcs-${var.environment}-readonly"
    ManagedBy = "terraform"
  })
}

resource "aws_iam_role_policy_attachment" "readonly" {
  role       = aws_iam_role.readonly.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

# ------------------------------------------------------------
# Developer Role
# ------------------------------------------------------------
resource "aws_iam_role" "developer" {
  name                 = "tcs-${var.environment}-developer"
  max_session_duration = 3600
  assume_role_policy   = local.account_trust_policy

  tags = merge(var.tags, {
    Name      = "tcs-${var.environment}-developer"
    ManagedBy = "terraform"
  })
}

resource "aws_iam_role_policy" "developer_inline" {
  name = "tcs-${var.environment}-developer-policy"
  role = aws_iam_role.developer.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowWorkloadServices"
        Effect = "Allow"
        Action = [
          "ec2:Describe*",
          "ec2:Get*",
          "ec2:List*",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "lambda:*",
          "rds:Describe*",
          "rds:ListTagsForResource",
          "logs:*",
          "cloudwatch:*",
          "xray:*"
        ]
        Resource = "*"
      },
      {
        Sid    = "AllowPassRoleTCSExecRoles"
        Effect = "Allow"
        Action = "iam:PassRole"
        Resource = "arn:aws:iam::${var.account_id}:role/${var.allowed_passrole_prefix}*"
        Condition = {
          StringEquals = {
            "iam:PassedToService" = "lambda.amazonaws.com"
          }
        }
      },
      {
        Sid    = "DenyIAM"
        Effect = "Deny"
        Action = [
          "iam:Create*",
          "iam:Delete*",
          "iam:Update*",
          "iam:Attach*",
          "iam:Detach*",
          "iam:Put*",
          "iam:Add*",
          "iam:Remove*",
          "iam:Set*",
          "iam:Tag*",
          "iam:Untag*"
        ]
        Resource = "*"
      },
      {
        Sid      = "DenyBilling"
        Effect   = "Deny"
        Action   = ["aws-portal:*", "budgets:*", "ce:*", "cur:*", "pricing:*"]
        Resource = "*"
      }
    ]
  })
}

# ------------------------------------------------------------
# PlatformEngineer Role
# ------------------------------------------------------------
resource "aws_iam_role" "platform_engineer" {
  name                 = "tcs-${var.environment}-platform-engineer"
  max_session_duration = 7200
  assume_role_policy   = local.account_trust_policy

  tags = merge(var.tags, {
    Name      = "tcs-${var.environment}-platform-engineer"
    ManagedBy = "terraform"
  })
}

resource "aws_iam_role_policy_attachment" "platform_engineer_power" {
  role       = aws_iam_role.platform_engineer.name
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}

resource "aws_iam_role_policy" "platform_engineer_deny_org" {
  name = "tcs-${var.environment}-platform-engineer-deny-org"
  role = aws_iam_role.platform_engineer.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "DenyOrgAndAccountManagement"
      Effect = "Deny"
      Action = [
        "organizations:*",
        "account:*",
        "aws-portal:*"
      ]
      Resource = "*"
    }]
  })
}

# ------------------------------------------------------------
# CICD Role (GitHub Actions OIDC)
# ------------------------------------------------------------
resource "aws_iam_openid_connect_provider" "github_actions" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = ["sts.amazonaws.com"]

  # Thumbprint for token.actions.githubusercontent.com (rotate if GitHub rotates their cert)
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]

  tags = merge(var.tags, {
    Name      = "github-actions-oidc"
    ManagedBy = "terraform"
  })
}

resource "aws_iam_role" "cicd" {
  name                 = "tcs-${var.environment}-cicd"
  max_session_duration = 3600

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.github_actions.arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringLike = {
          "token.actions.githubusercontent.com:sub" = "repo:${var.github_org}/${var.github_repo}:*"
        }
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })

  tags = merge(var.tags, {
    Name      = "tcs-${var.environment}-cicd"
    ManagedBy = "terraform"
  })
}

resource "aws_iam_role_policy" "cicd_inline" {
  name = "tcs-${var.environment}-cicd-policy"
  role = aws_iam_role.cicd.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCICDDeployment"
        Effect = "Allow"
        Action = [
          "ec2:Describe*",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket",
          "lambda:*",
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecs:RegisterTaskDefinition",
          "ecs:UpdateService",
          "ecs:DescribeServices",
          "ecs:DescribeTaskDefinition"
        ]
        Resource = "*"
      }
    ]
  })
}

# ------------------------------------------------------------
# BreakGlass Role
# ------------------------------------------------------------
resource "aws_iam_role" "break_glass" {
  name                 = "tcs-${var.environment}-break-glass"
  max_session_duration = 3600

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { AWS = "arn:aws:iam::${var.account_id}:root" }
      Action    = "sts:AssumeRole"
      Condition = {
        Bool = {
          "aws:MultiFactorAuthPresent" = "true"
        }
        NumericLessThanEquals = {
          "aws:MultiFactorAuthAge" = "900"
        }
      }
    }]
  })

  tags = merge(var.tags, {
    Name      = "tcs-${var.environment}-break-glass"
    ManagedBy = "terraform"
  })
}

resource "aws_iam_role_policy_attachment" "break_glass_admin" {
  role       = aws_iam_role.break_glass.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# ------------------------------------------------------------
# BreakGlass CloudWatch Alarm (optional)
# ------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "break_glass_assumed" {
  count = var.enable_breakglass_alarm ? 1 : 0

  alarm_name          = "tcs-${var.environment}-break-glass-assumed"
  alarm_description   = "ALERT: BreakGlass IAM role assumed. Verify this is authorized emergency access."
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "AssumeRoleEventCount"
  namespace           = "CloudTrailMetrics"
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  treat_missing_data  = "notBreaching"

  dimensions = {
    RoleArn = aws_iam_role.break_glass.arn
  }

  tags = merge(var.tags, {
    Name      = "tcs-${var.environment}-break-glass-assumed"
    ManagedBy = "terraform"
  })
}
