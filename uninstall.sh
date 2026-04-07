#!/bin/bash
# uninstall.sh — Claude Code Status Line 제거
set -euo pipefail

HOOKS_DIR="$HOME/.claude/hooks"
SETTINGS_FILE="$HOME/.claude/settings.json"
USAGE_FILE="$HOME/.claude/usage-exact.json"

# Windows jq PATH
export PATH="$HOME/AppData/Local/Microsoft/WinGet/Packages"/jqlang.jq_*:"$PATH" 2>/dev/null

echo "=== Claude Code Status Line Uninstaller ==="

# 1. statusline.sh 삭제
echo ""
if [ -f "$HOOKS_DIR/statusline.sh" ]; then
    rm -f "$HOOKS_DIR/statusline.sh"
    echo "  [ok] $HOOKS_DIR/statusline.sh 삭제"
else
    echo "  [skip] statusline.sh 없음"
fi

# 2. 캐시 파일 삭제
if [ -f "$USAGE_FILE" ]; then
    rm -f "$USAGE_FILE"
    echo "  [ok] $USAGE_FILE 삭제"
else
    echo "  [skip] 캐시 파일 없음"
fi

# 3. settings.json에서 statusLine 제거
if [ -f "$SETTINGS_FILE" ] && command -v jq >/dev/null 2>&1; then
    if jq -e '.statusLine' "$SETTINGS_FILE" >/dev/null 2>&1; then
        tmp="$(mktemp)"
        jq 'del(.statusLine)' "$SETTINGS_FILE" > "$tmp"
        mv "$tmp" "$SETTINGS_FILE"
        echo "  [ok] settings.json에서 statusLine 제거"
    else
        echo "  [skip] settings.json에 statusLine 없음"
    fi
else
    echo "  [skip] settings.json 또는 jq 없음"
fi

echo ""
echo "Done! Claude Code를 재시작하면 statusline이 사라집니다."
