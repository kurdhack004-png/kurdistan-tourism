# Kurdistan Tourism — GitHub Cloud Build

This project is prepared to build the Flutter Android app in GitHub Actions without a laptop.

## What the workflow does

- Uses Ubuntu 24.04 on GitHub-hosted runners.
- Uses Java 21.
- Uses Flutter 3.29.3 stable.
- Runs `flutter pub get`.
- Runs `flutter analyze`.
- Builds a release APK.
- Builds a release Android App Bundle (AAB).
- Uploads both files as GitHub Actions artifacts.

GitHub Actions artifacts can be downloaded from the completed workflow run.

## Important: API URL

The app defaults to:

`http://10.0.2.2:8000/api`

That address is useful for an Android emulator talking to a local backend, but it is NOT your phone's public server address.

If the backend is hosted online, add a repository variable:

`API_BASE_URL=https://YOUR-DOMAIN.example/api`

If you do not have an online backend yet, the app's local/demo authentication and offline-first parts can still be used where supported by the existing code.

## From a phone

1. Create a GitHub repository.
2. Upload the contents of this project so that `mobile/pubspec.yaml` and `.github/workflows/android-build.yml` are at those exact paths.
3. Open the repository's **Actions** tab.
4. Select **Build Kurdistan Tourism Android**.
5. Press **Run workflow**.
6. Wait for the workflow to finish.
7. Open the successful run and download the `kurdistan-tourism-apk` artifact.

The APK can then be installed on an Android phone. GitHub's artifact storage is intended for build outputs such as binaries and can be downloaded from completed workflow runs.
