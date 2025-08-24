# WE ASKED 100 PEOPLE

## 📋 プロジェクト概要

「100人に聞きました」形式のクイズ用データ収集アプリケーション。質問を作成し、多くの人から回答を集めて自動集計する、シンプルで使いやすいWebサービスです。

### 解決する課題
- クイズ番組のような「100人に聞きました」形式のデータ収集が困難
- 類似回答のグルーピングを手動で行うのが大変
- 回答収集から集計までを一元管理するツールがない

### 主な特徴
- 📝 **簡単な質問作成**: 質問タイトルと締切を設定するだけ
- 🔗 **短縮URL共有**: `/q/xxxxx` 形式の短いURLで簡単共有
- 🚫 **登録不要で回答**: 回答者はアカウント登録不要
- 🤖 **自動グルーピング**: 類似回答を自動的にまとめて集計
- 📊 **ランキング表示**: 上位10件の回答をランキング形式で表示
- 🐦 **SNS連携**: X（Twitter）でワンクリックシェア

## 🛠️ 技術スタック

- **Ruby**: 3.3.6
- **Rails**: 8.0.0（標準認証使用）
- **Database**: PostgreSQL 15
- **CSS**: Bootstrap 5.3
- **JavaScript**: Stimulus
- **Development**: Docker Compose
- **Background Jobs**: Solid Queue（Rails 8標準）
- **Cache**: Solid Cache（Rails 8標準）
- **CI/CD**: GitHub Actions

## 🔐 認証システム

### 質問作成者認証
- Rails 8標準認証（`has_secure_password`）
- メール + パスワードでログイン
- 複数の質問を作成・管理可能

### 回答者識別
- Cookie/UUID方式（登録不要）
- 重複回答を自動防止
- 30日間のCookie保持

```ruby
# Cookie有効期限
RESPONDENT_COOKIE_EXPIRES_IN = 30.days
```

## 🚀 クイックスタート

### 1. 必要な環境
- Docker & Docker Compose
- Git

### 2. セットアップ
```bash
# リポジトリクローン
git clone [repository-url]
cd WE-ASKED-100-PEOPLE

# 環境変数設定
cp .env.example .env.local
# 必要に応じて.env.localを編集

# Docker環境起動
docker-compose up -d

# データベース作成・マイグレーション
docker-compose exec web rails db:create
docker-compose exec web rails db:migrate

# ブラウザでアクセス
# http://localhost:3000
```

### 3. 環境変数
```bash
# .env.local
DATABASE_URL=postgresql://postgres:password@db:5432/we_asked_100_people_development
RAILS_ENV=development
SECRET_KEY_BASE=your-secret-key-base
```

## 💾 データベース構造

- **users**: 質問作成者（Rails 8標準認証）
- **questions**: 質問（短縮ID、締切管理）
- **answers**: 回答（正規化処理済み）
- **answer_groups**: 回答グループ（自動グルーピング）

## 📱 主要機能

### 1. 質問管理
- 質問の作成・編集・削除
- 締切自動管理（デフォルト2週間）
- カード形式での一覧表示
- 短縮URL自動生成

### 2. 回答収集
- 自由記述形式（50文字まで、絵文字OK）
- Cookie/UUIDによる重複防止
- 締切後の自動受付停止
- 回答後のSNSシェア誘導

### 3. 自動集計
- 類似回答の自動グルーピング
  - 大文字/小文字の統一
  - 全角/半角の正規化
  - 空白の除去
- 上位10件のランキング表示
- 手動グルーピング調整機能

### 4. SNS連携
- X（Twitter）シェアボタン
- URLコピー機能
- OGPタグ対応（予定）

## 💻 開発コマンド

### 基本操作
```bash
# 起動
docker-compose up -d

# 停止
docker-compose down

# ログ確認
docker-compose logs -f web

# コンソール起動
docker-compose exec web rails console
```

