#!/bin/sh

set -eu

echo "==> Xcode Cloud post-xcodebuild: start"
echo "==> CI_XCODEBUILD_ACTION=${CI_XCODEBUILD_ACTION:-<unset>}"
echo "==> CI_ARCHIVE_PATH=${CI_ARCHIVE_PATH:-<unset>}"

if [ "${CI_XCODEBUILD_ACTION:-}" != "archive" ]; then
  echo "==> Skipping: action is not archive"
  exit 0
fi

ARCHIVE_PATH="${CI_ARCHIVE_PATH:-}"
if [ -z "$ARCHIVE_PATH" ] || [ ! -d "$ARCHIVE_PATH" ]; then
  if [ -d "$CI_WORKSPACE" ]; then
    ARCHIVE_PATH="$(find "$CI_WORKSPACE" -type d -name "*.xcarchive" | head -n 1 || true)"
  else
    ARCHIVE_PATH="$(find . -type d -name "*.xcarchive" | head -n 1 || true)"
  fi
fi

if [ -z "$ARCHIVE_PATH" ] || [ ! -d "$ARCHIVE_PATH" ]; then
  echo "==> No .xcarchive found; nothing to patch"
  exit 0
fi

echo "==> Using archive: $ARCHIVE_PATH"

FRAMEWORK_BIN="$ARCHIVE_PATH/Products/Applications/Runner.app/Frameworks/objective_c.framework/objective_c"
DSYM_DIR="$ARCHIVE_PATH/dSYMs/objective_c.framework.dSYM"
DSYM_BIN="$DSYM_DIR/Contents/Resources/DWARF/objective_c"

if [ ! -f "$FRAMEWORK_BIN" ]; then
  echo "==> objective_c.framework not found in archive; nothing to patch"
  exit 0
fi

if [ -f "$DSYM_BIN" ]; then
  echo "==> objective_c dSYM already exists"
else
  echo "==> Generating objective_c dSYM with dsymutil"
  mkdir -p "$ARCHIVE_PATH/dSYMs"
  xcrun dsymutil "$FRAMEWORK_BIN" -o "$DSYM_DIR"
fi

echo "==> UUID check (framework)"
xcrun dwarfdump --uuid "$FRAMEWORK_BIN" || true
echo "==> UUID check (dSYM)"
xcrun dwarfdump --uuid "$DSYM_BIN" || true

if [ ! -f "$DSYM_BIN" ]; then
  echo "error: objective_c dSYM was not generated" >&2
  exit 1
fi

echo "==> Xcode Cloud post-xcodebuild: done"
