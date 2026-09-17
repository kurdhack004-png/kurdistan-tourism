# Kurdistan Tourism — Windows build checklist

## Requirements
- Flutter 3.47+
- Dart 3.7+
- JDK 17 (JAVA_HOME must point to JDK 17)
- Android SDK installed and accepted licenses
- Node.js 20+

## First run
1. Run `REPAIR_ANDROID_WINDOWS.bat` once if `android/gradle/wrapper/gradle-wrapper.jar` is missing.
2. Run `SETUP_ALL_WINDOWS.bat`.
3. Start the API and verify `http://localhost:8000/api/health`.
4. For Android Emulator use `http://10.0.2.2:8000/api`.
5. For a physical phone, use the PC's LAN IP and ensure Windows Firewall allows port 8000.

## Release
Run from `mobile`:

`flutter analyze`

`flutter build apk --release --dart-define=API_BASE_URL=https://YOUR-HTTPS-DOMAIN/api`

For production, use HTTPS, replace the development JWT secret, configure a real payment provider, and configure a production map style/provider. Do not ship the demo payment flow as a real payment gateway.

## Android toolchain
This package targets JDK 17. The Gradle wrapper is included in `mobile/android/gradle/wrapper/gradle-wrapper.jar`, so a separate Gradle installation is not required. The first Gradle run may download Gradle 8.13 from services.gradle.org; internet access is required for that first download.
