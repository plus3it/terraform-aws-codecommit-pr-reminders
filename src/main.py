#!/usr/bin/env python
# -*- coding: utf-8 -*-
import json
import os
import logging
import collections

import boto3
import requests

DEBUG = False

codecommit = boto3.client("codecommit")
slack_webhook = os.environ["SLACK_WEBHOOK"] if not DEBUG else None


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

log_file_name = ""
if not os.environ.get("AWS_EXECUTION_ENV"):
    log_file_name = "aws-pr-reminders.log"

logging.basicConfig(
    filename=log_file_name,
    format="%(asctime)s.%(msecs)03dZ [%(name)s][%(levelname)-5s]: %(message)s",
    datefmt="%Y-%m-%dT%H:%M:%S",
    level=LOG_LEVELS[os.environ.get("LOG_LEVEL", "").lower()],
)
log = logging.getLogger(__name__)


def post_message(pull_requests):
    text = []

    for pr in pull_requests:
        formatting = (
            ">Title: ",
            "<https://console.aws.amazon.com/codesuite/codecommit/repositories/",
            f"{pr['repo_name']}/pull-requests/{pr['id']}|{pr['title']}>\n",
            f">Repo: {pr['repo_name']}\n",
            f">Author: `{pr['author']}`",
        )

        text.append(
            {"type": "section", "text": {"type": "mrkdwn", "text": "".join(formatting)}}
        )

    if text:
        payload = {"blocks": text}
        if not DEBUG:
            requests.post(slack_webhook, data=json.dumps(payload))


def get_open_pull_requests():
    open_pull_requests = []
    repos = codecommit.list_repositories() or {}

    for repo in repos.get("repositories", []):
        open_prs = (
            codecommit.list_pull_requests(
                repositoryName=repo["repositoryName"], pullRequestStatus="OPEN"
            )
            or {}
        )

        log.debug("Processing open prs: %s", json.loads(open_prs))

        for open_pr in open_prs.get("pullRequestIds", []):
            pr = codecommit.get_pull_request(pullRequestId=open_pr)

            if not pr:
                continue

            log.debug("Processing pr: %s", json.loads(pr))

            pr_id = pr["pullRequest"]["pullRequestId"]
            author = pr["pullRequest"]["authorArn"]
            repo_name = repo["repositoryName"]
            title = pr["pullRequest"]["title"]
            open_pull_requests.append(
                {"id": pr_id, "author": author, "repo_name": repo_name, "title": title}
            )

    return open_pull_requests


def lambda_handler(event, context):
    main()


def main():
    open_pull_requests = get_open_pull_requests()
    post_message(open_pull_requests)


if __name__ == "__main__":
    main()
