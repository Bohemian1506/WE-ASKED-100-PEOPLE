# WE ASKED 100 PEOPLE - 技術仕様書

## 1. 技術スタック

### 1.1 バックエンド
- **言語**: Ruby 3.3.6
- **フレームワーク**: Ruby on Rails 8.0.0
- **データベース**: PostgreSQL 15
- **Webサーバー**: Puma
- **バックグラウンドジョブ**: Solid Queue（Rails 8標準）
- **キャッシュ**: Solid Cache（Rails 8標準）

### 1.2 フロントエンド
- **CSSフレームワーク**: Bootstrap 5.3
- **JavaScript**: Stimulus（Rails標準）
- **アイコン**: Bootstrap Icons
- **jQuery**: jquery-rails（Bootstrap依存）

### 1.3 開発環境
- **コンテナ**: Docker + Docker Compose
- **バージョン管理**: Git
- **コード管理**: GitHub
- **CI/CD**: GitHub Actions

### 1.4 主要Gem

```ruby
# Gemfile
source "https://rubygems.org"

ruby "3.3.6"

# Core
gem "rails", "~> 8.0.0"
gem "pg", "~> 1.5"
gem "puma", ">= 6.0"
gem "solid_queue"
gem "solid_cache"

# Frontend
gem "bootstrap", "~> 5.3"
gem "jquery-rails"
gem "bootstrap-icons-helper"
gem "stimulus-rails"
gem "turbo-rails"
gem "importmap-rails"

# Localization
gem "rails-i18n"
gem "enum_help"

# Development & Test
group :development, :test do
  gem "rspec-rails"
  gem "factory_bot_rails"
  gem "faker"
  gem "pry-rails"
  gem "bullet"
end

group :development do
  gem "web-console"
  gem "listen"
  gem "spring"
  gem "rubocop-rails"
end
```

## 2. 認証システム実装

### 2.1 質問作成者認証（Rails 8標準）

```ruby
# app/models/user.rb
class User < ApplicationRecord
  has_secure_password
  
  has_many :questions, dependent: :destroy
  
  validates :email, presence: true, 
                   uniqueness: { case_sensitive: false },
                   format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 8 }, if: :password_required?
  
  before_save :downcase_email
  
  private
  
  def downcase_email
    self.email = email.downcase
  end
  
  def password_required?
    password_digest.nil? || password.present?
  end
end
```

```ruby
# app/controllers/sessions_controller.rb
class SessionsController < ApplicationController
  def new
  end
  
  def create
    user = User.find_by(email: params[:email]&.downcase)
    
    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to dashboard_path, notice: "ログインしました"
    else
      flash.now[:alert] = "メールアドレスまたはパスワードが正しくありません"
      render :new, status: :unprocessable_entity
    end
  end
  
  def destroy
    session[:user_id] = nil
    redirect_to root_path, notice: "ログアウトしました"
  end
end
```

### 2.2 回答者識別システム（Cookie/UUID）

```ruby
# app/controllers/concerns/respondent_tracking.rb
module RespondentTracking
  extend ActiveSupport::Concern
  
  included do
    before_action :ensure_respondent_uuid
  end
  
  private
  
  def ensure_respondent_uuid
    unless cookies.signed[:respondent_uuid].present?
      cookies.permanent.signed[:respondent_uuid] = SecureRandom.uuid
    end
  end
  
  def current_respondent_uuid
    cookies.signed[:respondent_uuid]
  end
  
  def already_answered?(question)
    question.answers.exists?(respondent_uuid: current_respondent_uuid)
  end
end
```

```ruby
# app/controllers/answers_controller.rb
class AnswersController < ApplicationController
  include RespondentTracking
  
  def create
    @question = Question.find_by!(short_id: params[:short_id])
    
    if already_answered?(@question)
      redirect_to question_path(@question), 
                  alert: "この質問には既に回答済みです"
      return
    end
    
    @answer = @question.answers.build(answer_params)
    @answer.respondent_uuid = current_respondent_uuid
    
    if @answer.save
      redirect_to complete_question_path(@question)
    else
      render :new, status: :unprocessable_entity
    end
  end
end
```

## 3. 短縮ID生成システム

```ruby
# app/models/concerns/short_id_generator.rb
module ShortIdGenerator
  extend ActiveSupport::Concern
  
  ALPHABET = "0123456789abcdefghijklmnopqrstuvwxyz"
  ID_LENGTH = 8
  
  included do
    before_create :generate_short_id
  end
  
  private
  
  def generate_short_id
    loop do
      self.short_id = generate_random_id
      break unless self.class.exists?(short_id: short_id)
    end
  end
  
  def generate_random_id
    Array.new(ID_LENGTH) { ALPHABET.chars.sample }.join
  end
end

# app/models/question.rb
class Question < ApplicationRecord
  include ShortIdGenerator
  
  validates :short_id, uniqueness: true, presence: true
end
```

## 4. 回答正規化とグルーピング

### 4.1 正規化処理

