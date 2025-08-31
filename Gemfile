source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.0.2", ">= 8.0.2.1"
# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "propshaft"
# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"
# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"
# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"
# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"
# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem "kamal", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false

  gem "rspec-rails"        # テストフレームワーク
  gem "factory_bot_rails"  # テストデータ作成
  gem "faker"              # ダミーデータ生成
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"        # ブラウザ上でのデバッグコンソール
  gem "letter_opener"      # 開発環境でのメール確認
  gem "annotate"           # モデルへのスキーマ情報追記
  gem "bullet"             # N+1問題の検出
  gem "better_errors"      # エラー画面の改善
  gem "binding_of_caller"  # better_errorsの拡張
  gem "lookbook"           # ViewComponentカタログ
  gem "listen", "~> 3.3"
  gem "spring"
  gem "pry-rails"          # pry-railsが不足（任意）
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"            # 統合テスト
  gem "selenium-webdriver"  # ブラウザ自動操作
  gem "database_cleaner-active_record" # RSpecでのDB管理用
end

# 認証・セキュリティ
gem "bcrypt", "~> 3.1.7"  # has_secure_password用

# フロントエンド・UI
gem "bootstrap", "~> 5.3.0"    # CSSフレームワーク
gem "jquery-rails"             # Bootstrap用
gem "bootstrap-icons-helper"   # アイコン
gem "view_component", "~> 3.0" # UIコンポーネント
gem "kaminari"                 # ページネーション
gem "sassc-rails", require: false    # Bootstrap SCSS用

# 日本語化・国際化
gem "rails-i18n"         # Rails標準機能の日本語化
gem "enum_help"          # Enumの日本語化サポート

# データ管理・機能拡張
gem "discard"            # ソフトデリート機能
gem "rqrcode"            # QRコード生成（共有URL用）

# メール送信
gem "sendgrid-ruby", "~> 6.7"  # SendGridクライアント
