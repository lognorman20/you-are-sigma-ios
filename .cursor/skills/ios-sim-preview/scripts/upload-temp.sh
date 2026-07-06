#!/usr/bin/env bash
set -euo pipefail

FILE="${1:?usage: upload-temp.sh <file>}"
BASENAME="$(basename "$FILE")"

if [[ ! -f "$FILE" ]]; then
  echo "error: file not found: $FILE" >&2
  exit 1
fi

RESPONSE="$(curl -sS -F "file=@${FILE}" https://tmpfiles.org/api/v1/upload)"
PAGE_URL="$(printf '%s' "$RESPONSE" | sed -n 's/.*"url":"\([^"]*\)".*/\1/p')"

if [[ -z "$PAGE_URL" ]]; then
  echo "error: upload failed: $RESPONSE" >&2
  exit 1
fi

# Page URL:  https://tmpfiles.org/<token>/<name>
# Direct URL: https://tmpfiles.org/dl/<token>/<name>
TOKEN_AND_NAME="${PAGE_URL#https://tmpfiles.org/}"
DIRECT_URL="https://tmpfiles.org/dl/${TOKEN_AND_NAME}"

STATUS="$(curl -sS -o /dev/null -w '%{http_code}' -I "$DIRECT_URL")"
if [[ "$STATUS" != "200" ]]; then
  echo "error: direct URL not reachable (HTTP $STATUS): $DIRECT_URL" >&2
  exit 1
fi

echo "$DIRECT_URL"
