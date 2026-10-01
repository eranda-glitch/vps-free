#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"
SDK="${1:-iphoneos}"
case "$SDK" in
  iphoneos) TARGET="arm64-apple-ios15.0"; PLATFORM="iPhoneOS"; APP="build/device/Payload/FlappyWeb.app" ;;
  iphonesimulator) TARGET="$(uname -m)-apple-ios15.0-simulator"; PLATFORM="iPhoneSimulator"; APP="build/simulator/FlappyWeb.app" ;;
  *) echo "Unsupported SDK: $SDK" >&2; exit 1 ;;
esac
mkdir -p "$APP" artifacts
xcrun --sdk "$SDK" clang -target "$TARGET" -isysroot "$(xcrun --sdk "$SDK" --show-sdk-path)" \
  -fobjc-arc -O2 -Wall -Wextra -Wno-unused-parameter \
  -framework UIKit -framework WebKit -framework Foundation FlappyWeb.m -o "$APP/FlappyWeb"
cp Info.plist "$APP/Info.plist"
cp AppIcon60x60@2x.png AppIcon60x60@3x.png "$APP/"
/usr/libexec/PlistBuddy -c "Add :CFBundleSupportedPlatforms array" "$APP/Info.plist"
/usr/libexec/PlistBuddy -c "Add :CFBundleSupportedPlatforms:0 string $PLATFORM" "$APP/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion ${GITHUB_RUN_NUMBER:-1}" "$APP/Info.plist"
printf 'APPL????' > "$APP/PkgInfo"
plutil -lint "$APP/Info.plist"
plutil -convert binary1 "$APP/Info.plist"
if [[ "$SDK" == "iphoneos" ]]; then
  if codesign -d "$APP/FlappyWeb" 2>/dev/null; then
    codesign --remove-signature "$APP/FlappyWeb"
  fi
  if codesign -d "$APP/FlappyWeb" 2>/dev/null; then
    echo 'Device executable must be unsigned' >&2; exit 1
  fi
  file "$APP/FlappyWeb" | tee artifacts/device-binary.txt
  xcrun lipo -verify_arch arm64 "$APP/FlappyWeb"
  (cd build/device && /usr/bin/zip -q -r ../../artifacts/FlappyWeb-unsigned.ipa Payload)
  unzip -t artifacts/FlappyWeb-unsigned.ipa
  shasum -a 256 artifacts/FlappyWeb-unsigned.ipa | tee artifacts/SHA256SUMS.txt
else
  /usr/libexec/PlistBuddy -c 'Delete :UIRequiredDeviceCapabilities' "$APP/Info.plist"
  codesign --force --sign - "$APP"
fi
