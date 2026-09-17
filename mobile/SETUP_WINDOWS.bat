@echo off
setlocal EnableExtensions
cd /d "%~dp0"
echo ==============================================
echo   Kurdistan Tourism - Flutter Setup
echo ==============================================
where flutter >nul 2>nul
if errorlevel 1 (echo [ERROR] Flutter is not in PATH.&exit /b 1)
where java >nul 2>nul
if errorlevel 1 (echo [ERROR] JDK 17 is not in PATH.&exit /b 1)
if not exist "android\gradle\wrapper\gradle-wrapper.jar" (echo [ERROR] Gradle wrapper is missing from this package.&exit /b 1)
echo.
echo [Environment]
flutter --version
java -version
cd /d "%~dp0"
echo.
echo [1/4] Cleaning...
call flutter clean
if errorlevel 1 exit /b 1
echo [2/4] Packages...
call flutter pub get
if errorlevel 1 exit /b 1
echo [3/4] Static analysis...
call flutter analyze
if errorlevel 1 (
  echo [ERROR] flutter analyze found issues. See the messages above.
  exit /b 1
)
echo [4/4] Android debug build...
call flutter build apk --debug --dart-define=API_BASE_URL=http://10.0.2.2:8000/api
if errorlevel 1 (
  echo [ERROR] Android build failed. See the messages above.
  exit /b 1
)
echo.
echo ==============================================
echo READY - Debug APK build succeeded.
echo Emulator API: http://10.0.2.2:8000/api
echo Real phone: replace 10.0.2.2 with your PC LAN IP.
echo ==============================================
pause
