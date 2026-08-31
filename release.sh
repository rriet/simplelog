#!/bin/bash

set -e

###############################################
# Configuration
###############################################

PROJECT_DIR="/Users/ricardorietcorrea/Programming/Flutter/simplelog"
RELEASE_DIR="/Users/ricardorietcorrea/Programming/Flutter/SimpleLog-Releases"

# Apple App Store Connect
APPLE_ID="rietlabs@yahoo.com"
KEYCHAIN_SERVICE="SimpleLog-Transporter"


###############################################
# Go to project
###############################################

cd "$PROJECT_DIR"


###############################################
# Get version from pubspec.yaml
###############################################

VERSION=$(grep '^version:' pubspec.yaml | awk '{print $2}' | cut -d+ -f1)

echo
echo "======================================"
echo "Building SimpleLog version $VERSION"
echo "======================================"
echo


###############################################
# Flutter builds
###############################################

flutter pub get

echo "Building Android..."
flutter build apk --release

echo
echo "Building macOS..."
flutter build macos --release

echo
echo "Building iOS..."
flutter build ipa --release


###############################################
# Paths
###############################################

MAC_BUILD_DIR="$PROJECT_DIR/build/macos/Build/Products/Release"

APK_SRC="$PROJECT_DIR/build/app/outputs/flutter-apk/app-release.apk"
APK_NAME="SimpleLog-Android-${VERSION}.apk"

IPA_DIR="$PROJECT_DIR/build/ios/ipa"
IPA_SRC=$(find "$IPA_DIR" -maxdepth 1 -name "*.ipa" | head -1)
IPA_NAME="SimpleLog-iPhone-${VERSION}.ipa"

TARGET_DIR="$RELEASE_DIR/$VERSION"


###############################################
# Rename macOS application
###############################################

echo
echo "Preparing macOS application..."

MAC_APP=$(find "$MAC_BUILD_DIR" -maxdepth 1 -name "*.app" -type d | head -1)

if [ -z "$MAC_APP" ]; then
    echo "ERROR: No macOS .app found"
    ls -la "$MAC_BUILD_DIR"
    exit 1
fi

echo "Found app: $MAC_APP"

if [ "$(basename "$MAC_APP")" != "SimpleLog.app" ]; then

    TEMP_APP="$MAC_BUILD_DIR/SimpleLog_temp.app"

    echo "Renaming:"
    echo "  $MAC_APP"
    echo "  -> $TEMP_APP"

    mv "$MAC_APP" "$TEMP_APP"

    mv "$TEMP_APP" "$MAC_BUILD_DIR/SimpleLog.app"
fi


###############################################
# Rename Android APK
###############################################

echo "Preparing Android APK..."

APK_PATH="$PROJECT_DIR/build/app/outputs/flutter-apk/$APK_NAME"

rm -f "$APK_PATH"
mv "$APK_SRC" "$APK_PATH"


###############################################
# Rename iOS IPA
###############################################

echo "Preparing iOS IPA..."

if [ -z "$IPA_SRC" ] || [ ! -f "$IPA_SRC" ]; then
    echo "ERROR: IPA file not found"
    exit 1
fi

IPA_PATH="$IPA_DIR/$IPA_NAME"

rm -f "$IPA_PATH"
mv "$IPA_SRC" "$IPA_PATH"


###############################################
# Create Mac ZIP
###############################################

echo "Creating macOS ZIP..."

ZIP_NAME="SimpleLog-Mac-${VERSION}.zip"
ZIP_PATH="$MAC_BUILD_DIR/$ZIP_NAME"

rm -f "$ZIP_PATH"

cd "$MAC_BUILD_DIR"

ditto -c -k --sequesterRsrc --keepParent \
    "SimpleLog.app" \
    "$ZIP_NAME"

cd "$PROJECT_DIR"


###############################################
# Create release folder
###############################################

echo "Creating release folder..."

mkdir -p "$TARGET_DIR"


###############################################
# Move artifacts
###############################################

echo "Moving release artifacts..."

mv "$ZIP_PATH" "$TARGET_DIR/"
mv "$APK_PATH" "$TARGET_DIR/"
mv "$IPA_PATH" "$TARGET_DIR/"


###############################################
# Move Windows artifact if available
###############################################

WINDOWS_ZIP="$RELEASE_DIR/SimpleLog-Windows-${VERSION}.zip"

if [ -f "$WINDOWS_ZIP" ]; then
    echo "Moving Windows artifact..."
    mv "$WINDOWS_ZIP" "$TARGET_DIR/"
fi


# ###############################################
# # Upload iOS to App Store Connect
# ###############################################

# echo
# echo "Uploading iOS IPA to App Store Connect..."

# APP_PASSWORD=$(security find-generic-password \
#     -a "$APPLE_ID" \
#     -s "$KEYCHAIN_SERVICE" \
#     -w)

# if [ -z "$APP_PASSWORD" ]; then
#     echo "ERROR: App Store password not found in Keychain"
#     exit 1
# fi


# xcrun iTMSTransporter \
#     -m upload \
#     -assetFile "$TARGET_DIR/$IPA_NAME" \
#     -u "$APPLE_ID" \
#     -p "$APP_PASSWORD"


# echo "iOS upload completed."


###############################################
# Create GitHub release notes
###############################################

echo
echo "Enter NEW FEATURES for this release."
echo "Finish with Ctrl+D."
echo

FEATURES=$(cat)


cat > /tmp/simplelog_release_notes.md <<EOF
🚀 SimpleLog $VERSION

New feature:
$FEATURES

## 🧭 Notes

This is the initial stable public release.

Feedback, bug reports, and format compatibility issues are welcome as the import system will continue to expand and improve in future releases.
EOF


###############################################
# Create GitHub release
###############################################

echo
echo "Creating GitHub release..."

RELEASE_FILES=(
    "$TARGET_DIR/SimpleLog-Mac-${VERSION}.zip"
    "$TARGET_DIR/$APK_NAME"
    "$TARGET_DIR/$IPA_NAME"
)


WINDOWS_ARTIFACT="$TARGET_DIR/SimpleLog-Windows-${VERSION}.zip"

if [ -f "$WINDOWS_ARTIFACT" ]; then
    RELEASE_FILES+=("$WINDOWS_ARTIFACT")
fi


gh release create "$VERSION" \
    "${RELEASE_FILES[@]}" \
    --title "SimpleLog $VERSION" \
    --notes-file /tmp/simplelog_release_notes.md


###############################################
# Finished
###############################################

echo
echo "======================================"
echo "Release completed successfully!"
echo
echo "Version: $VERSION"
echo
echo "Artifacts:"
ls -lh "$TARGET_DIR"
echo
echo "======================================"