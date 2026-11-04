#!/usr/bin/env python3
"""Claude Code の marketplace / user scope plugin を宣言リストに揃える。

- 既定は check（読み取りのみ）。--apply で不足分だけ追加する。
- 削除は一切しない。リスト外の user scope plugin と、user scope と重複する
  local / project scope の登録は「報告のみ」。
- リスト: claude-plugins/plugins.toml（公開）+ plugins.local.toml（非公開・任意）。
  CLAUDE_PLUGINS_LOCAL で非公開リストのパスを上書きできる。

exit code: 0 = 差分なし / 2 = 不足・無効あり（check 時）/ 1 = エラー（source 不一致・apply 未収束など）
"""

from __future__ import annotations

import argparse
import json
import os
import re
import subprocess
import sys
import tomllib
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
PUBLIC = Path(
    os.environ.get("CLAUDE_PLUGINS_PUBLIC") or ROOT / "claude-plugins" / "plugins.toml"
).expanduser()
USER_SETTINGS = (
    Path(os.environ.get("CLAUDE_CONFIG_DIR") or Path.home() / ".claude").expanduser()
    / "settings.json"
)
SKILLS_DIR = "skills-dir"
LOCAL_ENV = os.environ.get("CLAUDE_PLUGINS_LOCAL")
LOCAL = Path(LOCAL_ENV or ROOT / "claude-plugins" / "plugins.local.toml").expanduser()


def load(path: Path, required: bool) -> dict:
    if not path.exists():
        if required or path.is_symlink():
            raise SystemExit(
                f"error: リストが読めない（存在しない or 切れたリンク）: {path}"
            )
        return {}
    with path.open("rb") as f:
        return tomllib.load(f)


def norm(src: str) -> str:
    """GitHub の owner/repo だけ大文字小文字を無視する。URL やパスはそのまま比較する。

    `#ref` が付いていれば ref はそのまま残して比較する。
    """
    s = src.strip()
    if "#" in s:
        base, ref = s.rsplit("#", 1)
        return norm_base(base) + "#" + ref
    return norm_base(s)


def is_local(s: str) -> bool:
    return s.startswith((".", "/", "~"))


def norm_base(s: str) -> str:
    if is_local(s):
        return str(Path(s).expanduser().resolve())
    gh = s.rstrip("/")
    for pre in ("https://github.com/", "git@github.com:"):
        gh = gh.removeprefix(pre)
    gh = gh.removesuffix(".git")
    if re.fullmatch(r"[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+", gh) and not s.startswith(
        (".", "/", "~")
    ):
        return gh.lower()
    return s


def registered_source(m: dict) -> str:
    base = norm_base(m.get("repo") or m.get("url") or m.get("path") or "")
    return base + (f"#{m['ref']}" if m.get("ref") else "")


def user_enabled() -> dict:
    """user scope の設定そのもの（~/.claude/settings.json の enabledPlugins）を読む。"""
    if not USER_SETTINGS.exists():
        return {}
    try:
        data = json.loads(USER_SETTINGS.read_text())
    except json.JSONDecodeError as e:
        raise SystemExit(f"error: {USER_SETTINGS} が JSON として読めない: {e}")
    return data.get("enabledPlugins") or {}


def merge(*docs: tuple[dict, Path]) -> tuple[dict[str, str], list[str]]:
    markets: dict[str, str] = {}
    plugins: list[str] = []
    for doc, base in docs:
        for name, spec in (doc.get("marketplaces") or {}).items():
            src = spec.get("source") if isinstance(spec, dict) else None
            if not src:
                raise SystemExit(f"marketplace '{name}' に source がない")
            if is_local(src):
                # 相対パスはリストファイルのあるディレクトリ基準で解決する
                path, sep, ref = src.partition("#")
                path = str((base / Path(path).expanduser()).resolve())
                src = path + sep + ref
            markets[name] = src
        for pid in (doc.get("plugins") or {}).get("user", []):
            if "@" not in pid:
                raise SystemExit(f"plugin '{pid}' は name@marketplace 形式で書く")
            if pid not in plugins:
                plugins.append(pid)
    return markets, plugins


def claude_json(*args: str):
    cmd = ["claude", "plugin", *args, "--json"]
    r = subprocess.run(cmd, check=False, capture_output=True, text=True)
    if r.returncode != 0:
        raise SystemExit(
            f"error: `{' '.join(cmd)}` が失敗 (rc={r.returncode})\n{r.stderr.strip()}"
        )
    try:
        return json.loads(r.stdout)
    except json.JSONDecodeError as e:
        raise SystemExit(f"error: `{' '.join(cmd)}` の出力が JSON でない: {e}")


