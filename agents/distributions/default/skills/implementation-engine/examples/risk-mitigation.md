# Risk Mitigation

Implementation Engineのリスク軽減戦略。Rollback、git checkpoint、実行前確認、問題識別の詳細。

## Rollback Strategy

### Git Checkpoints

### 自動checkpoint作成:

```bash
# Implementation Engineは各フェーズ完了時に自動的にcheckpointを作成

Phase 1 完了 → git commit -m "checkpoint: complete setup phase"
Phase 2 完了 → git commit -m "checkpoint: complete planning phase"
Phase 3 完了 → git commit -m "checkpoint: complete adaptation phase"
Phase 4 完了 → git commit -m "checkpoint: complete execution phase"
Phase 5 完了 → git commit -m "checkpoint: complete QA phase"
Phase 6 完了 → git commit -m "checkpoint: complete validation phase"
```

### 重要:

### checkpoint確認:

```bash
# 最近のcheckpointsを表示
git log --grep="checkpoint:" --oneline -10
```

### 特定checkpointへのrollback:

```bash
# checkpoint一覧表示
git log --grep="checkpoint:" --oneline

# 特定のcheckpointにロールバック
git reset --hard <commit-hash>
```

### Manual Checkpoints

### 重要な変更前にcheckpointを作成:

```bash
# 手動checkpoint作成
git add .
git commit -m "checkpoint: before major refactoring"
```

### 推奨タイミング:

1. 大規模なリファクタリング前
2. 破壊的変更前
3. 外部依存関係の更新前
4. データベーススキーマ変更前
5. API契約の変更前

### Stash Strategy

### 一時的な変更の保存:

```bash
# 現在の変更をstash
git stash push -m "WIP: implementation in progress"

# stash一覧表示
git stash list

# stashを復元
git stash pop
```

## Potential Issues識別

### 事前リスク分析

### plan.md作成時に潜在的問題を識別:

```markdown
## Risk Mitigation

### Potential Issues

#### High Risk

1. **Breaking Change: API Contract Modification**

   - Impact: Existing API consumers will break
   - Probability: High
   - Mitigation:
     - Create API version v2
     - Maintain backward compatibility for v1
     - Add deprecation warnings
     - Provide migration guide

2. **Database Migration Complexity**
   - Impact: Data loss or corruption possible
   - Probability: Medium
   - Mitigation:
     - Create backup before migration
     - Test migration in staging
     - Implement rollback script
     - Use transactional migrations

#### Medium Risk

3. **Performance Degradation**

   - Impact: Slower response times
   - Probability: Medium
   - Mitigation:
     - Add performance benchmarks
     - Monitor response times
     - Implement caching layer
     - Optimize database queries

4. **Dependency Conflicts**
   - Impact: Build failures
   - Probability: Low
   - Mitigation:
     - Lock dependency versions
     - Test in clean environment
     - Use dependency resolution tools
     - Document version requirements

#### Low Risk

5. **UI/UX Inconsistencies**
   - Impact: User confusion
   - Probability: Low
   - Mitigation:
     - Follow design system
     - UI/UX review before release
     - User testing
     - Gather feedback early
```

### 動的リスク検出

### 実装中のリスク検出:

```typescript
// リスク検出システム
function detectRisks(implementation) {
  const risks = [];

  // Breaking changes検出
  if (hasAPIChanges(implementation)) {
    risks.push({
      type: "breaking-change",
      severity: "high",
      description: "API contract modifications detected",
      mitigation: "Add API versioning and deprecation warnings",
    });
  }

  // Performance impact検出
  if (hasPerformanceImpact(implementation)) {
    risks.push({
      type: "performance",
      severity: "medium",
      description: "Potential performance degradation",
      mitigation: "Add benchmarks and monitoring",
    });
  }

  // Security vulnerabilities検出
  if (hasSecurityIssues(implementation)) {
    risks.push({
      type: "security",
      severity: "high",
      description: "Security vulnerabilities found",
      mitigation: "Fix vulnerabilities before deployment",
    });
  }

  return risks;
}
```