### データベース
```bash
# マイグレーション
docker-compose exec web rails db:migrate

# リセット（開発環境）
docker-compose exec web rails db:drop db:create db:migrate

# Seedデータ投入
docker-compose exec web rails db:seed
```

### テスト・品質チェック
```bash
# 全テスト実行
docker-compose exec web bundle exec rspec

# RuboCop実行
docker-compose exec web bundle exec rubocop

# 自動修正
docker-compose exec web bundle exec rubocop -A
```

## 📁 プロジェクト構造

```
WE-ASKED-100-PEOPLE/
├── app/
│   ├── controllers/             # コントローラー
│   ├── models/                 # モデル
│   ├── views/                  # ビュー
│   ├── services/               # ビジネスロジック
│   │   ├── answer_normalizer.rb      # 回答正規化
│   │   └── answer_grouping_service.rb # グルーピング処理
│   └── javascript/
│       └── controllers/        # Stimulusコントローラー
├── config/
│   └── locales/               # 日本語化ファイル
├── db/
├── docs/                      # ドキュメント
│   ├── requirements.md        # 要件定義書
│   ├── development-plan.md    # 開発計画書
│   ├── database-design.md     # DB設計書
│   ├── ui-flow.md            # UI/UX設計書
│   └── technical-specifications.md # 技術仕様書
├── spec/                      # テスト
├── docker-compose.yml
├── Dockerfile
└── CLAUDE.md                  # AI開発用仕様書
```

## 📖 開発ドキュメント

詳細な開発情報は以下を参照：

- **[要件定義書](docs/requirements.md)** - 機能要件・非機能要件
- **[開発計画書](docs/development-plan.md)** - フェーズ別実装計画
- **[DB設計書](docs/database-design.md)** - テーブル定義・ER図
- **[UI/UX設計書](docs/ui-flow.md)** - 画面遷移・デザイン
- **[技術仕様書](docs/technical-specifications.md)** - 実装詳細

## 🔧 開発ルール

### コーディング規約
- **Ruby**: RuboCop準拠
- **CSS**: Bootstrap 5ユーティリティ活用
- **JavaScript**: Stimulusコントローラー
- **テスト**: RSpec（単体・統合テスト）

### Git運用
- **mainブランチ保護**: 直接プッシュ禁止
- **機能開発**: `feature/feature-name`
- **バグ修正**: `fix/bug-description`
- **PR必須**: レビュー後マージ

### 回答正規化ロジック
```ruby
# app/services/answer_normalizer.rb
def self.normalize(text)
  text.strip                     # 前後の空白削除
      .downcase                   # 小文字統一
      .tr('０-９ａ-ｚＡ-Ｚ', '0-9a-za-z')  # 全角→半角
      .gsub(/[[:space:]]+/, '')   # 空白削除
end
```

## 🧪 テスト

```bash
# 全テスト実行
docker-compose exec web bundle exec rspec

# 特定のテスト
docker-compose exec web bundle exec rspec spec/models/question_spec.rb

# カバレッジ付き実行
docker-compose exec web COVERAGE=true bundle exec rspec
```

## 🚨 重要ポイント

- **セキュリティ**: CSRF対策、SQLインジェクション対策
- **パフォーマンス**: N+1対策、適切なインデックス設定
- **重複防止**: Cookie/UUIDによる同一人物の複数回答防止
- **自動処理**: 締切時刻での自動クローズ（Solid Queue）

## 📈 今後の拡張予定

### Phase 2
- レスポンシブデザイン対応
- より高度な類似判定（形態素解析）
- グラフによる視覚的表示
- 複数選択式の質問形式

### Phase 3
- API公開
- 多言語対応
- リアルタイム集計
- 有料プラン（無制限回答数など）

## 📞 サポート

- Issue報告: [GitHub Issues](link-to-issues)
- 開発相談: docsディレクトリ内の各種ガイドを参照

---

*WE ASKED 100 PEOPLE - クイズデータ収集をもっとスマートに*