# Agent Instructions

Before starting any task in this repository:

1. Run `make agents/sync`. It writes the shared Plus3 IT instructions for this repository's tardigrade-ci version to `.agents/plus3it/AGENTS.md`.
2. Read `.agents/plus3it/AGENTS.md` and follow it together with this file. If the sync fails, tell the user, and don't guess the conventions.

These rules always apply, even without the shared instructions:

- Don't push, open pull requests, publish releases, or apply infrastructure changes unless the user asks. List those steps for a person in your final report.
- Don't edit files under `.agents/plus3it/`; they are generated and overwritten by the sync.

@.agents/plus3it/AGENTS.md

## Repository-specific

### Purpose

This Terraform module deploys a Python Lambda function that lists the CodeCommit repositories in an account, finds their open pull requests, and posts them to Slack. An EventBridge (CloudWatch Events) rule runs the function on a schedule, which defaults to weekdays at 07:00. The main input is `hook_url`, the Slack webhook URL; `schedule`, `name`, `log_level`, `dry_run`, and a `lambda` object for package and runtime settings are optional. The module has no outputs.

### Module-specific files

- `src/` — Source of the Lambda function, packaged by the module through the upstream Lambda module's `source_path`; `main.py` holds the handler (`lambda_handler`) and `requirements.txt` lists the runtime packages (`boto3` and `requests`)
- `Dockerfile` — Builds on the tardigrade-ci image and installs `src/requirements.txt` so the Lambda packages are available in the image. The tardigrade-ci `docker/run` target, which the shared lint workflow calls, builds this image when it is not already present
