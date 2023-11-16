terraform {
  required_version = ">= 0.12"
}

module "example" {
  source = "../../"

  name     = "codecommit-pr-reminders-${random_string.this.result}"
  hook_url = "https://google.com"
}

resource "random_string" "this" {
  length  = 8
  upper   = false
  special = false
  numeric = false
}
