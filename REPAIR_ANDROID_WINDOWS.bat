@echo off
setlocal EnableExtensions
cd /d "%~dp0"
if not exist "mobile\android\gradle\wrapper\gradle-wrapper.jar" (
  echo [ERROR] Gradle wrapper JAR is missing from this package.
  echo Re-download the COMPLETE_FIXED package and extract it again.
  pause
  exit /b 1
)
echo [OK] Gradle wrapper is present. No Android project files were overwritten.
exit /b 0
