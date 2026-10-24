#!/bin/bash
# mac-health-check.sh - zero-cost local health check for macOS.
# mise bootstrap の LaunchAgent (dev.mise.mac-health-check) から 15 分ごとに起動する。
#
# 過去の事故（agmsg hook の session-start.sh / identities.sh 滞留、syspolicyd 張り付き、
# node 暴走、10/23 のプロセス起動遅延）を検知する。正常時は 1 行ログを追記するだけで無音、
# 異常時のみ osascript 通知 + 任意の webhook を送る（同一内容は 1 時間に 1 回まで）。
#
# macOS 標準の /bin/bash 3.2 で動くこと、外部コマンド起動を最小にすること
# （exec 遅延そのものが監視対象のため）を前提に書いている。
#
# Usage: mac-health-check.sh [-v|--verbose] [--test-notify]
# 閾値はすべて MH_* 環境変数で上書きできる。
# webhook URL は repo 外の $MH_WEBHOOK_ENV（既定 ~/.local/state/mac-health/webhook.env、
# chmod 600、中身は MH_WEBHOOK_URL=https://...）に置く。repo にはコミットしない。

set -u
shopt -s nullglob

: "${MH_STATE_DIR:=$HOME/.cache/mac-health}"
: "${MH_LOG:=$MH_STATE_DIR/health.log}"
: "${MH_LOG_MAX_BYTES:=1048576}"       # health.log.1 へローテーション
: "${MH_SYSPOLICYD_MAX:=50}"           # syspolicyd の % CPU
: "${MH_PROC_COUNT_MAX:=50}"           # 同一コマンド名のプロセス数
: "${MH_PROC_CPU_MAX:=200}"            # 同一コマンド名の合計 % CPU
: "${MH_AGMSG_PROC_MAX:=0}"            # command に agmsg を含むプロセス数
: "${MH_HOOKSCRIPT_PROC_MAX:=3}"       # session-start.sh / identities.sh の滞留数
: "${MH_LATENCY_MAX_MS:=1000}"         # /usr/bin/true の wall time
: "${MH_NOTIFY_COOLDOWN:=3600}"        # 同じ警告が続くときの再通知間隔（秒）
: "${MH_REPO_ROOTS:=$HOME/src $HOME/ghq}"
: "${MH_CLAUDE_SETTINGS:=$HOME/.claude/settings.json}"
: "${MH_CCSL_SETTINGS:=$HOME/.config/ccstatusline/settings.json}"
: "${MH_WEBHOOK_ENV:=${XDG_STATE_HOME:-$HOME/.local/state}/mac-health/webhook.env}"

# プロセス集計の除外リスト（macOS で多数のプロセスを持つことが正常なもの）
: "${MH_PROC_IGNORE:=com.apple. WindowServer loginwindow launchd kernel_task}"

VERBOSE=0
TEST_NOTIFY=0
for arg in "$@"; do
  case $arg in
    -v | --verbose) VERBOSE=1 ;;
    --test-notify) TEST_NOTIFY=1 ;;
    *)
      echo "unknown option: $arg" >&2
      exit 2
      ;;
  esac
done

mkdir -p "$MH_STATE_DIR" 2>/dev/null || exit 1

warns=() # 異常 -> 通知
notes=() # 弱い警告 -> ログのみ

# 先頭の整数部: "12.3" / "12,3"（ja_JP locale）/ "2\n" -> 12 / 12 / 2
to_int() {
  local v=${1%%[!0-9]*}
  printf '%s' "${v:-0}"
}

# fork せずにファイル全体を FILE へ読む
read_file() {
  FILE=
  [[ -r $1 ]] || return 1
  IFS= read -r -d '' FILE <"$1"
  return 0
}

