# EventPay Manager - MVP以降の実装ロードマップ

## 📊 MVP以降のフェーズ分け

### Phase 2: 利便性向上（MVP + 1〜2ヶ月）
基本機能を快適に使えるようにする改善

### Phase 3: 拡張機能（MVP + 3〜4ヶ月）
より高度な要求に応える機能追加

### Phase 4: エコシステム構築（MVP + 6ヶ月〜）
他アプリとの連携・プラットフォーム化

---

## 🚀 Phase 2: 利便性向上

### 1. 認証機能の拡張

#### Google認証の実装
```ruby
# Gemfile
gem 'omniauth'
gem 'omniauth-google-oauth2'
gem 'omniauth-rails_csrf_protection'

# 実装ポイント
- 既存のメール認証との併用
- アカウント連携機能
- 初回ログイン時の情報補完フロー
```

#### LINE認証の実装
```ruby
# 日本市場向けの重要機能
gem 'omniauth-line'

# 考慮事項
- LINE Messaging APIとの連携準備
- 通知機能との統合を視野に
```

### 2. UI/UXの改善

#### プログレッシブWebアプリ（PWA）化
```javascript
// manifest.json
{
  "name": "EventPay Manager",
  "short_name": "EventPay",
  "start_url": "/",
  "display": "standalone",
  "theme_color": "#007bff"
}

// 実装項目
- オフライン対応
- ホーム画面追加
- プッシュ通知
```

#### ダークモード対応
```scss
// CSS変数で管理
:root {
  --bg-primary: #ffffff;
  --text-primary: #333333;
}

[data-theme="dark"] {
  --bg-primary: #1a1a1a;
  --text-primary: #ffffff;
}
```

### 3. 通知機能の強化

#### LINEメッセージ連携
```ruby
# LINE Messaging API
class LineNotificationService
  def send_reminder(participant)
    # 参加者のLINE IDに直接通知
    # 既読確認も可能
  end
end
```

#### リアルタイム通知
```ruby
# Action Cable実装
class PaymentChannel < ApplicationCable::Channel
  def subscribed
    stream_for event
  end
end
```

### 4. データ分析機能

#### 幹事向けダッシュボード
- 支払い進捗の可視化
- 過去イベントの統計
- 参加率の推移グラフ

---

## 🔧 Phase 3: 拡張機能

### 1. 料金体系の柔軟化

#### 参加者別料金設定
```ruby
# モデル拡張
class Participation < ApplicationRecord
  # 基本料金をオーバーライド可能に
  attribute :custom_fee, :integer
  
  def actual_fee
    custom_fee || round.fee
  end
end

# 使用例
- 学生割引
- 幹事無料
- 早期割引
```

#### 支払い方法の記録
```ruby
class Payment < ApplicationRecord
  enum method: {
    cash: 0,
    bank_transfer: 1,
    paypay: 2,
    line_pay: 3,
    credit_card: 4
  }
  
  belongs_to :participation
  attribute :paid_at, :datetime
  attribute :note, :string
end
```

### 2. イベントテンプレート機能

```ruby
class EventTemplate < ApplicationRecord
  # よく使う設定を保存
  has_many :template_rounds
  
  def apply_to(event)
    # テンプレートから新規イベント作成
  end
end

# 用途
- 定例飲み会
- 歓送迎会パターン
- 部署別テンプレート
```

### 3. 高度な集計・レポート

#### エクスポート機能
```ruby
class EventExporter
  def to_excel(event)
    # 参加者リスト
    # 支払い状況
    # 会計報告書
  end
  
  def to_pdf(event)
    # 領収書一括発行
    # 精算報告書
  end
end
```

### 4. 権限管理の細分化

```ruby
class EventRole < ApplicationRecord
  # 複数幹事対応
  enum role: {
    owner: 0,      # 主幹事
    organizer: 1,  # 副幹事
    accountant: 2, # 会計担当
    viewer: 3      # 閲覧のみ
  }
end
```

---

## 🌐 Phase 4: エコシステム構築

### 1. API公開

