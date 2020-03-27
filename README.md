## terraform-aws-codecommit-pr-reminders

Terraform module to deploy a lambda function that will enumerate CodeCommit repositories and publish the Open PRs to slack

<!-- BEGIN TFDOCS -->
## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| hook\_url | Slack webhook URL; see <https://api.slack.com/incoming-webhooks> | `string` | n/a | yes |
| dry\_run | toggle to control dryrun output of the lambda function | `bool` | `false` | no |
| log\_level | The log level of the lambda function | `string` | `"INFO"` | no |
| name | (Optional) Name to associate with the lambda function | `string` | `"codecommit-pr-reminders"` | no |
| schedule | (Optional) Schedule expression for CloudWatch event; see <https://docs.aws.amazon.com/lambda/latest/dg/tutorial-scheduled-events-schedule-expressions.html> | `string` | `"cron(0 7 ? * MON-FRI *)"` | no |
| tags | Tags to add to the supported resources | `map` | `{}` | no |

## Outputs

No output.

<!-- END TFDOCS -->
