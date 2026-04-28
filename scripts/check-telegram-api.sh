#!/bin/sh
set -eu

# ==============================================================================
# Telegram Bot API Health Check
# ==============================================================================
# Usage:
#   sh ./scripts/check-telegram-api.sh
#   TELEGRAM_BOT_TOKEN=123456:ABC... sh ./scripts/check-telegram-api.sh
# ==============================================================================

if [ -t 1 ]; then
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[1;33m'
  BLUE='\033[0;34m'
  BOLD='\033[1m'
  NC='\033[0m'
else
  RED=''
  GREEN=''
  YELLOW=''
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

print_warning() {
  printf "%b\n" "${YELLOW}!!${NC} $1"
}

print_error() {
  printf "%b\n" "${RED}NG${NC} $1" >&2
}

read_token() {
  if [ -n "${TELEGRAM_BOT_TOKEN:-}" ]; then
    printf '%s\n' "$TELEGRAM_BOT_TOKEN"
    return 0
  fi

  printf "Telegram bot token: " >&2
  if [ -t 0 ]; then
    stty_state=$(stty -g)
    trap 'stty "$stty_state" 2>/dev/null || true' EXIT HUP INT TERM
    stty -echo
    IFS= read -r token
    stty "$stty_state"
    trap - EXIT HUP INT TERM
    printf "\n" >&2
  else
    IFS= read -r token
  fi

  printf '%s\n' "$token"
}

main() {
  printf "\n"
  printf "%b\n" "${BOLD}${BLUE}Telegram Bot API Health Check${NC}"
  printf "\n"

  if ! command -v curl >/dev/null 2>&1; then
    print_error "curl is not installed"
    exit 1
  fi

  token=$(read_token)
  if [ -z "$token" ]; then
    print_error "token is empty"
    exit 1
  fi

  api_base="${TELEGRAM_API_BASE:-https://api.telegram.org}"
  url="$api_base/bot$token/getMe"

  print_info "checking getMe..."

  curl_status=0
  response=$(
    curl \
      --silent \
      --show-error \
      --connect-timeout 10 \
      --max-time 20 \
      "$url"
  ) || curl_status=$?

  if [ "$curl_status" -ne 0 ]; then
    print_error "request failed (curl exit: $curl_status)"
    exit "$curl_status"
  fi

  case "$response" in
    *'"ok":true'* | *'"ok": true'*)
      print_success "Telegram Bot API is alive"
      printf "%s\n" "$response"
      ;;
    *'"error_code":401'* | *'"error_code": 401'*)
      print_error "unauthorized token"
      printf "%s\n" "$response" >&2
      exit 1
      ;;
    *)
      print_warning "request reached Telegram, but API returned an error"
      printf "%s\n" "$response" >&2
      exit 1
      ;;
  esac
}

main "$@"
