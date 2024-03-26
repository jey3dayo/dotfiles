#!/usr/bin/env zx

const [PR_URL, ACTION = "describe"] = argv._;

if (!PR_URL) {
  console.error("Error: PR_URL is required.");
  console.log(`Usage: ${argv._[0]} <PR_URL> [ACTION]`);
  process.exit(1);
}

const ALLOWED_ACTIONS = ["review", "describe", "improve", "update_changelog"];

if (!ALLOWED_ACTIONS.includes(ACTION)) {
  console.error(`Invalid action: ${ACTION}`);
  console.error(`Allowed actions: ${ALLOWED_ACTIONS.join(", ")}`);
  process.exit(1);
}

const { OPENAI_API_KEY, GITHUB_TOKEN } = process.env;

if (!OPENAI_API_KEY || !GITHUB_TOKEN) {
  console.error("Missing environment variables: OPENAI_API_KEY, GITHUB_TOKEN");
  process.exit(1);
}

await $`docker run --rm -it -e OPENAI.KEY=${OPENAI_API_KEY} -e GITHUB.USER_TOKEN=${GITHUB_TOKEN} codiumai/pr-agent:latest --pr_url ${PR_URL} ${ACTION}`;
