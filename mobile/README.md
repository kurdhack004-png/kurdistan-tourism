# Kurdistan Tourism V11

Flutter tourism application for Kurdistan with Kurdish (Sorani), Arabic and English support.

## Requirements

- Flutter stable 3.47.x or newer
- Dart 3.7+
- Android Studio with Flutter/Dart plugins
- JDK 21 for the current MapLibre Android stack
- Android SDK with API 21+

## Run with VS Code

1. Open this `mobile` folder.
2. Install the Flutter and Dart extensions.
3. Run `flutter pub get`.
4. Press F5, or run `flutter run`.

The `.vscode/launch.json` file contains both offline/local-demo mode and an Android-emulator API configuration.

## Run with Android Studio

Open the `mobile` folder, not the backend folder. Make sure the Flutter plugin is installed. Select an emulator or USB-connected Android phone and press Run.

If Android Gradle wrapper files are missing, run:

```text
flutter create --platforms=android --org com.kurdistan .
flutter clean
flutter pub get
flutter run
```

The project uses Java 21, Android API 21+ and the Gradle/Android Gradle Plugin versions required by the current MapLibre Android stack.

## API mode

The mobile app can connect to the Laravel API with:

```text
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api
```

For a physical Android phone, replace `10.0.2.2` with the computer's LAN IP address.

## Offline / local-demo mode

The app intentionally remains usable when the API is unavailable:

- Tourist locations fall back to built-in Kurdistan demo locations.
- Hotels fall back to built-in accommodation data.
- Bookings are stored locally when the API is unavailable.
- Reviews can be created locally when the API is unavailable.
- Login/register can use local demo authentication when the backend is unavailable.
- Favorites, settings and trip selections are persisted locally.

This fallback is for development/demo use. For production, connect the app to the real backend and payment provider.