## 実行前確認

### Pre-Implementation Checklist

### 実装開始前の確認:

```markdown
## Pre-Implementation Checklist

### Environment

- [ ] Git repository is clean (no uncommitted changes)
- [ ] On correct branch
- [ ] Latest changes pulled from remote
- [ ] Dependencies installed and up-to-date

### Backups

- [ ] Database backup created (if applicable)
- [ ] Configuration files backed up
- [ ] Environment variables documented

### Planning

- [ ] Requirements clearly defined
- [ ] Architecture documented
- [ ] Integration points identified
- [ ] Testing strategy defined

### Risk Assessment

- [ ] Potential issues identified
- [ ] Mitigation strategies defined
- [ ] Rollback plan documented
- [ ] Stakeholders informed
```

### 確認プロンプト:

```
Ready to start implementation?

Source: https://github.com/user/feature
Target: Current project

Risks identified:
- Breaking changes to API
- Database migration required
- Performance impact possible

Mitigation strategies in place:
- API versioning configured
- Migration rollback script ready
- Performance benchmarks prepared

Git status: Clean
Branch: feature/new-implementation
Backup: Created

Continue? [Y/n]
```

### Phase Transition Confirmation

### 各フェーズ完了時の確認:

```
Phase 3 (Intelligent Adaptation) Complete

Summary:
- Dependencies mapped to project equivalents
- Code patterns adapted to project style
- 15/15 transformations successful

Verification:
- ✓ All imports updated
- ✓ Naming conventions applied
- ✓ Error handling standardized
- ✓ Test style consistent

Checkpoint created: abc123def

Proceed to Phase 4 (Implementation Execution)? [Y/n]
```

## Impact Analysis

### Change Impact Assessment

### 変更の影響範囲を分析:

```typescript
function assessImpact(changes) {
  const impact = {
    files: [],
    functions: [],
    components: [],
    apis: [],
    database: [],
    dependencies: [],
  };

  // ファイルレベルの影響
  impact.files = identifyAffectedFiles(changes);

  // 関数レベルの影響
  impact.functions = identifyAffectedFunctions(changes);

  // コンポーネントレベルの影響
  impact.components = identifyAffectedComponents(changes);

  // API契約への影響
  impact.apis = identifyAPIChanges(changes);

  // データベーススキーマへの影響
  impact.database = identifyDatabaseChanges(changes);

  // 依存関係への影響
  impact.dependencies = identifyDependencyChanges(changes);

  return impact;
}
```

### 影響レポート:

```markdown
## Impact Analysis

### Files Modified: 12

- src/auth/login.ts (core)
- src/api/client.ts (integration)
- src/store/auth.ts (state)
- components/LoginForm.tsx (UI)
- ...

### Functions Modified: 23

- userAuthentication() - Breaking change
- fetchUserProfile() - Signature change
- saveToken() - Implementation change
- ...

### API Changes: 3

- POST /auth/login - Response format changed (Breaking)
- GET /auth/profile - New endpoint (Non-breaking)
- DELETE /auth/logout - Headers changed (Breaking)

### Database Changes: 1

- users table - Added last_login column (Non-breaking)

### Dependency Changes: 2

- Added: date-fns@2.30.0
- Removed: moment@2.29.4

### Risk Level: Medium

Breaking changes require:

- API versioning
- Migration guide
- Deprecation period
```

## Recovery Procedures

### Quick Recovery

### 即座にロールバック:

```bash
# 最後のcheckpointに戻る
git reset --hard HEAD~1

# 特定のcheckpointに戻る
git log --grep="checkpoint:" --oneline
git reset --hard <commit-hash>

# stashから復元
git stash pop
```

### Partial Recovery

### 特定のファイルのみロールバック:

