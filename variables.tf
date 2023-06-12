variable "name" {
  description = "(Optional) Name to associate with the lambda function"
  type        = string
  default     = "codecommit-pr-reminders"
}

variable "schedule" {
  description = "(Optional) Schedule expression for CloudWatch event; see <https://docs.aws.amazon.com/lambda/latest/dg/tutorial-scheduled-events-schedule-expressions.html>"
  type        = string
  default     = "cron(0 7 ? * MON-FRI *)"
}

variable "hook_url" {
  description = "Slack webhook URL; see <https://api.slack.com/incoming-webhooks>"
  type        = string
}

variable "tags" {
  description = "Tags to add to the supported resources"
  type        = map(any)
  default     = {}
}

variable "log_level" {
  type        = string
  default     = "INFO"
  description = "The log level of the lambda function"
}

variable "dry_run" {
  type        = bool
  default     = false
  description = "toggle to control dryrun output of the lambda function"
}

variable "lambda" {
  description = "Object of optional attributes passed on to the lambda module"
  type = object({
    artifacts_dir            = optional(string, "builds")
    build_in_docker          = optional(bool, false)
    create_package           = optional(bool, true)
    ephemeral_storage_size   = optional(number)
    ignore_source_code_hash  = optional(bool, true)
    local_existing_package   = optional(string)
    memory_size              = optional(number, 128)
    recreate_missing_package = optional(bool, false)
    runtime                  = optional(string, "python3.9")
    s3_bucket                = optional(string)
    s3_existing_package      = optional(map(string))
    s3_prefix                = optional(string)
    store_on_s3              = optional(bool, false)
    timeout                  = optional(number, 300)
  })
  default = {}
}
