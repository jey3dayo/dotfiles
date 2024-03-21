#!/bin/bash

PR_URL="$1"
ACTION="$2"


if [ -z "$PR_URL" ]; then
    echo "Usage: $0 <PR_URL>"
    exit 1
fi

# アクションが指定されていない場合は、デフォルトの「describe」を使用する
# review, describe, improve, update_changelog
if [ -z "$action" ]; then
    action="describe"
fi

docker run --rm -it -e OPENAI.KEY="$OPENAI_API_KEY" -e GITHUB.USER_TOKEN="$GITHUB_TOKEN" codiumai/pr-agent:latest --pr_url "$PR_URL" "$ACTION"