# Claude settings JSON の "hooks" セクションを近似抽出して HOOKS に入れる。
# 後続の "permissions" で切るので、allow リストに agmsg のパスがあっても誤検知しない。
hooks_section() {
  HOOKS=
  [[ $1 == *'"hooks"'* ]] || return 1
  HOOKS=${1#*\"hooks\"}
  HOOKS=${HOOKS%%\"permissions\"*}
  return 0
}

# 表示用コマンド名: .app バンドル名、なければ実行ファイルの basename
cmd_name() {
  local cmd=$1
  if [[ $cmd == *.app/* ]]; then
    CMD_NAME=${cmd%%.app/*}
  else
    CMD_NAME=${cmd%% *}
  fi
  CMD_NAME=${CMD_NAME##*/}
  CMD_NAME=${CMD_NAME// /_}
}

# ---- 1. プロセス（ps は 1 回だけ）+ コマンド名ごとの集計 ------------------------

# 除外対象かチェック（MH_PROC_IGNORE のスペース区切りリストに部分一致すれば除外）
should_ignore() {
  local name=$1
  local pattern
  for pattern in $MH_PROC_IGNORE; do
    [[ $name == *"$pattern"* ]] && return 0
  done
  return 1
}

agg_names=()
agg_cpu=()
agg_cnt=()
sysp=0
agmsg_procs=0
hook_procs=0
orphan_dev=0
ps_out=$(LC_ALL=C /bin/ps -Ao pid=,ppid=,pcpu=,command= 2>/dev/null)
while read -r pid ppid pcpu cmd; do
  [[ -n ${pid:-} ]] || continue
  case $cmd in *mac-health-check.sh*) continue ;; esac
  cpu=${pcpu%%[!0-9]*}
  cpu=${cpu:-0}
  exe=${cmd%% *}
  base=${exe##*/}
  
  # syspolicyd は個別にチェック（頻出する張り付きパターン）
  [[ $base == syspolicyd ]] && ((cpu > sysp)) && sysp=$cpu
  
  # 特定パターンの検知
  case $cmd in *agmsg*) agmsg_procs=$((agmsg_procs + 1)) ;; esac
  case $cmd in *session-start.sh* | *identities.sh*) hook_procs=$((hook_procs + 1)) ;; esac
  
  # launchd 直下に取り残された dev サーバー（todo.txt 2026-08-21 の残タスク）。ログのみ。
  if [[ $ppid == 1 ]]; then
    case $cmd in *vite* | *workerd* | *'pnpm '*dev* | *'mise run'*) orphan_dev=$((orphan_dev + 1)) ;; esac
  fi
  
  # 集計は CPU を使っているプロセスだけ（0% の大量プロセスで線形探索を回さない）
  ((cpu > 0)) || continue
  
  cmd_name "$cmd"
  should_ignore "$CMD_NAME" && continue
  
  i=0
  n=${#agg_names[@]}
  while ((i < n)) && [[ ${agg_names[i]} != "$CMD_NAME" ]]; do i=$((i + 1)); done
  if ((i == n)); then
    agg_names[i]=$CMD_NAME
    agg_cpu[i]=0
    agg_cnt[i]=0
  fi
  agg_cpu[i]=$((agg_cpu[i] + cpu))
  agg_cnt[i]=$((agg_cnt[i] + 1))
done <<<"$ps_out"

# 合計 CPU の上位 3 コマンド（選択ソート 3 回）
top=""
picked=" "
for _ in 1 2 3; do
  best=-1
  bi=-1
  i=0
  while ((i < ${#agg_names[@]})); do
    if [[ $picked != *" $i "* ]] && ((agg_cpu[i] > best)); then
      best=${agg_cpu[i]}
      bi=$i
    fi
    i=$((i + 1))
  done
  ((bi < 0)) && break
  picked="$picked$bi "
  top="$top${agg_names[bi]}:${agg_cpu[bi]}%x${agg_cnt[bi]},"
done
top=${top%,}

# 汎用プロセス集計チェック：全プロセスグループについてカウント閾値または CPU 閾値を確認
i=0
while ((i < ${#agg_names[@]})); do
  if ((agg_cnt[i] > MH_PROC_COUNT_MAX)); then
    warns+=("${agg_names[i]} x${agg_cnt[i]} processes")
  fi
  if ((agg_cpu[i] > MH_PROC_CPU_MAX)); then
    warns+=("${agg_names[i]} total ${agg_cpu[i]}%CPU x${agg_cnt[i]}")
  fi
  i=$((i + 1))
done

((sysp > MH_SYSPOLICYD_MAX)) && warns+=("syspolicyd ${sysp}%CPU")
((agmsg_procs > MH_AGMSG_PROC_MAX)) && warns+=("agmsg procs x${agmsg_procs}")
((hook_procs > MH_HOOKSCRIPT_PROC_MAX)) && warns+=("hook scripts piling up x${hook_procs}")
((orphan_dev > 0)) && notes+=("orphan dev servers x${orphan_dev}")

# ---- 2. agmsg / orca hook の復活 --------------------------------------------
agmsg_files=()
for f in "$HOME"/.claude/settings*.json; do
  read_file "$f" || continue
  hooks_section "$FILE" && [[ $HOOKS == *agmsg* ]] && agmsg_files+=("${f#"$HOME"/}")
done
if read_file "$HOME/.codex/hooks.json" && [[ $FILE == *agmsg* ]]; then
  agmsg_files+=(".codex/hooks.json")
fi
for root in $MH_REPO_ROOTS; do
  [[ -d $root ]] || continue
  for f in "$root"/*/.claude/settings.local.json "$root"/*/*/.claude/settings.local.json \
    "$root"/*/*/*/.claude/settings.local.json; do
    read_file "$f" || continue
    hooks_section "$FILE" && [[ $HOOKS == *agmsg* ]] && agmsg_files+=("${f#"$HOME"/}")
  done
  for f in "$root"/*/.codex/hooks.json "$root"/*/*/.codex/hooks.json "$root"/*/*/*/.codex/hooks.json; do
    read_file "$f" || continue
    [[ $FILE == *agmsg* ]] && agmsg_files+=("${f#"$HOME"/}")
  done
done
if ((${#agmsg_files[@]} > 0)); then
  warns+=("agmsg hook back in ${#agmsg_files[@]} file(s): ${agmsg_files[0]}")
fi

if read_file "$MH_CLAUDE_SETTINGS"; then
  settings=$FILE
  if hooks_section "$settings" && [[ $HOOKS == *orca* ]]; then
    warns+=("orca hook back in ~/.claude/settings.json")
  fi
  # ---- 3. statusLine が shim / ランチャー経由に戻っていないか --------------------
  if [[ $settings == *'"statusLine"'* ]]; then
    sl=${settings#*\"statusLine\"}
    sl=${sl%%\}*}
    case $sl in
      */shims/* | *'mise x'* | *'mise exec'* | *npx\ * | *bunx\ * | *'pnpm dlx'*)
        warns+=("statusLine goes through a shim/launcher")
        ;;
    esac
  fi
  # ---- 4. model == opus（手癖。ログのみ） ---------------------------------------
  if [[ $settings == *'"model"'* ]]; then
    m=${settings#*\"model\"}
    m=${m:0:30}
    [[ $m == *opus* ]] && notes+=("model=opus")
  fi
fi

# ---- 5. ccstatusline widget 数（初回値を baseline として保存） ----------------------
ccsl=-1
if read_file "$MH_CCSL_SETTINGS"; then
  ccsl=0
  rest=$FILE
  while [[ $rest == *'"type"'* ]]; do
    rest=${rest#*\"type\"}
    ccsl=$((ccsl + 1))
  done
  baseline_file=$MH_STATE_DIR/ccstatusline.baseline
  baseline=${MH_CCSL_WIDGET_MAX:-}
  if [[ -z $baseline ]]; then
    if read_file "$baseline_file"; then
      baseline=$(to_int "$FILE")
    else
      baseline=$ccsl
      printf '%s\n' "$ccsl" >"$baseline_file"
    fi
  fi
  ((ccsl > baseline)) && warns+=("ccstatusline widgets ${ccsl} > baseline ${baseline}")
fi

# ---- 6. プロセス起動レイテンシ ---------------------------------------------------
lat_file=$MH_STATE_DIR/.latency
TIMEFORMAT=%3R
{ time /usr/bin/true; } 2>"$lat_file"
lat_s=0
read_file "$lat_file" && lat_s=${FILE%%[!0-9.,]*}
lat_int=$(to_int "$lat_s")
lat_frac=${lat_s#*[.,]}
[[ $lat_frac == "$lat_s" ]] && lat_frac=000
lat_frac=${lat_frac}000
lat_frac=${lat_frac:0:3}
lat_ms=$((10#$lat_int * 1000 + 10#$lat_frac))
((lat_ms > MH_LATENCY_MAX_MS)) && warns+=("exec latency ${lat_ms}ms")

# ---- 出力 ------------------------------------------------------------------------
read -r now_epoch now_iso <<<"$(/bin/date '+%s %Y-%m-%dT%H:%M:%S%z')"
status=OK
((${#warns[@]} > 0)) && status=WARN
reasons=""
for w in "${warns[@]+"${warns[@]}"}" "${notes[@]+"${notes[@]}"}"; do
  reasons="$reasons$w; "
done
reasons=${reasons%; }
line="$now_iso $status lat=${lat_ms}ms sysp=$sysp agmsgp=$agmsg_procs hookp=$hook_procs ccsl=$ccsl top=$top${reasons:+ | $reasons}"

if [[ -f $MH_LOG ]]; then
  size=$(/usr/bin/stat -f %z "$MH_LOG" 2>/dev/null || echo 0)
  ((size > MH_LOG_MAX_BYTES)) && mv -f "$MH_LOG" "$MH_LOG.1"
fi
printf '%s\n' "$line" >>"$MH_LOG"
((VERBOSE)) && printf '%s\n' "$line"

notify_desktop() {
  /usr/bin/osascript -e "display notification \"$1\" with title \"Mac health check\" sound name \"Funk\"" >/dev/null 2>&1
}

# webhook.env は source せず MH_WEBHOOK_URL= / MH_WEBHOOK_AUTH_HEADER= 行だけ読む。
# group/other から読める場合は送らない。認証ヘッダーはログに記録しない。
notify_webhook() {
  local url="" auth_header="" perm key val
  [[ -f $MH_WEBHOOK_ENV ]] || return 0
  perm=$(/usr/bin/stat -f %Lp "$MH_WEBHOOK_ENV" 2>/dev/null)
  if [[ $perm != 600 && $perm != 400 ]]; then
    printf '%s webhook skipped: %s must be chmod 600 (is %s)\n' "$now_iso" "$MH_WEBHOOK_ENV" "${perm:-?}" >>"$MH_LOG"
    return 0
  fi
  while IFS='=' read -r key val; do
    case $key in
      MH_WEBHOOK_URL)
        val=${val%\"}
        val=${val#\"}
        url=$val
        ;;
      MH_WEBHOOK_AUTH_HEADER)
        val=${val%\"}
        val=${val#\"}
        auth_header=$val
        ;;
    esac
  done <"$MH_WEBHOOK_ENV"
  [[ $url == https://* ]] || return 0
  local text="[${HOSTNAME%%.*}] $1"
  # Slack (text) / Discord (content) の両方が読めるペイロード
  local curl_args=(
    -fsS -m 10 -o /dev/null
    -H 'Content-Type: application/json'
  )
  [[ -n $auth_header ]] && curl_args+=(-H "$auth_header")
  /usr/bin/curl "${curl_args[@]}" \
    -d "{\"text\":\"$text\",\"content\":\"$text\"}" "$url" 2>>"$MH_LOG" \
    || printf '%s webhook post failed\n' "$now_iso" >>"$MH_LOG"
}

notify() {
  local msg=${1//\"/}
  msg=${msg//\\/}
  notify_desktop "$msg"
  notify_webhook "$msg"
}

((TEST_NOTIFY)) && notify "test notification ($status)"

# 重複抑止: 警告ごとに数字より前の部分をキーにする（"node x69" -> "node x"）。
# 前回から新しいキーが増えたとき、または cooldown 経過時だけ通知する。
# 解消した警告はキー集合から外れるので、再発すればすぐ通知される。
last_file=$MH_STATE_DIR/last_notify
if [[ $status == WARN ]]; then
  wmsg=""
  keys="|"
  for w in "${warns[@]}"; do
    wmsg="$wmsg$w; "
    keys="$keys${w%%[0-9]*}|"
  done
  wmsg=${wmsg%; }
  last_epoch=0
  last_keys=""
  if read_file "$last_file"; then
    last_epoch=$(to_int "${FILE%%$'\n'*}")
    last_keys=${FILE#*$'\n'}
    last_keys=${last_keys%$'\n'}
  fi
  new_key=0
  rest=${keys#|}
  while [[ -n $rest ]]; do
    k=${rest%%|*}
    rest=${rest#*|}
    [[ $last_keys == *"|$k|"* ]] || new_key=1
  done
  if ((new_key)) || ((now_epoch - last_epoch >= MH_NOTIFY_COOLDOWN)); then
    notify "$wmsg"
    last_epoch=$now_epoch
  fi
  printf '%s\n%s\n' "$last_epoch" "$keys" >"$last_file"
  exit 1
fi
[[ -f $last_file ]] && rm -f "$last_file"
exit 0