```ruby
# app/services/answer_normalizer.rb
class AnswerNormalizer
  def self.normalize(text)
    return "" if text.blank?
    
    text.strip                        # 前後の空白削除
        .downcase                      # 小文字統一
        .tr('０-９ａ-ｚＡ-Ｚ', '0-9a-za-z')  # 全角→半角
        .gsub(/[[:space:]]+/, '')      # 空白削除
        .gsub(/[・、。！？「」『』（）｛｝【】]/, '') # 記号削除
  end
  
  # 将来的な拡張用
  def self.normalize_advanced(text)
    # ひらがな/カタカナ統一など
    # gem 'mojinizer' 使用時
  end
end
```

### 4.2 自動グルーピング

```ruby
# app/services/answer_grouping_service.rb
class AnswerGroupingService
  def initialize(question)
    @question = question
  end
  
  def perform
    ActiveRecord::Base.transaction do
      # 既存のグループをクリア
      @question.answer_groups.destroy_all
      
      # 正規化された回答でグループ化
      grouped_answers = @question.answers
                                 .group(:normalized_content)
                                 .count
      
      # グループ作成とランキング計算
      create_groups(grouped_answers)
      assign_answers_to_groups
      calculate_rankings
    end
  end
  
  private
  
  def create_groups(grouped_answers)
    grouped_answers.each do |normalized_content, count|
      representative = @question.answers
                               .where(normalized_content: normalized_content)
                               .first
      
      @question.answer_groups.create!(
        representative_answer: representative.content,
        normalized_answer: normalized_content,
        answers_count: count
      )
    end
  end
  
  def assign_answers_to_groups
    @question.answers.find_each do |answer|
      group = @question.answer_groups
                       .find_by(normalized_answer: answer.normalized_content)
      answer.update!(answer_group: group)
    end
  end
  
  def calculate_rankings
    @question.answer_groups
             .order(answers_count: :desc)
             .each_with_index do |group, index|
      group.update!(rank: index + 1)
    end
  end
end
```

### 4.3 手動グルーピング

```ruby
# app/services/manual_grouping_service.rb
class ManualGroupingService
  def initialize(answer_group)
    @answer_group = answer_group
  end
  
  def merge_with(other_group)
    ActiveRecord::Base.transaction do
      # 回答を移動
      other_group.answers.update_all(answer_group_id: @answer_group.id)
      
      # カウント更新
      @answer_group.update!(
        answers_count: @answer_group.answers.count
      )
      
      # 元のグループを削除
      other_group.destroy!
      
      # ランキング再計算
      recalculate_rankings
    end
  end
  
  private
  
  def recalculate_rankings
    AnswerGroupingService.new(@answer_group.question).calculate_rankings
  end
end
```

## 5. SNS連携実装

### 5.1 Xシェアボタン実装

```erb
<!-- app/views/shared/_x_share_button.html.erb -->
<%
  share_text = text
  share_url = url
  encoded_text = ERB::Util.url_encode(share_text)
  encoded_url = ERB::Util.url_encode(share_url)
  share_link = "https://twitter.com/intent/tweet?text=#{encoded_text}&url=#{encoded_url}"
%>

<%= link_to share_link, 
            target: "_blank", 
            rel: "noopener noreferrer",
            class: "btn btn-primary" do %>
  <%= bootstrap_icon "twitter-x" %>
  Xでシェア
<% end %>
```

### 5.2 URLコピー機能

```javascript
// app/javascript/controllers/clipboard_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["source", "button"]
  
  copy() {
    const text = this.sourceTarget.value || this.sourceTarget.textContent
    
    navigator.clipboard.writeText(text).then(() => {
      this.showSuccess()
    }).catch(() => {
      this.fallbackCopy(text)
    })
  }
  
  fallbackCopy(text) {
    const textarea = document.createElement("textarea")
    textarea.value = text
    document.body.appendChild(textarea)
    textarea.select()
    document.execCommand("copy")
    document.body.removeChild(textarea)
    this.showSuccess()
  }
  
  showSuccess() {
    const originalText = this.buttonTarget.innerHTML
    this.buttonTarget.innerHTML = "コピーしました！"
    this.buttonTarget.classList.add("btn-success")
    
    setTimeout(() => {
      this.buttonTarget.innerHTML = originalText
      this.buttonTarget.classList.remove("btn-success")
    }, 2000)
  }
}
```

## 6. 期限管理システム

### 6.1 自動締切処理

```ruby
# app/models/question.rb
class Question < ApplicationRecord
  enum :status, { active: 0, closed: 1 }
  
  scope :expired, -> { active.where("deadline < ?", Time.current) }
  
  def expired?
    active? && deadline < Time.current
  end
  
  def close_if_expired!
    closed! if expired?
  end
end

# app/jobs/close_expired_questions_job.rb
class CloseExpiredQuestionsJob < ApplicationJob
  queue_as :default
  
  def perform
    Question.expired.find_each do |question|
      question.closed!
      Rails.logger.info "Closed expired question: #{question.id}"
    end
  end
end

# config/solid_queue.yml
default: &default
  dispatchers:
    - polling_interval: 1
      batch_size: 500
  workers:
    - queues: "*"
      threads: 3
      polling_interval: 0.1

recurring_tasks:
  close_expired_questions:
    class: CloseExpiredQuestionsJob
    schedule: "every 1 hour"
```