```bash
# 特定ファイルを復元
git checkout HEAD~1 -- src/auth/login.ts

# 複数ファイルを復元
git checkout HEAD~1 -- src/auth/*.ts
```

### Database Recovery

### データベース変更のロールバック:

```bash
# Rollback scriptを実行
npm run db:rollback

# または手動でロールバック
psql -d mydb -f rollback.sql
```

## Monitoring & Alerts

### Implementation Monitoring

### 実装中のモニタリング:

```typescript
// モニタリングシステム
function monitorImplementation(session) {
  // 進捗モニタリング
  const progress = trackProgress(session);

  // 品質モニタリング
  const quality = trackQuality(session);

  // エラーモニタリング
  const errors = trackErrors(session);

  // パフォーマンスモニタリング
  const performance = trackPerformance(session);

  // アラート発行
  if (quality.lintErrors > 0) {
    alert("Lint errors detected");
  }

  if (quality.testFailures > 0) {
    alert("Test failures detected");
  }

  if (performance.buildTime > threshold) {
    alert("Build time exceeds threshold");
  }
}
```

### Quality Gates

### 品質ゲート:

```typescript
// 各フェーズの品質ゲート
const qualityGates = {
  phase1: {
    required: [
      "session_files_created",
      "source_analyzed",
      "project_understood",
    ],
  },
  phase2: {
    required: ["plan_created", "tasks_defined", "risks_identified"],
  },
  phase3: {
    required: [
      "dependencies_mapped",
      "code_patterns_adapted",
      "conflicts_resolved",
    ],
  },
  phase4: {
    required: [
      "core_implemented",
      "integrations_complete",
      "checkpoint_created",
    ],
  },
  phase5: {
    required: [
      "lint_passing",
      "tests_passing",
      "type_check_passing",
      "build_succeeds",
    ],
  },
  phase6: {
    required: [
      "features_complete",
      "integrations_verified",
      "documentation_updated",
      "report_generated",
    ],
  },
};

// ゲートチェック
function checkQualityGate(phase, results) {
  const gate = qualityGates[phase];
  const passed = gate.required.every((req) => results[req] === true);

  if (!passed) {
    const failed = gate.required.filter((req) => !results[req]);
    throw new Error(`Quality gate failed: ${failed.join(", ")}`);
  }

  return true;
}
```

## Disaster Recovery

### Complete Rollback

### 完全なロールバック手順:

```bash
# 1. 実装前のcommitを特定
git log --oneline | grep "checkpoint: before implementation"

# 2. 完全にロールバック
git reset --hard <commit-before-implementation>

# 3. セッションファイルを削除
rm -rf implement/

# 4. 変更を確認
git status

# 5. リモートにpush（force push必要な場合のみ）
# 注意: main/masterブランチへのforce pushは避ける
git push --force-with-lease origin feature-branch
```

### Incremental Rollback

### 段階的なロールバック:

```bash
# Phase 6 → Phase 5
git reset --hard $(git log --grep="checkpoint: complete QA phase" --format="%H" -1)

# Phase 5 → Phase 4
git reset --hard $(git log --grep="checkpoint: complete execution phase" --format="%H" -1)

# 必要なフェーズまで繰り返す
```

## ベストプラクティス

### リスク軽減:

1. すべてのフェーズ完了時にcheckpointを作成
2. 大きな変更前に手動checkpointを作成
3. 潜在的問題を事前に識別
4. 各問題に対する軽減戦略を用意

### 回復手順:

1. ロールバック計画を常に用意
2. データベース変更は必ずrollback scriptを作成
3. 本番環境への適用前にステージングでテスト
4. モニタリングとアラートを設定

### 品質保証:

1. 各フェーズで品質ゲートをチェック
2. 継続的にテストを実行
3. エラーを即座に検出
4. パフォーマンスを常に監視

### コミュニケーション:

1. リスクを明確に文書化
2. ステークホルダーに通知
3. 進捗を定期的に報告
4. 問題が発生したら即座に報告
