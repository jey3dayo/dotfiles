# Linear プロジェクト一覧（team: JEY / 取得日: 2026-03-29）

## プロジェクト

| プロジェクト名 | ID                                   | ステータス  | 用途                                 |
| -------------- | ------------------------------------ | ----------- | ------------------------------------ |
| finance-ops    | af80afe7-be9f-47f9-a1b2-b2bbd3ed04f4 | In Progress | お金・決済・サブスク・固定費・ポイ活 |
| labs           | d72d07ba-695c-471c-9a29-a8d975bc7976 | In Progress | 学習・調査・技術検証・研究           |
| GBF            | 108edeba-9579-41fb-8b32-82d44678d382 | In Progress | グランブルーファンタジー全般         |
| workbench      | 039463de-1a52-4ce7-a89b-c3d3cd26bb96 | In Progress | 会社雑務・その他個人タスク           |
| cygate         | 05fed0ff-02a4-4934-b340-9340d84541e1 | Backlog     | -                                    |
| pr-labeler     | ce1a8d5f-e5c3-4f5d-8dd2-d293ee135734 | Backlog     | -                                    |

## 使い方

```bash
python3 scripts/linear_task.py create \
  --team JEY \
  --project af80afe7-be9f-47f9-a1b2-b2bbd3ed04f4 \
  --title "タスクタイトル"
```

## 注意

- プロジェクト ID は変わらないが、追加・削除があった場合はこのファイルを更新すること。
- 分類ルールは `SKILL.md` の「Project Routing」セクションを参照。
