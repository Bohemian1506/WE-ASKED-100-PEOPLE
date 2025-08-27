● DB作成のエラーと解決方法まとめ

  Sprockets Manifest Error

  症状:
  bin/rails aborted!
  Sprockets::Railtie::ManifestNeededError: Expected to find a manifest file in
  `app/assets/config/manifest.js` (Sprockets::Railtie::ManifestNeededError)
  But did not, please create this file and use it to link any assets that need to be
  rendered by your app:

  Example:
    //= link_tree ../images
    //= link_directory ../javascripts .js
    //= link_directory ../stylesheets .css

  原因:

  1. Asset Pipeline の競合
    - Rails 8はデフォルトでPropshaftを使用
    - GemfileでBootstrap用にsassc-railsを追加
    - sassc-railsの依存関係でsprockets-railsが自動インストール
    - PropshaftとSprocketsが共存し、Sprocketsが優先された
  2. manifest.jsファイル不存在
    - Sprocketsは起動時にapp/assets/config/manifest.jsを要求
    - Rails newで生成されたPropshaft環境にはmanifest.jsが不要
    - そのためファイルが存在せずエラー
  3. 依存関係の連鎖
  bootstrap gem → sassc-rails → sprockets-rails → manifest.js が必要

  解決方法:

  1. Gemfile修正 (実施済み)

  gem "sassc-rails", require: false  # 自動ロードを無効化

  2. manifest.jsファイル作成 (実施済み)

  # ディレクトリとファイルを作成
  mkdir -p app/assets/config
  echo '//= link_tree ../images' > app/assets/config/manifest.js
  echo '//= link_directory ../stylesheets .css' >> app/assets/config/manifest.js

  学んだポイント:

  1. Rails 8のAsset Pipeline変更
    - Sprockets → Propshaft への移行期間
    - 既存gemの依存関係による競合が発生しやすい
  2. 依存関係の影響
    - 直接指定していないgemでも依存関係でインストールされる
    - require: falseは自動ロードを防ぐが、gem自体は利用可能
  3. エラー対処の優先順位
    - 既存の環境を壊さない方法を選択
    - manifest.jsの作成でSprocketsとの共存を実現

  代替案:

  # より根本的な解決（Sprockets完全回避）
  gem "dartsass-rails", "~> 0.5.0"  # sassc-railsの代替
  # gem "sassc-rails"  # コメントアウト

  今回の解決方法（manifest.js作成）は、既存のGemfile構成を保ちつつエラーを解消する実用
  的なアプローチでした。