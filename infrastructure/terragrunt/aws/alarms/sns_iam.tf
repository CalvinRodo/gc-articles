resource "aws_iam_role" "notify_slack_lambda" {
  name               = "NotifySlackLambda"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_policy.json
}

resource "aws_iam_policy" "notify_slack_lambda" {
  name   = "NotifySlackLambda"
  path   = "/"
  policy = data.aws_iam_policy_document.notify_slack_lambda.json
}

resource "aws_iam_role_policy_attachment" "notify_slack_lambda" {
  role       = aws_iam_role.notify_slack_lambda.name
  policy_arn = aws_iam_policy.notify_slack_lambda.arn
}

resource "aws_iam_role_policy_attachment" "notify_slack_lambda_vpc" {
  role       = aws_iam_role.notify_slack_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

data "aws_iam_policy_document" "lambda_assume_policy" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "notify_slack_lambda" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      aws_cloudwatch_log_group.notify_slack_lambda.arn
    ]
  }
}
