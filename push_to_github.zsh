#!/bin/zsh

# ローカルファイルをGitHubの新しいリポジトリにプッシュするスクリプト
# 使用方法: ./push_to_github.zsh [リポジトリ名] [GitHubユーザー名]

# 色付きの出力用
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# エラーハンドリング
set -e

# 関数: エラーメッセージ表示
error_exit() {
    echo -e "${RED}エラー: $1${NC}" >&2
    exit 1
}

# 関数: 成功メッセージ表示
success_msg() {
    echo -e "${GREEN}✓ $1${NC}"
}

# 関数: 情報メッセージ表示
info_msg() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# 関数: 警告メッセージ表示
warning_msg() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# 引数の確認
if [[ $# -eq 0 ]]; then
    echo "使用方法: $0 [リポジトリ名] [GitHubユーザー名(オプション)]"
    echo ""
    echo "例:"
    echo "  $0 my-project"
    echo "  $0 my-project myusername"
    echo ""
    read "repo_name?リポジトリ名を入力してください: "
    if [[ -z "$repo_name" ]]; then
        error_exit "リポジトリ名が入力されていません"
    fi
else
    repo_name=$1
fi

# GitHubユーザー名の取得
if [[ $# -ge 2 ]]; then
    github_username=$2
else
    # Gitの設定からユーザー名を取得を試行
    github_username=$(git config --global user.name 2>/dev/null || echo "")
    if [[ -z "$github_username" ]]; then
        read "github_username?GitHubユーザー名を入力してください: "
        if [[ -z "$github_username" ]]; then
            error_exit "GitHubユーザー名が入力されていません"
        fi
    else
        info_msg "Gitの設定からユーザー名を取得: $github_username"
        read "confirm?このユーザー名を使用しますか？ (y/n): "
        if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
            read "github_username?GitHubユーザー名を入力してください: "
        fi
    fi
fi

# 必要なコマンドの確認
command -v git >/dev/null 2>&1 || error_exit "gitコマンドが見つかりません"
command -v gh >/dev/null 2>&1 || {
    warning_msg "GitHub CLIが見つかりません。手動でリポジトリを作成する必要があります"
    manual_creation=true
}

info_msg "リポジトリ名: $repo_name"
info_msg "GitHubユーザー名: $github_username"
info_msg "現在のディレクトリ: $(pwd)"

# 確認
echo ""
read "proceed?続行しますか？ (y/n): "
if [[ "$proceed" != "y" && "$proceed" != "Y" ]]; then
    info_msg "処理を中止しました"
    exit 0
fi

echo ""
info_msg "処理を開始します..."

# 1. Gitリポジトリの初期化（既に存在する場合はスキップ）
if [[ ! -d ".git" ]]; then
    info_msg "Gitリポジトリを初期化しています..."
    git init
    success_msg "Gitリポジトリを初期化しました"
else
    info_msg "既存のGitリポジトリを使用します"
fi

# 2. .gitignoreファイルの作成（存在しない場合）
if [[ ! -f ".gitignore" ]]; then
    info_msg ".gitignoreファイルを作成しています..."
    cat > .gitignore << 'EOF'
# macOS
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# R
.Rhistory
.Rapp.history
.RData
.Ruserdata
.Rproj.user/
*-Ex.R
/*.tar.gz
/*.Rcheck/
.Renviron

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# Logs
*.log

# Temporary files
*.tmp
*.temp

# MPI specific
*.o
*.so
*.dylib
EOF
    success_msg ".gitignoreファイルを作成しました"
fi

# 3. ファイルをステージング
info_msg "ファイルをステージングしています..."
git add .
success_msg "ファイルをステージングしました"

# 4. 初回コミット
if ! git rev-parse --verify HEAD >/dev/null 2>&1; then
    info_msg "初回コミットを作成しています..."
    git commit -m "Initial commit: Add MPI parallel computing project

- Add MPI R programs for parallel computing examples
- Include hello world, pi calculation, data processing, and matrix multiplication examples
- Add shell scripts and SLURM scripts for HPC environments
- Add comprehensive documentation and README"
    success_msg "初回コミットを作成しました"
else
    info_msg "既存のコミットが存在します。新しい変更をコミットしています..."
    if git diff --staged --quiet; then
        warning_msg "ステージングされた変更がありません"
    else
        git commit -m "Update: $(date '+%Y-%m-%d %H:%M:%S')"
        success_msg "変更をコミットしました"
    fi
fi

# 5. GitHubリポジトリの作成
if [[ "$manual_creation" == "true" ]]; then
    warning_msg "GitHub CLIが利用できないため、手動でリポジトリを作成してください"
    echo ""
    echo "以下の手順でリポジトリを作成してください："
    echo "1. https://github.com/new にアクセス"
    echo "2. リポジトリ名: $repo_name"
    echo "3. 'Create repository'をクリック"
    echo "4. 'Initialize this repository with a README'のチェックを外す"
    echo ""
    read "created?リポジトリを作成しましたか？ (y/n): "
    if [[ "$created" != "y" && "$created" != "Y" ]]; then
        error_exit "リポジトリの作成が完了していません"
    fi
else
    info_msg "GitHubリポジトリを作成しています..."
    
    # GitHub CLIでリポジトリ作成
    if gh repo create "$repo_name" --public --source=. --remote=origin --push; then
        success_msg "GitHubリポジトリを作成し、プッシュしました"
        echo ""
        info_msg "リポジトリURL: https://github.com/$github_username/$repo_name"
        success_msg "すべての処理が完了しました！"
        exit 0
    else
        warning_msg "GitHub CLIでの自動作成に失敗しました。手動で設定を続行します..."
        manual_creation=true
    fi
fi

# 6. リモートリポジトリの追加
remote_url="https://github.com/$github_username/$repo_name.git"
info_msg "リモートリポジトリを追加しています..."

# 既存のoriginリモートがある場合は削除
if git remote get-url origin >/dev/null 2>&1; then
    git remote remove origin
fi

git remote add origin "$remote_url"
success_msg "リモートリポジトリを追加しました: $remote_url"

# 7. メインブランチの設定
info_msg "メインブランチを設定しています..."
git branch -M main
success_msg "メインブランチを設定しました"

# 8. GitHubにプッシュ
info_msg "GitHubにプッシュしています..."
if git push -u origin main; then
    success_msg "GitHubにプッシュしました"
else
    error_exit "プッシュに失敗しました。リポジトリが正しく作成されているか確認してください"
fi

echo ""
echo "🎉 すべての処理が完了しました！"
echo ""
info_msg "リポジトリURL: https://github.com/$github_username/$repo_name"
info_msg "ローカルリポジトリ: $(pwd)"
echo ""
echo "今後の変更をプッシュする場合は以下のコマンドを使用してください："
echo "  git add ."
echo "  git commit -m \"Your commit message\""
echo "  git push"