terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

locals {
  common_tags = merge(
    {
      repository = "tcs-cloud-foundations"
      managed_by = "terraform"
      environment = var.environment
    },
    var.tags
  )
}

resource "aws_s3_bucket" "logs" {
  bucket = "${var.name_prefix}-${var.environment}-logs"

  tags = merge(
    local.common_tags,
    {
      purpose = "centralized-logging"
    }
  )
}

resource "aws_s3_bucket_versioning" "logs" {
  bucket = aws_s3_bucket.logs.id

  versioning_configuration {
    status = "Enabled"
  }
}
