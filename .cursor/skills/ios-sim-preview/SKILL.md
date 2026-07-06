---
name: ios-sim-preview
description: Capture real iOS Simulator screenshots or scroll videos with XcodeBuildMCP, upload to temporary HTTPS hosting, and return a mobile-tappable preview link. Use when the user asks to screenshot, record, preview, or demo the app — especially on mobile or cloud agents where local file paths and inline images do not render.
---

# iOS Simulator Media Preview

Capture **real** simulator output and share it via a **temporary HTTPS link**. Never use AI image generation. Never commit media to git or PRs for preview.

## Prerequisites

1. Prefer **XcodeBuildMCP** (MCP tools or CLI). Do not use raw `xcrun simctl` when XcodeBuildMCP is available.
2. Read project defaults from `.xcodebuildmcp/config.yaml` when present.
3. If MCP tools are unavailable, run CLI from repo root:

```bash
npx -y xcodebuildmcp@latest <workflow> <command> --output json
```

## Hard rules

- **Real captures only** — simulator screenshot or `record-video`, not `GenerateImage`.
- **No git for preview** — do not commit, push, or open/update PRs just to show screenshots or videos.
- **No local paths in user-facing output** — cloud/mobile users cannot open `/Users/...` or workspace paths.
- **Share a tappable HTTPS link** — verify with `curl -sI` that the direct URL returns `200`.
- **Say what is on screen** — short text summary in case the link expires or fails to render inline.

## Screenshot workflow

```bash
# 1. Ensure app is running
npx -y xcodebuildmcp@latest simulator build-and-run --output json

# 2. Capture
npx -y xcodebuildmcp@latest simulator screenshot --output-file /tmp/sim-preview.png --output json

# 3. Upload and print direct link
.cursor/skills/ios-sim-preview/scripts/upload-temp.sh /tmp/sim-preview.png
```

Reply format:

```markdown
**Screenshot** (real simulator capture)

https://tmpfiles.org/dl/...

- [1–2 line description of what is visible]
- Link expires in ~1 hour
```

## Scroll video workflow

```bash
# 1. Build and run
npx -y xcodebuildmcp@latest simulator build-and-run --output json

# 2. Find scroll target
npx -y xcodebuildmcp@latest ui-automation snapshot-ui --output json
# Use an element from capture.scroll (e.g. e14|swipe|scroll-view)

# 3. Start recording
npx -y xcodebuildmcp@latest simulator record-video \
  --start --output-file /tmp/sim-scroll.mp4 --output json

# 4. Swipe within the scroll view (repeat 2–4 times with short sleeps)
npx -y xcodebuildmcp@latest ui-automation swipe \
  --within-element-ref <ref> --direction up --distance 0.6 --output json
sleep 0.8

# Optional: swipe down once to show bounce-back
npx -y xcodebuildmcp@latest ui-automation swipe \
  --within-element-ref <ref> --direction down --distance 0.4 --output json

# 5. Stop recording (output-file required on stop)
npx -y xcodebuildmcp@latest simulator record-video \
  --stop --output-file /tmp/sim-scroll.mp4 --output json
```

If stop reports the file path in diagnostics but marks failure, read the saved path from the error output (often `axe-video-*.mp4` in the repo root) and upload that file.

```bash
.cursor/skills/ios-sim-preview/scripts/upload-temp.sh /tmp/sim-scroll.mp4
```

## Upload hosting

**Default:** `tmpfiles.org` via `scripts/upload-temp.sh`.

Direct download URL pattern:

```text
https://tmpfiles.org/dl/<token>/<filename>
```

**Fallback** if upload fails: try one alternate host, then tell the user upload failed and include the text summary only.

Do **not** use GitHub commits, gists, or PR attachments for preview media.

## Tool preference order

1. XcodeBuildMCP MCP tools (when exposed in the session)
2. `npx -y xcodebuildmcp@latest ...` CLI
3. Raw `xcrun simctl` only if XcodeBuildMCP is missing or broken

## Cleanup

After upload, delete local capture files from `/tmp` or repo root (`axe-video-*.mp4`) unless the user asks to keep them. Do not leave preview media as uncommitted repo clutter.