def fetch_state(markets: dict[str, str], wanted: list[str]):
    have = {m["name"]: m for m in claude_json("marketplace", "list")}
    installed = claude_json("list")
    user = {p["id"]: p for p in installed if p.get("scope") == "user"}
    miss_m = [n for n in markets if n not in have]
    mismatch = [
        n
        for n in markets
        if n in have and registered_source(have[n]) != norm(markets[n])
    ]
    miss_p = [p for p in wanted if p not in user]
    enabled = user_enabled()
    disabled = [p for p in wanted if p in user and enabled.get(p) is not True]
    return have, installed, user, miss_m, mismatch, miss_p, disabled


def run(cmd: list[str]) -> bool:
    print("  $ " + " ".join(cmd))
    return subprocess.run(cmd, check=False).returncode == 0


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument(
        "--apply", action="store_true", help="不足分を追加する（既定は check のみ）"
    )
    args = ap.parse_args()

    markets, wanted = merge(
        (load(PUBLIC, True), PUBLIC.resolve().parent),
        (load(LOCAL, bool(LOCAL_ENV)), LOCAL.resolve().parent),
    )
    print(
        f"lists: {PUBLIC.relative_to(ROOT) if PUBLIC.is_relative_to(ROOT) else PUBLIC}"
        + (f" + {LOCAL}" if LOCAL.exists() else " (local list なし)")
    )

    for pid in wanted:
        mk = pid.split("@", 1)[1]
        if mk not in markets:
            print(
                f"warn: {pid} の marketplace '{mk}' がリストにない（既に登録済みなら問題なし）"
            )

    have_markets, installed, user, miss_m, mismatch, miss_p, disabled = fetch_state(
        markets, wanted
    )

    print("\n[marketplaces]")
    for n, s in markets.items():
        st = (
            "MISSING " if n in miss_m else ("MISMATCH" if n in mismatch else "ok      ")
        )
        extra = (
            f" -> 登録済み: {registered_source(have_markets[n])}"
            if n in mismatch
            else ""
        )
        print(f"  {st} {n} ({s}){extra}")
    print("\n[user plugins]")
    for p in wanted:
        state = (
            "MISSING" if p in miss_p else ("disabled" if p in disabled else "ok     ")
        )
        print(f"  {state} {p}")

    # skills-dir は Claude がスキルのディレクトリを plugin として見せているだけで
    # install できない（apm 側で管理）。対象外として件数だけ出す。
    pseudo = sorted(p for p in user if p.endswith("@" + SKILLS_DIR))
    extras = sorted(p for p in user if p not in wanted and p not in pseudo)
    dups = sorted(
        (p["id"], p.get("scope"), p.get("projectPath", ""))
        for p in installed
        if p.get("scope") in ("local", "project") and p["id"] in user
    )
    overrides = [
        p
        for p in wanted
        if p in user and bool(user[p].get("enabled")) != (p not in disabled)
    ]
    print("\n[report only: project / local 設定で有効状態が上書きされている]")
    for p in overrides:
        print(
            f"  override {p} (user={'on' if p not in disabled else 'off'}, merged={'on' if user[p].get('enabled') else 'off'})"
        )
    if not overrides:
        print("  (なし)")
    print("\n[report only: リスト外の user scope plugin]")
    for p in extras:
        print(f"  extra   {p}")
    if pseudo:
        print(f"  info    {SKILLS_DIR} のスキル {len(pseudo)} 件は対象外（apm 管理）")
    if not extras:
        print("  (なし)")
    print("\n[report only: user scope と重複する local / project 登録]")
    for pid, scope, path in dups:
        print(f"  dup     {pid} {scope} {path}")
    if not dups:
        print("  (なし)")

    if mismatch:
        print(
            "\nerror: 同名 marketplace の source が宣言と違う。手で確認して直す（自動では変えない）"
        )
        return 1
    if not args.apply:
        drift = bool(miss_m or miss_p or disabled)
        print(f"\ncheck: {'不足あり (--apply で追加/有効化)' if drift else '差分なし'}")
        return 2 if drift else 0

    print("\napply:")
    ok = True
    for n in miss_m:
        ok &= run(["claude", "plugin", "marketplace", "add", markets[n]])
    for p in miss_p:
        ok &= run(["claude", "plugin", "install", p, "--scope", "user"])
    for p in disabled:
        ok &= run(["claude", "plugin", "enable", p, "--scope", "user"])
    if not (miss_m or miss_p or disabled):
        print("  変更なし（no-op）")
        return 0
    _, _, _, miss_m, mismatch, miss_p, disabled = fetch_state(markets, wanted)
    left = miss_m + mismatch + miss_p + disabled
    if left:
        print(
            "error: apply 後も揃っていない（marketplace の実名がキーと違う可能性）: "
            + ", ".join(left)
        )
        return 1
    print("  verified: 宣言どおりに揃った")
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
