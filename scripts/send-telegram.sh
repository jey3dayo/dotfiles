#!/bin/sh
set -eu

# ==============================================================================
# Telegram Bot Message Sender
# ==============================================================================
# Usage:
#   sh ./scripts/send-telegram.sh "message text"
#   echo "message text" | sh ./scripts/send-telegram.sh
#   TELEGRAM_BOT_TOKEN=... TELEGRAM_CHAT_ID=... sh ./scripts/send-telegram.sh "msg"
#
# Env:
#   TELEGRAM_BOT_TOKEN  Required. Bot token (or sourced from ~/.openclaw/gateway.env)
#   TELEGRAM_CHAT_ID    Required. Numeric chat id or @username
#   TELEGRAM_API_BASE   Optional. Defaults to https://api.telegram.org
#   TELEGRAM_PARSE_MODE Optional. e.g. MarkdownV2 / HTML (default: none)
# ==============================================================================

if [ -t 1 ]; then
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  BLUE='\033[0;34m'
  BOLD='\033[1m'
  NC='\033[0m'
else
  RED=''
  GREEN=''
  BLUE=''
  BOLD=''
  NC=''
fi

print_info() {
  printf "%b\n" "${BLUE}i${NC}  $1"
}

print_success() {
  printf "%b\n" "${GREEN}OK${NC} $1"
}

print_error() {
  printf "%b\n" "${RED}NG${NC} $1" >&2
}

read_secret() {
  varname="$1"
  prompt="$2"
  value=$(eval printf '%s' "\${$varname:-}")
  if [ -n "$value" ]; then
    printf '%s\n' "$value"
    return 0
  fi
  printf "%s: " "$prompt" >&2
  if [ -t 0 ]; then
    stty_state=$(stty -g)
    trap 'stty "$stty_state" 2>/dev/null || true' EXIT HUP INT TERM
    stty -echo
    IFS= read -r v
    stty "$stty_state"
    trap - EXIT HUP INT TERM
    printf "\n" >&2
  else
    IFS= read -r v
  fi
  printf '%s\n' "$v"
}

main() {
  if [ $# -ge 1 ]; then
    message="$*"
  else
    message=$(cat)
  fi

  if [ -z "$message" ]; then
    print_error "message is empty"
    printf "Usage: %s \"text\"  (or pipe message via stdin)\n" "$0" >&2
    exit 1
  fi

  if ! command -v curl >/dev/null 2>&1; then
    print_error "curl is not installed"
    exit 1
  fi

  token=$(read_secret TELEGRAM_BOT_TOKEN "Telegram bot token")
  chat_id=$(read_secret TELEGRAM_CHAT_ID "Telegram chat id")

  if [ -z "$token" ] || [ -z "$chat_id" ]; then
    print_error "token or chat_id is empty"
    exit 1
  fi

  api_base="${TELEGRAM_API_BASE:-https://api.telegram.org}"
  parse_mode="${TELEGRAM_PARSE_MODE:-}"
  url="$api_base/bot$token/sendMessage"

  print_info "sending to $chat_id (${#message} chars)..."

  curl_status=0
  if [ -n "$parse_mode" ]; then
    response=$(
      curl --silent --show-error --connect-timeout 10 --max-time 20 \
        -X POST "$url" \
        --data-urlencode "chat_id=$chat_id" \
        --data-urlencode "text=$message" \
        --data-urlencode "parse_mode=$parse_mode"
    ) || curl_status=$?
  else
    response=$(
      curl --silent --show-error --connect-timeout 10 --max-time 20 \
        -X POST "$url" \
        --data-urlencode "chat_id=$chat_id" \
        --data-urlencode "text=$message"
    ) || curl_status=$?
  fi

  if [ "$curl_status" -ne 0 ]; then
    print_error "request failed (curl exit: $curl_status)"
    exit "$curl_status"
  fi

  case "$response" in
    *'"ok":true'* | *'"ok": true'*)
      print_success "sent"
      ;;
    *)
      print_error "Telegram API rejected the request"
      printf "%s\n" "$response" >&2
      exit 1
      ;;
  esac
}

printf "%b\n" "${BOLD}${BLUE}Telegram Send${NC}"
main "$@"
