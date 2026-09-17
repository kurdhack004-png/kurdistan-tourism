@echo off
setlocal
cd /d "%~dp0mobile"
echo ========================================
echo Kurdistan Tourism - Android Build
 echo ========================================
where flutter >nul 2>&1
if errorlevel 1 (
  echo ERROR: Flutter SDK is not installed or not in PATH.
  echo Install Flutter and run: flutter doctor -v
  pause
  exit /b 1
)
call flutter clean
if errorlevel 1 goto :fail
call flutter pub get
if errorlevel 1 goto :fail
call flutter analyze
if errorlevel 1 goto :fail
call flutter build apk --release
if errorlevel 1 goto :fail
echo.
echo BUILD SUCCESSFUL
echo APK: mobile\build\app\outputs\flutter-apk\app-release.apk
pause
exit /b 0
:fail
echo.
echo BUILD FAILED - see the error above.
pause
exit /b 1
