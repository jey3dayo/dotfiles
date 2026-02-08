---
name: golang
description: |
  [What] Specialized skill for reviewing Go (Golang) projects. Evaluates idiomatic Go code, error handling patterns, concurrency usage, memory management, and standard library utilization. Provides detailed assessment of goroutine safety, channel patterns, interface design, and performance considerations
  [When] Use when: users mention "Go", "Golang", work with .go files, or request Go-specific code review
  [Keywords] Go, Golang
---

# Golang Project Review

## Overview

Provide specialized review guidance for Go projects, focusing on idiomatic Go patterns, effective error handling, safe concurrency usage, and performance optimization. Evaluate code for Go-specific best practices and community standards.

## Context7 MCP Integration

**Up-to-date Go documentation access** via Context7:

- **Go Standard Library** (`/websites/pkg_go_dev_std_go1_25_3`): 3,636 snippets, score 82.8
- **Effective Go** (`/websites/go_dev_doc`): 3,861 snippets, score 69.8
- **Go Language** (`/golang/go`): 5,743 snippets, score 80.8

Use `mcp__plugin_context7_context7__query-docs` for latest Go idioms, standard library APIs, and best practices.

## 詳細リファレンス

- 評価領域/アンチパターン/ワークフローは `references/golang-details.md` を参照

## 次のステップ

1. 対象リポジトリの目的を確認
2. Context7で最新のGo標準ライブラリ・ベストプラクティスを確認
3. 評価領域を選定
4. レビュー結果を整理

## 関連リソース

- `references/golang-details.md`
- Context7 MCP: Up-to-date Go documentation
