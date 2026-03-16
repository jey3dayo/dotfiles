# Linearラベル一覧（team: JEY / 取得日: 2026-03-14）

## ラベル

- Research
- term
- term:daily
- term:weekly
- term:monthly
- term:quarterly
- term:semiannual
- term:yearly
- risk
- risk:unknown
- risk:P0
- risk:P1
- risk:P2
- risk:P3
- LT
- Bug
- Improvement
- Feature

## 使い分けの実例

- 期限・周期管理: `term:*`
  - 例: `term:monthly`, `term:yearly`
- 緊急度・重要度: `risk:*`
  - 例: `risk:P1`, `risk:P3`
- 研究・検証: `Research`
- 種別: `Bug` / `Improvement` / `Feature`

## 注意

- ラベルはチームごとに異なる。
- 実行前に最新化したい場合は、GraphQLで `team(id){ labels { nodes { name }}}` を再取得する。
