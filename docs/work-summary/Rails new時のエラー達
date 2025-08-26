● Rails new実行時のエラーと解決方法まとめ

  1. Docker起動時のハング問題

  症状: docker-compose runが5分以上応答しない
  docker-compose run --rm web \
    rails new . --database=postgresql --skip-git --skip-bundle --force
  # 応答なし

  原因:
  - Dockerfile内のRUN bundle installでGemfile.lockが空のため処理が止まる
  - Docker Daemonの応答問題

  解決方法:
  # 一時的な最小Gemfileを作成
  cat > Gemfile << 'EOF'
  source 'https://rubygems.org'
  gem 'rails', '~> 8.0.0'
  EOF
  touch Gemfile.lock

  ---
  2. Docker Daemon応答なし問題

  症状: docker psが応答しない
  timeout 5 docker ps
  # 何も返ってこない

  原因: Docker DesktopとWSL2の接続問題

  解決方法:
  # WSL2を完全に再起動（PowerShellで実行）
  wsl --shutdown

  # Docker Desktop再起動
  # タスクトレイから「Restart」

  ---
  3. "Invalid application name rails, constant Rails is already in 
  use"エラー

  症状: rails new実行時にRails定数の衝突
  Invalid application name rails, constant Rails is already in use.
  Please choose another application name.

  原因:
  - spec/rails_helper.rbが../config/environmentを要求
  - configディレクトリが存在しないため不完全な状態でRailsがロード
  - Dockerfileのbundle installで既にRailsがインストール済み

  解決方法:
  # 1. specディレクトリを退避
  mv spec spec.backup

  # 2. 環境変数をクリアして実行
  docker-compose run --rm -e RAILS_ENV= -e BUNDLE_GEMFILE= web \
    bash -c "rails new . --database=postgresql --skip-git --skip-bundle 
  --force"

  ---
  4. docker-compose.ymlのversionアトリビュート警告

  症状:
  WARN[0000] /path/docker-compose.yml: the attribute `version` is
  obsolete

  原因: Docker Compose v2ではversion指定が非推奨

  解決方法: docker-compose.ymlからversion: 
  '3.9'を削除（警告だけなので動作に影響なし）

  ---
  5. bashコマンドのエスケープ問題

  症状: bash -cでコマンドが実行されずbashプロンプトに入る

  原因: ダブルクォートのエスケープ漏れ

  解決方法:
  # 正しい記述
  docker-compose run --rm web \
    bash -c "rails new . --database=postgresql --skip-git --skip-bundle 
  --force"

  # または直接実行
  docker-compose run --rm web \
    rails new . --database=postgresql --skip-git --skip-bundle --force

  ---
  根本原因の整理

  問題の連鎖:

  1. 既存ファイルの削除不足 → specディレクトリが残存
  2. Dockerfileのbundle install → Railsが事前にロード
  3. 不完全なRails環境 → rails newでの定数衝突
  4. Docker Daemonの問題 → WSL2統合の不安定性

  最終的な成功パターン:

  # 1. 既存ファイル削除（specも含む）
  rm -rf app bin config db lib log public storage test tmp vendor spec

  # 2. 最小限のGemfile作成
  cat > Gemfile << 'EOF'
  source 'https://rubygems.org'
  gem 'rails', '~> 8.0.0'
  EOF
  touch Gemfile.lock

  # 3. 環境変数クリア+rails new実行
  docker-compose run --rm -e RAILS_ENV= -e BUNDLE_GEMFILE= web \
    bash -c "rails new . --database=postgresql --skip-git --skip-bundle 
  --force"

  この経験から、Rails newを既存プロジェクトで実行する際は、環境のクリーン
  さが重要であることがわかりました。