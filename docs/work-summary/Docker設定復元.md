 Docker環境の復元と設定調整プラン

  1. Docker関連ファイルの復元

  docker-compose.ymlの復元

  # バックアップから復元
  cp docker-compose.yml.backup docker-compose.yml

  現在のdocker-compose.yml（復元後）:
  - webコンテナ: Rails開発サーバー
  - dbコンテナ: PostgreSQL 15
  - ボリューム: bundle_cacheとpostgres_data

  Dockerfileの復元

  # バックアップから復元
  cp Dockerfile.backup Dockerfile

  注意: 新しいDockerfile（Rails生成）は本番用のマルチステージビルドなので、開発用の既存Dockerfileを使用

  ---
  2. database.ymlの修正

  Docker環境用に設定を変更:
  default: &default
    adapter: postgresql
    encoding: unicode
    host: db  # Docker内のホスト名
    username: postgres
    password: password
    pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>

  development:
    <<: *default
    database: we_asked_100_people_development

  test:
    <<: *default
    database: we_asked_100_people_test

  production:
    <<: *default
    database: we_asked_100_people_production
    username: we_asked_100_people
    password: <%= ENV["WE_ASKED_100_PEOPLE_DATABASE_PASSWORD"] %>

  ---
  3. Gemfileの調整

  CLAUDE.md仕様に合わせて追加:

  # 既存のGemfileに追加
  gem 'rails', '~> 8.0.0'  # バージョン固定
  gem 'pg', '~> 1.1'       # すでにある

  # UI関連
  gem 'bootstrap', '~> 5.3'
  gem 'sassc-rails'  # Bootstrap用
  gem 'jquery-rails' # 必要に応じて

  # 日本語化
  gem 'rails-i18n', '~> 8.0'

  # 開発・テスト環境
  group :development, :test do
    gem 'rspec-rails', '~> 6.0'
    gem 'factory_bot_rails'
    gem 'faker'
    gem 'pry-rails'
    gem 'rubocop', require: false
    gem 'rubocop-rails', require: false
  end

  group :test do
    gem 'capybara'
    gem 'selenium-webdriver'
    gem 'database_cleaner-active_record'
  end

  ---
  4. Docker環境の起動手順

  # 1. Dockerイメージの再ビルド
  docker-compose build

  # 2. コンテナ起動
  docker-compose up -d

  # 3. 依存関係インストール
  docker-compose exec web bundle install

  # 4. データベース作成
  docker-compose exec web rails db:create

  # 5. マイグレーション実行
  docker-compose exec web rails db:migrate

  # 6. 動作確認
  docker-compose exec web rails --version
  docker-compose exec web rails routes

  # 7. サーバー起動確認
  docker-compose logs -f web

  ---
  5. 環境変数の設定

  .env.localファイル作成:
  DATABASE_URL=postgresql://postgres:password@db:5432/we_asked_100_people_development
  RAILS_ENV=development
  SECRET_KEY_BASE=<rails secret で生成>

  ---
  6. RSpec環境の復元

  # 1. spec.backupを復元
  rm -rf spec  # 空のspecディレクトリを削除
  mv spec.backup spec

  # 2. RSpec初期化（必要に応じて）
  docker-compose exec web rails generate rspec:install

  ---
  7. クリーンアップ

  # バックアップファイル削除
  rm -f *.backup
  rm -rf docs.backup

  # 不要なファイル削除
  rm -rf test  # RSpec使用のため

  # gitignoreの確認
  cat .gitignore  # 必要な除外設定があるか確認

  ---
  8. 動作確認チェックリスト

  - docker-compose ps でコンテナが起動
  - docker-compose exec web rails console でコンソール起動
  - docker-compose exec web rails db:migrate:status でDB接続確認
  - http://localhost:3000 でRailsウェルカムページ表示
  - docker-compose exec web bundle exec rspec でテスト実行可能

  ---
  実行順序の推奨

  1. Docker設定復元 → docker-compose.yml, Dockerfile
  2. database.yml修正 → Docker用の設定
  3. Dockerビルド・起動 → イメージビルド、コンテナ起動
  4. Gemfile調整・bundle install → 必要なgemを追加
  5. DB作成・マイグレーション → データベース初期化
  6. RSpec復元 → テスト環境整備
  7. クリーンアップ → 不要ファイル削除
  8. 動作確認 → 全体の動作チェック

  この手順で、Rails 8アプリケーションとDocker開発環境の統合が完了します。