#### RESTful API v1
```ruby
# app/controllers/api/v1/events_controller.rb
module Api
  module V1
    class EventsController < ApiController
      # 外部アプリ連携用
      def index
        @events = current_user.events
        render json: EventSerializer.new(@events)
      end
    end
  end
end
```

#### GraphQL対応
```ruby
# より柔軟なデータ取得
gem 'graphql'

class EventPaySchema < GraphQL::Schema
  query QueryType
  mutation MutationType
end
```

### 2. 姉妹アプリとの連携

#### EventTodo Manager連携
```ruby
# TODOタスクの自動生成
class EventTodoIntegration
  def create_todos_for_event(event)
    # 会場予約TODO
    # 参加確認TODO
    # 精算TODO
  end
end
```

#### EventChat連携
```ruby
# リアルタイムチャット統合
class EventChatIntegration
  def create_chat_room(event)
    # イベント専用チャットルーム
    # 参加者自動招待
  end
end
```

### 3. 外部サービス連携

#### カレンダー連携
- Googleカレンダー自動登録
- Outlookカレンダー対応
- iCalフォーマット出力

#### 会計ソフト連携
- freee API
- マネーフォワード
- 弥生会計

#### 決済サービス統合
- PayPay for Business
- LINE Pay
- Square

---

## 🔒 セキュリティ・インフラ強化

### 1. セキュリティ強化

```ruby
# 二要素認証
gem 'devise-two-factor'

# APIレート制限
gem 'rack-attack'

# 監査ログ
class AuditLog < ApplicationRecord
  # すべての重要操作を記録
end
```

### 2. パフォーマンス最適化

```ruby
# Redisキャッシュ導入
gem 'redis'
gem 'hiredis'

# 検索エンジン
gem 'elasticsearch-rails'

# 画像最適化
gem 'image_processing'
```

### 3. インフラ整備

```yaml
# Kubernetes対応
apiVersion: apps/v1
kind: Deployment
metadata:
  name: eventpay-manager

# CI/CD強化
# - GitHub Actions
# - 自動デプロイ
# - A/Bテスト基盤
```

---

## 💰 マネタイズ戦略

### 1. フリーミアムモデル

#### 無料プラン
- 月3イベントまで
- 参加者30名まで
- 基本機能のみ

#### プロプラン（月額500円）
- イベント無制限
- 参加者無制限
- テンプレート機能
- 優先サポート

#### ビジネスプラン（月額2,000円）
- 複数幹事機能
- API利用
- 管理者権限
- SLA保証

### 2. 追加課金オプション

- SMS通知: 10円/通
- 領収書発行: 50円/枚
- データ長期保存: 100円/年
- カスタムドメイン: 300円/月

---

## 📈 成長指標（KPI）

### Phase 2終了時点
- MAU: 10,000人
- イベント作成数: 5,000/月
- リテンション率: 60%

### Phase 3終了時点
- MAU: 50,000人
- 有料会員: 1,000人
- ARPU: 800円

### Phase 4終了時点
- MAU: 200,000人
- 有料会員: 10,000人
- 連携アプリ: 5個以上

---

## 🗓️ 実装優先順位マトリクス

| 機能             | 実装難易度 | ビジネス価値 | 優先度 |
| ---------------- | ---------- | ------------ | ------ |
| Google/LINE認証  | 中         | 高           | A      |
| PWA化            | 低         | 高           | A      |
| 参加者別料金     | 低         | 中           | B      |
| LINE通知         | 中         | 高           | A      |
| エクスポート機能 | 低         | 中           | B      |
| API公開          | 高         | 中           | C      |
| 決済連携         | 高         | 高           | B      |
| 二要素認証       | 中         | 低           | C      |

---

## 🚦 実装時の注意点

### 1. 技術的負債の管理
- リファクタリング期間の確保
- テストカバレッジ80%以上維持
- ドキュメント整備

### 2. ユーザビリティ維持
- 機能追加による複雑化を避ける
- 既存ユーザーへの影響を最小化
- A/Bテストによる検証

### 3. スケーラビリティ
- 10万ユーザーを想定した設計
- マイクロサービス化の準備
- データベース分割の検討

---

*このロードマップは市場の反応と技術トレンドに応じて柔軟に更新されます。*
*作成日: 2025年1月*