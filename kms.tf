data "aws_caller_identity" "current" {}

# KMS key for EC2 encryption
resource "aws_kms_key" "ec2_encryption_key" {
  description             = "KMS key for EC2 instance encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  key_usage               = "ENCRYPT_DECRYPT"
  rotation_period_in_days = 90
  policy                  = data.aws_iam_policy_document.ec2_kms_policy.json

  tags = {
    Name = "EC2-KMS-Key-${var.vpc_name}"
  }
}

data "aws_iam_policy_document" "ec2_kms_policy" {
  statement {
    sid    = "AllowRootFullAccess"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid    = "AllowEC2Service"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
      "kms:CreateGrant"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = ["ec2.${var.region}.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }


  statement {
    sid    = "AllowAutoScalingService"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["autoscaling.amazonaws.com"]
    }
    actions   = ["kms:CreateGrant"]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = ["ec2.${var.region}.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }

  statement {
    sid    = "AllowServiceLinkedRoleAutoScaling"
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
      ]
    }
    actions = [
      "kms:CreateGrant",
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = ["ec2.${var.region}.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

resource "aws_kms_alias" "ec2_key_alias" {
  name          = "alias/${var.vpc_name}-ec2-key"
  target_key_id = aws_kms_key.ec2_encryption_key.key_id
}

# KMS key for RDS encryption
resource "aws_kms_key" "rds_encryption_key" {
  description             = "KMS key for RDS instance encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  key_usage               = "ENCRYPT_DECRYPT"
  rotation_period_in_days = 90
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowRootFullAccess"
        Effect = "Allow"
        Principal = {
          AWS = format("arn:aws:iam::%s:root", data.aws_caller_identity.current.account_id)
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "AllowRDSServiceUse"
        Effect = "Allow"
        Principal = {
          Service = "rds.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:GenerateDataKey"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Name = "RDS-KMS-Key-${var.vpc_name}"
  }
}

resource "aws_kms_alias" "rds_key_alias" {
  name          = "alias/${var.vpc_name}-rds-key"
  target_key_id = aws_kms_key.rds_encryption_key.key_id
}

# KMS key for S3 encryption
resource "aws_kms_key" "s3_encryption_key" {
  description             = "KMS key for S3 bucket encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  key_usage               = "ENCRYPT_DECRYPT"
  rotation_period_in_days = 90
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowRootFullAccess"
        Effect = "Allow"
        Principal = {
          AWS = format("arn:aws:iam::%s:root", data.aws_caller_identity.current.account_id)
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "AllowS3ServiceAccess"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "kms:EncryptionContext:aws:s3:arn" = format("arn:aws:s3:::%s", aws_s3_bucket.app_bucket.id)
          }
        }
      }
    ]
  })

  tags = {
    Name = "S3-KMS-Key-${var.vpc_name}"
  }
}

resource "aws_kms_alias" "s3_key_alias" {
  name          = "alias/${var.vpc_name}-s3-key"
  target_key_id = aws_kms_key.s3_encryption_key.key_id
}

# KMS key for Secrets Manager
resource "aws_kms_key" "secrets_encryption_key" {
  description             = "KMS key for Secrets Manager encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  key_usage               = "ENCRYPT_DECRYPT"
  rotation_period_in_days = 90
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowRootFullAccess"
        Effect = "Allow"
        Principal = {
          AWS = format("arn:aws:iam::%s:root", data.aws_caller_identity.current.account_id)
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "AllowSecretsManagerUse"
        Effect = "Allow"
        Principal = {
          Service = "secretsmanager.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey"
        ]
        Resource = "*"
      },
      {
        Sid    = "AllowEC2ToDecryptSecrets"
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.ec2_s3_access_role.arn
        }
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Name = "Secrets-KMS-Key-${var.vpc_name}"
  }
}

resource "aws_kms_alias" "secrets_key_alias" {
  name          = "alias/${var.vpc_name}-secrets-key"
  target_key_id = aws_kms_key.secrets_encryption_key.key_id
}