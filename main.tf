terraform {
  required_version = ">= 0.12"
}

module "lambda" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-lambda.git?ref=v6.0.0"

  function_name            = var.name
  description              = "Gather open pull requests and send it to slack"
  handler                  = "main.lambda_handler"
  artifacts_dir            = var.lambda.artifacts_dir
  build_in_docker          = var.lambda.build_in_docker
  create_package           = var.lambda.create_package
  ephemeral_storage_size   = var.lambda.ephemeral_storage_size
  ignore_source_code_hash  = var.lambda.ignore_source_code_hash
  local_existing_package   = var.lambda.local_existing_package
  memory_size              = var.lambda.memory_size
  recreate_missing_package = var.lambda.recreate_missing_package
  runtime                  = var.lambda.runtime
  s3_bucket                = var.lambda.s3_bucket
  s3_existing_package      = var.lambda.s3_existing_package
  s3_prefix                = var.lambda.s3_prefix
  store_on_s3              = var.lambda.store_on_s3
  timeout                  = var.lambda.timeout

  source_path = [
    {
      path             = "${path.module}/src"
      pip_requirements = true
      patterns         = ["!\\.terragrunt-source-manifest"]
    }
  ]

  policy = data.aws_iam_policy_document.this.json

  environment_variables = {
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
