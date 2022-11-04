#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""Post reminders about open CodeCommit pull requests to slack."""
import json
import os
import logging
import collections

import boto3
import requests

codecommit = boto3.client("codecommit")
SLACK_WEBHOOK = os.environ.get("SLACK_WEBHOOK")
DRYRUN = os.environ.get("DRYRUN", "").lower() == "true"

DEFAULT_LOG_LEVEL = logging.DEBUG
LOG_LEVELS = collections.defaultdict(
    lambda: DEFAULT_LOG_LEVEL,
    {
        "critical": logging.CRITICAL,
        "error": logging.ERROR,
        "warning": logging.WARNING,
        "info": logging.INFO,
        "debug": logging.DEBUG,
    },
)

# Lambda initializes a root logger that needs to be removed in order to set a
# different logging config
root = logging.getLogger()
if root.handlers:
    for handler in root.handlers:
        root.removeHandler(handler)

LOG_FILE_NAME = ""
if not os.environ.get("AWS_EXECUTION_ENV"):
    LOG_FILE_NAME = "aws-pr-reminders.log"

logging.basicConfig(
    filename=LOG_FILE_NAME,
    format="%(asctime)s.%(msecs)03dZ [%(name)s][%(levelname)-5s]: %(message)s",
    datefmt="%Y-%m-%dT%H:%M:%S",
    level=LOG_LEVELS[os.environ.get("LOG_LEVEL", "").lower()],
)
log = logging.getLogger(__name__)


def post_message(pull_requests):
    """Post message to slack."""
    text = []

    for pull_request in pull_requests:
        formatting = (
            ">Title: ",
            "<https://console.aws.amazon.com/codesuite/codecommit/repositories/",
            f"{pull_request['repo_name']}/pull-requests/",
            f"{pull_request['id']}|{pull_request['title']}>\n",
            f">Repo: {pull_request['repo_name']}\n",
            f">Author: `{pull_request['author']}`",
        )

        text.append(
            {"type": "section", "text": {"type": "mrkdwn", "text": "".join(formatting)}}
        )

    if text:
        payload = {"blocks": text}
        if not DRYRUN:
            requests.post(SLACK_WEBHOOK, data=json.dumps(payload), timeout=10)


def get_open_pull_requests():
    """Get list of open pull requests from CodeCommit."""
    open_pull_requests = []
    repos = codecommit.list_repositories() or {}

    for repo in repos.get("repositories", []):
        open_prs = (
            codecommit.list_pull_requests(
                repositoryName=repo["repositoryName"], pullRequestStatus="OPEN"
            )
            or {}
        )

        log.debug("Processing open prs: %s", open_prs)

        for open_pr in open_prs.get("pullRequestIds", []):
            pull_request = codecommit.get_pull_request(pullRequestId=open_pr)

            if not pull_request:
                continue

            log.debug("Processing pr: %s", pull_request)

            pr_id = pull_request["pullRequest"]["pullRequestId"]
            author = pull_request["pullRequest"]["authorArn"]
            repo_name = repo["repositoryName"]
            title = pull_request["pullRequest"]["title"]
            open_pull_requests.append(
                {"id": pr_id, "author": author, "repo_name": repo_name, "title": title}
            )

    return open_pull_requests


def lambda_handler(event, context):  # pylint: disable=unused-argument
    """Entry point for lambda handler."""
    main()


def main():
    """Post reminders about open CodeCommit pull requests to slack."""
    open_pull_requests = get_open_pull_requests()
    post_message(open_pull_requests)


if __name__ == "__main__":
    main()
