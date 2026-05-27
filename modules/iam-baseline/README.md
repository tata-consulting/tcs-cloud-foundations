# TCS IAM Baseline Module

Terraform module for provisioning standardized IAM roles across TCS client AWS accounts. Implements least-privilege access for human operators, CI/CD pipelines, and emergency break-glass access.

## Roles

| Role | Trust | Permissions | Use Case |
|------|-------|-------------|----------|
| `ReadOnly` | Account root + MFA | `ReadOnlyAccess` managed policy | Auditors, support staff needing view access |
| `Developer` | Account root + MFA | EC2/S3/Lambda/RDS, no IAM, no billing | Day-to-day development work |
| `PlatformEngineer` | Account root + MFA | `PowerUserAccess` minus org/account mgmt | Platform team provisioning and operations |
| `CICD` | GitHub Actions OIDC | EC2/S3/Lambda/ECR/ECS deployment actions | GitHub Actions CI/CD pipelines |
| `BreakGlass` | Account root + MFA (fresh, max 15min old) | `AdministratorAccess` | Emergency full access - must be audited |

## Usage

```hcl
module "iam_baseline" {
  source = "../../modules/iam-baseline"

  account_id  = "123456789012"
  environment = "production"
  github_org  = "tata-consulting"
  github_repo = "my-application"

  allowed_passrole_prefix = "tcs-"
  enable_breakglass_alarm = true

  tags = {
    Environment = "production"
    CostCenter  = "platform-001"
    Team        = "platform"
    ManagedBy   = "terraform"
    Project     = "tcs-cloud-foundations"
  }
}
```

## OIDC Subject Scoping

The CICD role trust policy uses a wildcard subject (`repo:org/repo:*`) by default, which permits assumption from any branch, tag, or environment in the specified repository. For production deployments, scope this to specific branches or environments:

```hcl
# Only allow main branch to assume the role
"token.actions.githubusercontent.com:sub" = "repo:org/repo:ref:refs/heads/main"

# Only allow a specific GitHub environment
"token.actions.githubusercontent.com:sub" = "repo:org/repo:environment:production"
```

The `github_repo` variable sets the repo portion. To change the subject format, override the `assume_role_policy` on the role directly or fork the module.

## BreakGlass Alarm

When `enable_breakglass_alarm = true` (the default), a CloudWatch metric alarm is created that fires when the `AssumeRole` API is called against the BreakGlass role ARN. The alarm uses the `CloudTrailMetrics` namespace - ensure CloudTrail is configured to publish metrics to CloudWatch.

## MFA Requirements

All human-assumed roles (`ReadOnly`, `Developer`, `PlatformEngineer`, `BreakGlass`) require `aws:MultiFactorAuthPresent = true` in the trust policy. The `BreakGlass` role additionally enforces `aws:MultiFactorAuthAge <= 900` (15 minutes) to ensure the MFA token is freshly authenticated.

## Developer PassRole Scoping

The `Developer` role's `iam:PassRole` permission is constrained to role ARNs matching `arn:aws:iam::<account>:role/<allowed_passrole_prefix>*`. The default prefix is `tcs-`, covering TCS-managed Lambda execution roles (`tcs-*-exec-*`) without exposing broader privilege escalation paths.
