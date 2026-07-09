---
name: zsh
description: Use when reviewing or improving Zsh configuration files such as `.zshrc`, `.zprofile`, or plugin-manager config, especially for startup performance, plugin loading, PATH ordering, lazy loading, and modular structure. Do not use for bash-only configuration review.
---

# Zsh Configuration Review

## Overview

Zsh review should begin by confirming that the target is actually Zsh, then checking startup path, plugin loading, and PATH construction in that order. Do not begin from dotfiles-specific implementation details unless the repository clearly uses them.

## When to Use

- `.zshrc` や `.zprofile` をレビューしたい
- 起動が遅い、plugin load が重い、PATH 順序が怪しい
- lazy loading や plugin manager の整理をしたい
- Zsh 設定を modular に保てているか確認したい

使わない場面:

- bash-only 設定をレビューしたい
- fish や nushell など別 shell の相談
- shell 一般論だけで、具体的な Zsh 設定確認が不要

## First Pass

1. Zsh 設定かどうかを確認する
2. entry point を確認する (`.zshrc`, `.zprofile`, loader)
3. startup cost が高そうな箇所を確認する
4. plugin manager と lazy loading の有無を確認する
5. PATH の構築順と重複除去を確認する

## Review Areas

### 1. Startup Performance

- 起動時間を測る導線があるか
- 重い `source` や同期初期化が多すぎないか
- `zprof` や遅延読み込みを使う余地があるか

### 2. Plugin Management

- plugin manager が何か
- plugin 数が多すぎないか
- lazy loading や priority 設計があるか
- 重複機能 plugin がないか

### 3. PATH Management

- `.zprofile` と `.zshrc` の責務が分かれているか
- version manager / user bin / system path の順序が妥当か
- 重複除去や存在確認が入っているか

### 4. Structure

- loader と各 module が分かれているか
- OS 別設定や tool 別設定を分離できているか
- local override を安全に差し込めるか

### 5. Robustness

- 依存コマンドが無いときに壊れないか
- エラーメッセージや fallback があるか
- machine-specific 設定を混ぜすぎていないか

## Dotfiles-Specific Notes

この workspace のように dotfiles 事情が強い場合でも、まず一般的な Zsh レビューを優先する。その後で必要なら:

- Sheldon などの plugin manager 設計
- tiered lazy loading
- `.zwc` コンパイル
- machine-local override

の順に見る。

## Context7

Context7 は oh-my-zsh や zinit など、特定 plugin manager や framework の公式仕様確認が必要なときだけ使う。一般的なレビュー入口としては不要。

## Common Mistakes

- bash と Zsh を同じ基準でレビューする
- dotfiles 固有の構成例を一般論として押し付ける
- PATH 順序より先に alias や見た目から触り始める
- startup performance を測らずに最適化案を決める
