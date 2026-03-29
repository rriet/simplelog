#!/bin/sh

set -eu

echo "==> Xcode Cloud post-clone: start"
echo "==> PWD: $(pwd)"

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"
echo "==> Repo root: $REPO_ROOT"

if command -v flutter >/dev/null 2>&1; then
  FLUTTER_BIN="flutter"
elif [ -n "${FLUTTER_ROOT:-}" ] && [ -x "${FLUTTER_ROOT}/bin/flutter" ]; then
  FLUTTER_BIN="${FLUTTER_ROOT}/bin/flutter"
else
  echo "error: flutter not found in PATH and FLUTTER_ROOT is not set" >&2
  exit 1
fi

echo "==> Flutter: $("$FLUTTER_BIN" --version | head -n 1)"
echo "==> Running flutter pub get"
"$FLUTTER_BIN" pub get

echo "==> Running pod install --repo-update (ios)"
cd ios
pod --version
pod install --repo-update

echo "==> Xcode Cloud post-clone: done"
