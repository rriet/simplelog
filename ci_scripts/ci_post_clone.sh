#!/bin/sh

set -eu

echo "==> Xcode Cloud post-clone: start"

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

if command -v flutter >/dev/null 2>&1; then
  FLUTTER_BIN="flutter"
elif [ -n "${FLUTTER_ROOT:-}" ] && [ -x "${FLUTTER_ROOT}/bin/flutter" ]; then
  FLUTTER_BIN="${FLUTTER_ROOT}/bin/flutter"
else
  echo "error: flutter not found in PATH and FLUTTER_ROOT is not set" >&2
  exit 1
fi

echo "==> Running flutter pub get"
"$FLUTTER_BIN" pub get

echo "==> Running pod install --repo-update (ios)"
cd ios
pod install --repo-update

echo "==> Xcode Cloud post-clone: done"
