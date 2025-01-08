## terraform-aws-codecommit-pr-reminders

Terraform module to deploy a lambda function that will enumerate CodeCommit repositories and publish the Open PRs to slack

## Testing

Manual testing:

```
# Replace "xxx" with an actual AWS profile, then execute the integration tests.
export AWS_PROFILE=xxx 
make terraform/pytest PYTEST_ARGS="-v --nomock"
```

For automated testing, PYTEST_ARGS is optional and no profile is needed:

```
make mockstack/up
make terraform/pytest PYTEST_ARGS="-v"
make mockstack/clean
```

<!-- BEGIN TFDOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.12 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy_document.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_hook_url"></a> [hook\_url](#input\_hook\_url) | Slack webhook URL; see <https://api.slack.com/incoming-webhooks> | `string` | n/a | yes |
| <a name="input_dry_run"></a> [dry\_run](#input\_dry\_run) | toggle to control dryrun output of the lambda function | `bool` | `false` | no |
| <a name="input_lambda"></a> [lambda](#input\_lambda) | Object of optional attributes passed on to the lambda module | <pre>object({<br/>    artifacts_dir            = optional(string, "builds")<br/>    build_in_docker          = optional(bool, false)<br/>    create_package           = optional(bool, true)<br/>    ephemeral_storage_size   = optional(number)<br/>    ignore_source_code_hash  = optional(bool, true)<br/>    local_existing_package   = optional(string)<br/>    memory_size              = optional(number, 128)<br/>    recreate_missing_package = optional(bool, false)<br/>    runtime                  = optional(string, "python3.12")<br/>    s3_bucket                = optional(string)<br/>    s3_existing_package      = optional(map(string))<br/>    s3_prefix                = optional(string)<br/>    store_on_s3              = optional(bool, false)<br/>    timeout                  = optional(number, 300)<br/>  })</pre> | `{}` | no |
| <a name="input_log_level"></a> [log\_level](#input\_log\_level) | The log level of the lambda function | `string` | `"INFO"` | no |
| <a name="input_name"></a> [name](#input\_name) | (Optional) Name to associate with the lambda function | `string` | `"codecommit-pr-reminders"` | no |
| <a name="input_schedule"></a> [schedule](#input\_schedule) | (Optional) Schedule expression for CloudWatch event; see <https://docs.aws.amazon.com/lambda/latest/dg/tutorial-scheduled-events-schedule-expressions.html> | `string` | `"cron(0 7 ? * MON-FRI *)"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to add to the supported resources | `map(any)` | `{}` | no |

## Outputs

No outputs.

<!-- END TFDOCS -->
