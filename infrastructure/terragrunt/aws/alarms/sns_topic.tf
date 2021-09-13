#
# SNS: topics
#
resource "aws_sns_topic" "alert_warning" {
  name              = "alert-warning"
  kms_master_key_id = aws_kms_key.sns_cloudwatch.id

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
  }
}

resource "aws_sns_topic" "alert_warning_us_east" {
  provider = aws.us-east-1

  name              = "alert-warning"
  kms_master_key_id = aws_kms_key.sns_cloudwatch_us_east.id

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
  }
}

#
# SNS: subscriptions
#
resource "aws_sns_topic_subscription" "alert_warning" {
  topic_arn = aws_sns_topic.alert_warning.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.notify_slack.arn
}

resource "aws_sns_topic_subscription" "alert_warning_us_east" {
  provider = aws.us-east-1

  topic_arn = aws_sns_topic.alert_warning_us_east.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.notify_slack.arn
}

#
# KMS: SNS topic encryption keys
# A CMK is required so we can apply a policy that allows CloudWatch to use it
resource "aws_kms_key" "sns_cloudwatch" {
  # checkov:skip=CKV_AWS_7: key rotation not required for CloudWatch SNS topic's messages
  description = "KMS key for CloudWatch SNS topic"
  policy      = data.aws_iam_policy_document.sns_cloudwatch.json

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
  }
}

resource "aws_kms_key" "sns_cloudwatch_us_east" {
  # checkov:skip=CKV_AWS_7: key rotation not required for CloudWatch SNS topic's messages
  provider = aws.us-east-1

  description = "KMS key for CloudWatch SNS topic in US east"
  policy      = data.aws_iam_policy_document.sns_cloudwatch.json

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
  }
}

data "aws_iam_policy_document" "sns_cloudwatch" {
  # checkov:skip=CKV_AWS_109: `resources = ["*"]` identifies the KMS key to which the key policy is attached
  # checkov:skip=CKV_AWS_111: `resources = ["*"]` identifies the KMS key to which the key policy is attached
  statement {
    effect    = "Allow"
    resources = ["*"]
    actions   = ["kms:*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.account_id}:root"]
    }
  }

  statement {
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey*",
    ]

    principals {
      type        = "Service"
      identifiers = ["cloudwatch.amazonaws.com"]
    }
  }
}
