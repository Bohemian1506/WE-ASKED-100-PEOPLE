# GitHub Actions with Claude Code セットアップガイド

## 概要
このプロジェクトでは、GitHub ActionsでClaude Code Assistantを使用して自動コードレビューとセキュリティチェックを実行します。

## 必要な設定

### 1. GitHub Secrets設定

以下のシークレットをGitHubリポジトリに設定してください：

1. **リポジトリの設定ページ**にアクセス
   ```
   https://github.com/[username]/WE-ASKED-100-PEOPLE/settings/secrets/actions
   ```

2. **必要なシークレット**
   - `ANTHROPIC_API_KEY`: Claude Code用のAnthropic APIキー
   
### 2. Anthropic API Key取得方法

1. [Anthropic Console](https://console.anthropic.com/)にアクセス
2. アカウント作成またはログイン
3. API Keysセクションで新しいキーを作成
4. キーをコピーしてGitHub Secretsに設定

### 3. ワークフロー実行条件

#### 自動実行される場面：
- **新しいPRが作成された時**
  - 自動的にコードレビューとセキュリティチェックを実行
  
- **@claude メンション時**
  - Issue、PR、コメントで `@claude` をメンションした時に実行
  
#### 実行されるジョブ：
1. **claude-assistant**: 一般的なコードレビュー
2. **claude-security-review**: セキュリティ専門レビュー

## 使用方法

### 1. 自動レビュー
```bash
# 新しいブランチを作成してPRを開くだけで自動実行
git checkout -b feature/new-feature
git push origin feature/new-feature
# GitHub上でPRを作成 → 自動でレビュー実行
```

### 2. 手動レビュー要求
```markdown
@claude このコードをレビューしてください。特にセキュリティ面を重点的にお願いします。
```

### 3. 特定の質問
```markdown
@claude この認証処理にSQLインジェクションの脆弱性はありませんか？
```

## レビュー項目

### 一般レビュー（claude-assistant）
- セキュリティ（SQLインジェクション、CSRF対策）
- Rails 8ベストプラクティス準拠
- パフォーマンス（N+1問題等）
- コード可読性・保守性
- テストカバレッジ
- 日本語化対応

### セキュリティレビュー（claude-security-review）
- SQLインジェクション脆弱性
- CSRF保護
- 認証・認可の実装
- 機密情報漏洩リスク
- 入力値サニタイゼーション
- セッション管理

## トラブルシューティング

### よくある問題

1. **ANTHROPIC_API_KEY が設定されていない**
   - エラー: `Error: Input required and not supplied: anthropic-api-key`
   - 解決: GitHub Secretsに正しくAPIキーを設定

2. **権限エラー**
   - エラー: `Error: Resource not accessible by integration`
   - 解決: リポジトリの Actions 権限設定を確認

3. **ワークフローが実行されない**
   - 確認項目:
     - `.github/workflows/claude.yml` が正しく配置されているか
     - ファイル内のYAML構文が正しいか
     - ブランチが `main` または `develop` か

### デバッグ方法

1. **GitHub Actionsログ確認**
   ```
   リポジトリ → Actions タブ → 該当のワークフロー実行をクリック
   ```

2. **ローカルでのYAML検証**
   ```bash
   # yamllintを使用（要インストール）
   yamllint .github/workflows/claude.yml
   ```

## 追加設定オプション

### カスタム指示の変更
`custom-instructions` セクションを編集してレビュー観点を調整可能：

```yaml
custom-instructions: |
  特定の技術スタックに合わせた指示を記載...
```

### 実行条件の調整
`if` 条件を変更して実行タイミングを調整：

```yaml
if: |
  contains(github.event.comment.body, '@claude') && 
  github.actor == 'specific-user'
```

## セキュリティ考慮事項

- APIキーは必ずGitHub Secretsで管理
- プライベートリポジトリでの使用を推奨
- レビュー結果に機密情報が含まれないよう注意
- 定期的なAPIキーローテーション推奨