## 7. パフォーマンス最適化

### 7.1 N+1問題対策

```ruby
# app/controllers/dashboard_controller.rb
class DashboardController < ApplicationController
  def index
    @questions = current_user.questions
                            .includes(:answers, :answer_groups)
                            .order(created_at: :desc)
                            .page(params[:page])
  end
end
```

### 7.2 カウンターキャッシュ

```ruby
# app/models/answer.rb
class Answer < ApplicationRecord
  belongs_to :question, counter_cache: true
  belongs_to :answer_group, optional: true, counter_cache: true
end
```

### 7.3 インデックス最適化

```ruby
# db/migrate/add_indexes_for_performance.rb
class AddIndexesForPerformance < ActiveRecord::Migration[7.1]
  def change
    add_index :questions, [:user_id, :status, :created_at]
    add_index :answers, [:question_id, :normalized_content]
    add_index :answer_groups, [:question_id, :rank]
  end
end
```

## 8. セキュリティ実装

### 8.1 CSRF対策

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
end
```

### 8.2 Strong Parameters

```ruby
# app/controllers/questions_controller.rb
class QuestionsController < ApplicationController
  private
  
  def question_params
    params.require(:question).permit(:title, :deadline)
  end
end
```

### 8.3 認可処理

```ruby
# app/controllers/concerns/authorization.rb
module Authorization
  extend ActiveSupport::Concern
  
  included do
    before_action :authorize_resource!, only: [:edit, :update, :destroy]
  end
  
  private
  
  def authorize_resource!
    unless can_access_resource?
      redirect_to root_path, alert: "権限がありません"
    end
  end
  
  def can_access_resource?
    resource.user_id == current_user&.id
  end
end
```

## 9. 国際化（i18n）設定

### 9.1 基本設定

```ruby
# config/application.rb
module WeAsked100People
  class Application < Rails::Application
    config.i18n.default_locale = :ja
    config.i18n.available_locales = [:ja, :en]
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.yml')]
  end
end
```

### 9.2 日本語化ファイル

```yaml
# config/locales/ja.yml
ja:
  activerecord:
    models:
      user: ユーザー
      question: 質問
      answer: 回答
    attributes:
      user:
        email: メールアドレス
        password: パスワード
        name: 名前
      question:
        title: タイトル
        deadline: 締切日時
        status: ステータス
      answer:
        content: 回答内容
  
  questions:
    status:
      active: 受付中
      closed: 締切
  
  helpers:
    submit:
      create: 作成する
      update: 更新する
      submit: 送信する
```

## 10. エラーハンドリング

### 10.1 カスタムエラーページ

```ruby
# app/controllers/errors_controller.rb
class ErrorsController < ApplicationController
  def not_found
    render status: 404
  end
  
  def internal_server_error
    render status: 500
  end
end

# config/routes.rb
Rails.application.routes.draw do
  match '/404', to: 'errors#not_found', via: :all
  match '/500', to: 'errors#internal_server_error', via: :all
end
```

### 10.2 例外処理

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActionController::ParameterMissing, with: :bad_request
  
  private
  
  def not_found
    redirect_to root_path, alert: "お探しのページが見つかりません"
  end
  
  def bad_request
    redirect_to root_path, alert: "不正なリクエストです"
  end
end
```

## 11. テスト戦略

### 11.1 モデルテスト

```ruby
# spec/models/user_spec.rb
RSpec.describe User, type: :model do
  describe "validations" do
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should have_secure_password }
  end
  
  describe "associations" do
    it { should have_many(:questions).dependent(:destroy) }
  end
end
```

### 11.2 リクエストテスト

```ruby
# spec/requests/questions_spec.rb
RSpec.describe "Questions", type: :request do
  describe "POST /questions" do
    context "with valid parameters" do
      it "creates a new question" do
        expect {
          post questions_path, params: { question: valid_attributes }
        }.to change(Question, :count).by(1)
      end
    end
  end
end
```

## 12. デプロイ設定

### 12.1 Docker設定

```dockerfile
# Dockerfile
FROM ruby:3.3.6

RUN apt-get update -qq && apt-get install -y \
  nodejs \
  postgresql-client \
  imagemagick \
  vim

WORKDIR /app

COPY Gemfile* ./
RUN bundle install

COPY . .

EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]
```

### 12.2 Docker Compose設定

```yaml
# docker-compose.yml
version: '3.8'

services:
  db:
    image: postgres:15
    environment:
      POSTGRES_PASSWORD: password
    volumes:
      - postgres_data:/var/lib/postgresql/data

  web:
    build: .
    command: bash -c "rm -f tmp/pids/server.pid && bundle exec rails server -b '0.0.0.0'"
    volumes:
      - .:/app
    ports:
      - "3000:3000"
    depends_on:
      - db
    environment:
      DATABASE_URL: postgresql://postgres:password@db:5432/we_asked_100_people_development

volumes:
  postgres_data:
```