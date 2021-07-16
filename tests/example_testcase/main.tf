terraform {
  required_version = ">= 0.12"
}

module "example" {
  source = "../../"

  hook_url = "https://google.com"
}
