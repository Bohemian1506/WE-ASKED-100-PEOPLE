# WE ASKED 100 PEOPLE

## プロジェクト概要
「100人に聞きました」形式のクイズ用データ収集アプリケーション。質問を作成し、多くの人から回答を集めて自動集計する、シンプルで使いやすいWebサービス

## 技術スタック
- **Ruby**: 3.3.6
- **Rails**: 8.0.0 (標準認証使用)
- **Database**: PostgreSQL 15
- **CSS**: Bootstrap 5.3
- **JS**: Stimulus
- **Development**: Docker Compose
- **Background Jobs**: Solid Queue (Rails 8標準)
- **Cache**: Solid Cache (Rails 8標準)
- **CI/CD**: GitHub Actions

## 認証システム
- **質問作成者**: Rails 8標準認証（メール+パスワード）
- **回答者**: Cookie/UUID方式（登録不要、30日間有効）

```ruby
# Cookie有効期限
RESPONDENT_COOKIE_EXPIRES_IN = 30.days
```

## データベース構造
- **users**: 質問作成者（Rails 8標準認証）
- **questions**: 質問（短縮ID、締切管理）
- **answers**: 回答（正規化処理済み）
- **answer_groups**: 回答グループ（自動グルーピング）

## 主要機能
1. **質問管理**: 質問の作成・編集・削除、締切自動管理
2. **回答収集**: 自由記述形式（50文字まで、絵文字OK）、重複防止
3. **自動集計**: 類似回答の自動グルーピング、上位10件ランキング表示
4. **SNS連携**: X（Twitter）シェア機能、URLコピー機能

## クイックスタート
```bash
# 起動
docker-compose up -d

# DB作成・マイグレーション
docker-compose exec web rails db:create
docker-compose exec web rails db:migrate

# ブラウザでアクセス
# http://localhost:3000
```

## 回答正規化ロジック
```ruby
# app/services/answer_normalizer.rb
def self.normalize(text)
  text.strip                     # 前後の空白削除
      .downcase                   # 小文字統一
      .tr('０-９ａ-ｚＡ-Ｚ', '0-9a-za-z')  # 全角→半角
      .gsub(/[[:space:]]+/, '')   # 空白削除
end
```

## 環境変数
```bash
# .env.local
DATABASE_URL=postgresql://postgres:password@db:5432/we_asked_100_people_development
RAILS_ENV=development
SECRET_KEY_BASE=your-secret-key-base
```

## 開発コマンド
```bash
# 基本操作
docker-compose up -d              # 起動
docker-compose down               # 停止
docker-compose logs -f web        # ログ確認

# データベース
docker-compose exec web rails db:migrate           # マイグレーション
docker-compose exec web rails db:drop db:create db:migrate  # リセット

# テスト・品質チェック
docker-compose exec web bundle exec rspec          # テスト実行
docker-compose exec web bundle exec rubocop        # RuboCop実行
docker-compose exec web bundle exec rubocop -A     # 自動修正
```

## プロジェクト構造
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
├── spec/                      # テスト
├── docker-compose.yml
├── Dockerfile
└── CLAUDE.md                  # AI開発用仕様書
```

## 開発について
詳細な開発ルールとセットアップ手順は以下を参照：
- **[要件定義書](docs/requirements.md)** - 機能要件・非機能要件
- **[開発計画書](docs/development-plan.md)** - フェーズ別実装計画
- **[DB設計書](docs/database-design.md)** - テーブル定義・ER図
- **[UI/UX設計書](docs/ui-flow.md)** - 画面遷移・デザイン
- **[技術仕様書](docs/technical-specifications.md)** - 実装詳細

## 重要ポイント
- **質問作成者認証**: Rails 8標準認証（has_secure_password）
- **回答者識別**: Cookie/UUID方式（30日間有効、登録不要）
- **セキュリティ**: CSRF対策、SQLインジェクション対策
- **パフォーマンス**: N+1対策、適切なインデックス設定
- **重複防止**: Cookie/UUIDによる同一人物の複数回答防止
- **自動処理**: 締切時刻での自動クローズ（Solid Queue）

## 今後の拡張予定

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