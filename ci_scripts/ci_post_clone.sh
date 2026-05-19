#!/bin/sh

set -eux

echo "==> Xcode Cloud post-clone: start"

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

if command -v flutter >/dev/null 2>&1; then
  FLUTTER_BIN="flutter"
elif [ -n "${FLUTTER_ROOT:-}" ] && [ -x "${FLUTTER_ROOT}/bin/flutter" ]; then
  FLUTTER_BIN="${FLUTTER_ROOT}/bin/flutter"
else
  echo "error: flutter not found"
  exit 1
fi

echo "==> Flutter version"
"$FLUTTER_BIN" --version

echo "==> Cleaning Flutter"
"$FLUTTER_BIN" clean

echo "==> Getting packages"
"$FLUTTER_BIN" pub get

echo "==> Precache iOS artifacts"
"$FLUTTER_BIN" precache --ios

echo "==> Building iOS plugin symlinks"
"$FLUTTER_BIN" build ios --config-only

cd ios

echo "==> Removing old pods"
rm -rf Pods Podfile.lock

echo "==> Installing pods"
pod repo update
pod install --repo-update

echo "==> Done"#!/bin/sh

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
