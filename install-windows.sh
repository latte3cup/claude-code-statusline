#!/bin/bash
# install-windows.sh — Claude Code Status Line installer (Windows / Git Bash)
# Usage: bash install-windows.sh
set -euo pipefail

REPO_RAW="https://raw.githubusercontent.com/latte3cup/claude-code-statusline/custom"
HOOKS_DIR="$HOME/.claude/hooks"
SETTINGS_FILE="$HOME/.claude/settings.json"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-/dev/null}")" 2>/dev/null && pwd || echo "")"

echo "=== Claude Code Status Line Installer (Windows) ==="

# 1. jq 설치 확인 + winget 설치
echo ""
echo "Checking dependencies..."

if command -v curl >/dev/null 2>&1; then
    echo "  [ok] curl"
else
    echo "  [missing] curl — Git Bash에 기본 포함되어 있어야 합니다"
    exit 1
fi

# jq: WinGet 경로 포함해서 확인
export PATH="$HOME/AppData/Local/Microsoft/WinGet/Packages"/jqlang.jq_*:"$PATH" 2>/dev/null
if command -v jq >/dev/null 2>&1; then
    echo "  [ok] jq"
else
    echo "  [missing] jq"
    if command -v winget.exe >/dev/null 2>&1; then
        echo "  Installing jq via winget..."
        winget.exe install jqlang.jq --accept-package-agreements --accept-source-agreements
        # PATH 갱신
        export PATH="$HOME/AppData/Local/Microsoft/WinGet/Packages"/jqlang.jq_*:"$PATH" 2>/dev/null
        if command -v jq >/dev/null 2>&1; then
            echo "  [ok] jq installed"
        else
            echo "  [warn] jq 설치됨. 터미널을 재시작한 후 다시 실행해주세요."
            exit 1
        fi
    else
        echo "  winget을 찾을 수 없습니다. 수동으로 jq를 설치해주세요:"
        echo "    winget install jqlang.jq"
        exit 1
    fi
fi

# 2. Install statusline.sh
echo ""
echo "Installing statusline.sh..."

mkdir -p "$HOOKS_DIR"

if [ -n "$SCRIPT_DIR" ] && [ -f "$SCRIPT_DIR/statusline.sh" ]; then
    cp "$SCRIPT_DIR/statusline.sh" "$HOOKS_DIR/statusline.sh"
else
    echo "  Downloading from GitHub..."
    curl -fsSL "$REPO_RAW/statusline.sh" -o "$HOOKS_DIR/statusline.sh"
fi

echo "  Installed: $HOOKS_DIR/statusline.sh"

# 3. Update settings.json
echo ""
echo "Configuring Claude Code..."

STATUS_LINE_CONFIG='{"type":"command","command":"bash ~/.claude/hooks/statusline.sh"}'

if [ -f "$SETTINGS_FILE" ]; then
    tmp="$(mktemp)"
    jq --argjson sl "$STATUS_LINE_CONFIG" '.statusLine = $sl' "$SETTINGS_FILE" > "$tmp"
    mv "$tmp" "$SETTINGS_FILE"
    echo "  Updated statusLine in existing settings.json"
else
    mkdir -p "$(dirname "$SETTINGS_FILE")"
    jq -n --argjson sl "$STATUS_LINE_CONFIG" '{statusLine: $sl}' > "$SETTINGS_FILE"
    echo "  Created settings.json with statusLine"
fi

# 4. Done
echo ""
echo "Done! Restart Claude Code to see the status line."
echo ""
echo "Test command:"
echo "  echo '{\"model\":\"claude-sonnet-4-6\",\"context_window\":{\"used_percentage\":42}}' | bash $HOOKS_DIR/statusline.sh"
