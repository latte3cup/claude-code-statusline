# claude-code-statusline (custom)

**Know your Claude Code rate limits in real time.** No more guessing when your session or weekly quota resets — see your actual usage data live in the status bar.

This is a **minimal, text-only** fork — no emoji traffic lights, no progress bars, no dollar costs. Just the numbers you need.

```
Opus 4.7 (Mid) │ main★ │ /my-project │ 5% context │ 53% session ↻ 18h │ 4% weekly ↻ 06-16(화) 03h
```

> Based on [ohugonnot/claude-code-statusline](https://github.com/ohugonnot/claude-code-statusline). See `main` branch for the original version with full visual indicators.

## What's different from the original?

| Removed | Why |
|---------|-----|
| Color-coded progress bars (`🟢▓▓▓░░░`) | Cleaner without visual clutter |
| Session cost (`$0.42`) | Not useful for Max plan users |
| Duration timer (`⏱ 1h4m`) | Not essential |
| Sonnet weekly quota | Only tracking combined weekly |

| Kept | Example |
|------|---------|
| Model + effort level | `Opus 4.7 (Mid)` — effort: `Low` / `Mid` / `High` / `X.High` / `Max` |
| Git branch + dirty | `main★` |
| Working directory name | `/my-project` |
| Context window % | `5% context` |
| Session quota + reset time (hour) | `53% session ↻ 18h` |
| Weekly quota + reset date/time | `4% weekly ↻ 06-16(화) 03h` |

## Install

### Windows (Git Bash)

```bash
curl -fsSL https://raw.githubusercontent.com/latte3cup/claude-code-statusline/custom/install-windows.sh | bash
```

jq가 없으면 자동으로 `winget install jqlang.jq`를 실행합니다.

### Linux / macOS

```bash
curl -fsSL https://raw.githubusercontent.com/latte3cup/claude-code-statusline/custom/install.sh | bash
```

### Manual

```bash
mkdir -p ~/.claude/hooks
curl -fsSL https://raw.githubusercontent.com/latte3cup/claude-code-statusline/custom/statusline.sh \
  -o ~/.claude/hooks/statusline.sh
```

Add to `~/.claude/settings.json`:

```json
{
  "statusLine": {
    "type": "command",
    "command": "bash ~/.claude/hooks/statusline.sh"
  }
}
```

## How it works

```
Claude Code → JSON stdin → statusline.sh → formatted status string
                              ↓ (if cache > 300s old)
                         curl → Anthropic OAuth API → ~/.claude/usage-exact.json
```

Every 5 minutes (configurable), the script calls the Anthropic usage API with your OAuth token. The call takes ~200ms and runs inline — no background processes, no tmux, no scraping.

The OAuth token is read from `~/.claude/.credentials.json`, which Claude Code maintains automatically. If the token is expired or the API is unreachable, the script silently falls back to cached data.

### About the Usage API

The script uses `https://api.anthropic.com/api/oauth/usage`, an **undocumented** Anthropic endpoint. It returns session (5h) and weekly (7d) quota utilization as percentages with ISO 8601 reset timestamps.

This is not an official API — it could change without notice. Feature request for official access: [anthropics/claude-code#13585](https://github.com/anthropics/claude-code/issues/13585).

## Configuration

Export in your shell profile or edit the top of `statusline.sh`:

| Variable | Default | Description |
|----------|---------|-------------|
| `REFRESH_INTERVAL` | `300` | Seconds between API calls — **do not set to 0** |
| `SHOW_WEEKLY` | `1` | Set to `0` to hide weekly quota |
| `TIMEZONE` | *(system default)* | Override display timezone (e.g. `America/New_York`) |
| `USAGE_FILE` | `~/.claude/usage-exact.json` | Cache file path |
| `CREDENTIALS_FILE` | `~/.claude/.credentials.json` | OAuth credentials path |

## Troubleshooting

**Usage not showing?**
Check that `~/.claude/.credentials.json` exists with a valid `claudeAiOauth.accessToken`.

**Force refresh:**
```bash
rm -f ~/.claude/usage-exact.json
```

**Test the API directly:**
```bash
TOKEN=$(jq -r '.claudeAiOauth.accessToken' ~/.claude/.credentials.json)
curl -s "https://api.anthropic.com/api/oauth/usage" \
  -H "Authorization: Bearer $TOKEN" \
  -H "anthropic-beta: oauth-2025-04-20" | jq .
```

## Uninstall

```bash
curl -fsSL https://raw.githubusercontent.com/latte3cup/claude-code-statusline/custom/uninstall.sh | bash
```

## License

MIT
