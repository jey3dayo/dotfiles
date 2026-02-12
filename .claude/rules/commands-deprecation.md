# Commands → Skills 移行ポリシー

## 現状（2026-02-12時点）

Commandsシステムは**廃止予定**です。現在、SkillsシステムへのPhased移行が進行中です。

### 移行フェーズ

| Phase   | ステータス | 対象                              | 期間          |
| ------- | ---------- | --------------------------------- | ------------- |
| Phase 1 | ✅ 完了    | Foundation（基礎スキル作成）      | Week 1        |
| Phase 2 | 🟡 進行中  | Core Workflows（主要6スキル移行） | Week 2-7      |
| Phase 3 | ⏳ 計画中  | Secondary（二次スキル移行）       | Week 10-16    |
| Phase 4 | ⏳ 計画中  | Commands廃止                      | Phase 2完了後 |

### Phase 2 移行スキル（優先順位順）

1. **learnings-knowledge** (Week 2) - 独立、依存なし
2. **code-quality-automation** (Week 2-3) - 独立、自己完結
3. **implementation-engine** (Week 3-4) - ほぼ独立
4. **todo-orchestrator** (Week 4-5) - TaskContext軽依存
5. **task-router** (Week 5-6) - Context7統合依存
6. **code-review-system** (Week 6-7) - 複数スキル依存

## 開発ガイドライン

### 新規機能開発

**必須**: 新規機能は**Skillsとして実装**してください。Commandsとしての実装は禁止です。

**理由**:

- Commands廃止予定のため、新規Commandsは技術的負債となる
- Skillsの方が機能的に優れている（Progressive Disclosure、サポートファイル、高度な制御）
- 移行作業の負担を増やさない

### 既存Commands修正

**移行予定のCommands**: 最小限の修正のみ（重大なバグ修正のみ）
**移行対象外のCommands**: 通常通り修正可能（ただしSkills移行を推奨）

### 移行期間中のルール

**両対応が必要な期間**: Phase 2完了まで（約1ヶ月）

- 既存Commandsはそのまま動作する
- 新規Skillsから旧Commandsを呼び出す場合あり
- ドキュメントでは両方を併記（Commandsに「廃止予定」マーク）

## Skills vs Commands

### Skillsの利点

1. **Progressive Disclosure**: 初回ロード軽量（<20KB）、詳細は必要時にロード
2. **サポートファイル**: ディレクトリ構造でテンプレート、サンプル、スクリプトを整理
3. **呼び出し制御**: `disable-model-invocation`, `user-invocable`で実行タイミングを細かく制御
4. **Agent Skills標準**: 複数のAIツール間で相互運用可能
5. **動的コンテキスト注入**: `` `!command` ``でリアルタイムデータ取得

### Commandsの制限

- 単一ファイル（`.md`）、全体がコンテキストにロード
- 大規模Commandsでコンテキストウィンドウ圧迫
- サポートファイルの管理が困難
- 呼び出し制御が限定的

## 質問・フィードバック

移行に関する質問や提案は、`agents-only`スキルまたは`integration-framework`スキルを参照してください。

---

**最終更新**: 2026-02-12
**次回見直し**: Phase 2完了時（Week 7予定）
