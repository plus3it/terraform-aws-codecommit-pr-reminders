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
  type        = map
  default     = {}
}

variable "log_level" {
  type        = string
  default     = "INFO"
  description = "The log level of the lambda function"
}
