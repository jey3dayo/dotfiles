#!/usr/bin/env python3
"""Minimal Linear task operations via GraphQL API.

Usage examples:
  python3 scripts/linear_task.py teams
  python3 scripts/linear_task.py list --team KEY --limit 20
  python3 scripts/linear_task.py create --team KEY --title "Task title" --description "details" --due-date 2026-03-20
  python3 scripts/linear_task.py update --issue ABC-123 --title "new title" --state "Done"
  python3 scripts/linear_task.py comment --issue ABC-123 --body "追加メモ"
"""

from __future__ import annotations

import argparse
import json
import os
from typing import Any, Dict, Optional
from urllib.error import HTTPError
from urllib.request import Request, urlopen

LINEAR_API_URL = "https://api.linear.app/graphql"


def load_token() -> str:
    token = os.getenv("LINEAR_API_KEY") or os.getenv("LINEAR_TOKEN")
    if token:
        return token.strip()

    env_file = os.getenv("LINEAR_ENV_FILE", ".env")
    if os.path.exists(env_file):
        with open(env_file, "r", encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if not line or line.startswith("#") or "=" not in line:
                    continue
                k, v = line.split("=", 1)
                if k.strip() in {"LINEAR_API_KEY", "LINEAR_TOKEN"}:
                    return v.strip().strip('"').strip("'")

    raise SystemExit("LINEAR_API_KEY (or LINEAR_TOKEN) is not set.")


def gql(query: str, variables: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
    payload = json.dumps({"query": query, "variables": variables or {}}).encode("utf-8")
    token = load_token()
    req = Request(
        LINEAR_API_URL,
        data=payload,
        headers={
            "Content-Type": "application/json",
            "Authorization": token,
        },
        method="POST",
    )
    try:
        with urlopen(req, timeout=30) as res:
            body = res.read().decode("utf-8")
    except HTTPError as e:
        detail = e.read().decode("utf-8", errors="replace")
        raise SystemExit(f"Linear API error: {e.code} {e.reason}\n{detail}")

    data = json.loads(body)
    if data.get("errors"):
        raise SystemExit(f"GraphQL errors: {json.dumps(data['errors'], ensure_ascii=False)}")
    return data["data"]


def cmd_teams(_: argparse.Namespace) -> None:
    q = """
    query {
      teams {
        nodes {
          id
          key
          name
        }
      }
    }
    """
    data = gql(q)
    for t in data["teams"]["nodes"]:
        print(f"{t['key']}\t{t['name']}\t{t['id']}")


def cmd_states(args: argparse.Namespace) -> None:
    team_id = get_team_id_by_key(args.team)
    q = """
    query($teamId: String!) {
      team(id: $teamId) {
        id
        name
        states {
          nodes {
            id
            name
            type
          }
        }
      }
    }
    """
    data = gql(q, {"teamId": team_id})
    team = data.get("team")
    if not team:
        raise SystemExit(f"Team not found: {args.team}")
    for s in team["states"]["nodes"]:
        print(f"{s['name']}\t{s['type']}\t{s['id']}")


def cmd_list(args: argparse.Namespace) -> None:
    team_id = get_team_id_by_key(args.team)
    q = """
    query($teamId: String!, $first: Int!) {
      team(id: $teamId) {
        issues(first: $first, orderBy: updatedAt) {
          nodes {
            id
            identifier
            title
            priority
            dueDate
            state { name }
            assignee { name }
            updatedAt
          }
        }
      }
    }
    """
    data = gql(q, {"teamId": team_id, "first": args.limit})
    team = data.get("team")
    if not team:
        raise SystemExit(f"Team not found: {args.team}")
    for i in team["issues"]["nodes"]:
        print(
            "\t".join(
                [
                    i.get("identifier") or "-",
                    i.get("state", {}).get("name") or "-",
                    (i.get("assignee") or {}).get("name") or "-",
                    str(i.get("dueDate") or "-"),
                    str(i.get("priority") or "0"),
                    (i.get("title") or "").replace("\t", " "),
                ]
            )
        )


def get_team_id_by_key(team_key: str) -> str:
    q = """
    query {
      teams {
        nodes {
          id
          key
        }
      }
    }
    """
    data = gql(q)
    for team in data.get("teams", {}).get("nodes", []):
        if (team.get("key") or "").strip().lower() == team_key.strip().lower():
            return team["id"]
    raise SystemExit(f"Team not found: {team_key}")


def get_state_id_by_name(team_key: str, state_name: str) -> Optional[str]:
    team_id = get_team_id_by_key(team_key)
    q = """
    query($teamId: String!) {
      team(id: $teamId) {
        states { nodes { id name } }
      }
    }
    """
    data = gql(q, {"teamId": team_id})
    team = data.get("team")
    if not team:
        return None
    needle = state_name.strip().lower()
    for s in team["states"]["nodes"]:
        if s["name"].strip().lower() == needle:
            return s["id"]
    return None


def cmd_create(args: argparse.Namespace) -> None:
    team_id = get_team_id_by_key(args.team)
    q = """
    mutation($input: IssueCreateInput!) {
      issueCreate(input: $input) {
        success
        issue { id identifier title url }
      }
    }
    """
    input_obj: Dict[str, Any] = {
        "teamId": team_id,
        "title": args.title,
    }
    if args.description:
        input_obj["description"] = args.description
    if args.due_date:
        input_obj["dueDate"] = args.due_date
    if args.priority is not None:
        input_obj["priority"] = args.priority

    data = gql(q, {"input": input_obj})
    issue = data["issueCreate"]["issue"]
    print(f"CREATED\t{issue['identifier']}\t{issue['title']}\t{issue['url']}")


def cmd_update(args: argparse.Namespace) -> None:
    q = """
    mutation($id: String!, $input: IssueUpdateInput!) {
      issueUpdate(id: $id, input: $input) {
        success
        issue { id identifier title url }
      }
    }
    """
    input_obj: Dict[str, Any] = {}
    if args.title:
        input_obj["title"] = args.title
    if args.description is not None:
        input_obj["description"] = args.description
    if args.due_date is not None:
        input_obj["dueDate"] = args.due_date
    if args.priority is not None:
        input_obj["priority"] = args.priority
    if args.state:
        if not args.team:
            raise SystemExit("--team is required when using --state")
        sid = get_state_id_by_name(args.team, args.state)
        if not sid:
            raise SystemExit(f"State '{args.state}' not found in team {args.team}")
        input_obj["stateId"] = sid
    if not input_obj:
        raise SystemExit("No update fields set.")

    data = gql(q, {"id": args.issue, "input": input_obj})
    issue = data["issueUpdate"]["issue"]
    print(f"UPDATED\t{issue['identifier']}\t{issue['title']}\t{issue['url']}")


def cmd_comment(args: argparse.Namespace) -> None:
    q = """
    mutation($input: CommentCreateInput!) {
      commentCreate(input: $input) {
        success
        comment { id body }
      }
    }
    """
    data = gql(q, {"input": {"issueId": args.issue, "body": args.body}})
    c = data["commentCreate"]["comment"]
    print(f"COMMENTED\t{c['id']}")


def build_parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(description="Linear task operations")
    sub = p.add_subparsers(dest="cmd", required=True)

    s = sub.add_parser("teams", help="List teams")
    s.set_defaults(func=cmd_teams)

    s = sub.add_parser("states", help="List states of a team")
    s.add_argument("--team", required=True, help="Team key (e.g. OPS)")
    s.set_defaults(func=cmd_states)

    s = sub.add_parser("list", help="List issues in a team")
    s.add_argument("--team", required=True, help="Team key")
    s.add_argument("--limit", type=int, default=20)
    s.set_defaults(func=cmd_list)

    s = sub.add_parser("create", help="Create issue")
    s.add_argument("--team", required=True, help="Team key")
    s.add_argument("--title", required=True)
    s.add_argument("--description")
    s.add_argument("--due-date", help="YYYY-MM-DD")
    s.add_argument("--priority", type=int, choices=[0, 1, 2, 3, 4])
    s.set_defaults(func=cmd_create)

    s = sub.add_parser("update", help="Update issue")
    s.add_argument("--issue", required=True, help="Issue id (UUID) or identifier if your workspace resolves it")
    s.add_argument("--team", help="Team key (required with --state)")
    s.add_argument("--title")
    s.add_argument("--description")
    s.add_argument("--due-date")
    s.add_argument("--priority", type=int, choices=[0, 1, 2, 3, 4])
    s.add_argument("--state", help="State name in the team")
    s.set_defaults(func=cmd_update)

    s = sub.add_parser("comment", help="Add comment")
    s.add_argument("--issue", required=True, help="Issue id (UUID)")
    s.add_argument("--body", required=True)
    s.set_defaults(func=cmd_comment)

    return p


def main() -> None:
    parser = build_parser()
    args = parser.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
