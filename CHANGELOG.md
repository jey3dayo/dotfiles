# CHANGELOG

## 2026-09-23 — ドキュメントをdocs/toolsのSSOTへ集約（ツールREADMEをポインタ化、performance.mdとレビュー基準を撤去し/code-reviewへ委譲）、pam-reattachを[bootstrap.packages]へ移動

## 2026-09-16 — Brewfileの取り込み漏れを検出するbrewfile:diffを追加し、mise移行済みのtapを撤去

## 2026-09-03 — 自己更新ツール（claude/codex）をmise管理から外し、[bootstrap.hooks.post-tools]経由の公式インストーラ導入に変更

## 2026-08-28 — 環境変数を2層管理へ移行（常時注入の.envと、on-demand注入の.env.secrets）

## 2026-08-28 — dotenvxがmise注入の古い.env.localを優先して復号結果に混ぜる自己汚染ループを修正

## 2026-08-21 — Git HTTPSの証明書検証を既定どおり有効にした

## 2026-08-21 — git-wtのworktreeへdotenvの秘密ファイルを複製しないようにした

## 2026-08-21 — JSON LSPをホスト固定パスではなくPATH上のサーバーで起動するようにした

## 2026-08-21 — 撤去済みNix配布ドキュメントをやめ、残存storeのGC手順だけworkflowsに残した

## 2026-07-10 — Home Manager/Nixのdotfiles配布・launchd管理をmise bootstrapへ完全移管

## 2026-07-10 — Nix generation掃除でディスク容量を解放（mac 11.8GiB、pi 1.9GiB）

## 2026-07-10 — repo-localのnix-dotfiles skillをretire

## 2026-07-10 — `~/.npmrc`を廃止し`npm/npmrc`へ移行

## 2026-07-10 — awsumeをmise管理の`pipx:awsume`へ移行

## 2026-07-10 — ZDOTDIRと`~/.zprofile`の読み込み挙動を実測調査

## 2026-02-03 — miseのnpmバックエンドをnpmからpnpmへ移行（`settings.npm.package_manager = "pnpm"`）し、npm/bunグローバルの残骸を削除してローカルリンクのみ維持

mise を v2025.7.17 → v2025.12.13 に更新して `settings.npm.package_manager` を有効化。pnpm 自体は `package_manager = "npm"` に一時的に戻して `npm:pnpm@10.28.2` を導入し、その後 `"pnpm"` へ切り替えた。npm グローバル 30+ / bun グローバル 9 パッケージ（依存込み 2,624 パッケージ）を削除し、ローカルリンク（astro-my-profile, zx-scripts）だけを残した。

## 2025-12-23 — global-package.jsonによるnpmグローバル管理を廃止し、miseの`npm:`プレフィックス管理へ移行
