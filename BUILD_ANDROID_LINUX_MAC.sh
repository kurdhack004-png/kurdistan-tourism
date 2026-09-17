#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/mobile"
command -v flutter >/dev/null || { echo "Flutter SDK is not installed or not in PATH."; exit 1; }
flutter clean
flutter pub get
flutter analyze
flutter build apk --release
echo "BUILD SUCCESSFUL"
echo "APK: mobile/build/app/outputs/flutter-apk/app-release.apk"
