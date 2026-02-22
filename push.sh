#!/bin/bash

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$REPO_DIR"

if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    echo "Not a git repo. Initializing..."
    git init
    git remote add origin https://github.com/devjpt23/cuda.git
fi

if [ -z "$(git config user.name)" ]; then
    read -p "Git username: " name
    git config user.name "$name"
fi
if [ -z "$(git config user.email)" ]; then
    read -p "Git email: " email
    git config user.email "$email"
fi

git add -A
echo ""
git status

read -p "Commit message (leave empty for auto): " msg
if [ -z "$msg" ]; then
    msg="update $(date '+%Y-%m-%d %H:%M:%S')"
fi

git commit -m "$msg"

BRANCH=$(git branch --show-current)
git push origin "$BRANCH"
