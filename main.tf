terraform {
  required_version = ">= 0.12"
}

module "lambda" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-lambda.git"

  function_name = var.name
  description   = "Gather open pull requests and send it to slack"
  handler       = "main.lambda_handler"
  runtime       = var.lambda.runtime
  timeout       = 30

  source_path = "${path.module}/src"

  policy = data.aws_iam_policy_document.this.json

  environment = {
    SLACK_WEBHOOK = var.hook_url
    LOG_LEVEL     = var.log_level
    DRYRUN        = var.dry_run
  }
}

# Create Cloudwatch Event Rule
resource "aws_cloudwatch_event_rule" "this" {
  name                = var.name
  description         = "Runs lambda function ${var.name} on a schedule"
  schedule_expression = var.schedule
  tags                = var.tags
}

resource "aws_cloudwatch_event_target" "this" {
  rule = aws_cloudwatch_event_rule.this.name
  arn  = module.lambda.lambda_function_arn
}

resource "aws_lambda_permission" "this" {
  action        = "lambda:InvokeFunction"
  function_name = module.lambda.lambda_function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.this.arn
}

### DATA SOURCES ###
data "aws_iam_policy_document" "this" {
  statement {
    actions = [
      "codecommit:ListRepositories",
      "codecommit:ListPullRequests",
      "codecommit:GetPullRequest"
    ]

    resources = [
      "*"
    ]
  }
}
