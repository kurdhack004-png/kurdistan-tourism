@echo off
setlocal EnableExtensions
cd /d "%~dp0"
echo ==========================================
echo Kurdistan Tourism - Full Setup / Preflight
echo ==========================================
where node >nul 2>nul
if errorlevel 1 (echo [ERROR] Node.js 20+ is required.&pause&exit /b 1)
where flutter >nul 2>nul
if errorlevel 1 (echo [ERROR] Flutter is required and must be in PATH.&pause&exit /b 1)
where java >nul 2>nul
if errorlevel 1 (echo [ERROR] JDK 17 is required and must be in PATH.&pause&exit /b 1)
call mobile\android\gradlew.bat --version >nul 2>nul
if errorlevel 1 (echo [ERROR] Gradle could not start. Check JDK 17 and internet access.&pause&exit /b 1)
cd backend-node
if not exist .env copy .env.example .env
call npm install
if errorlevel 1 exit /b 1
start "Kurdistan Tourism API" cmd /k "cd /d %CD% && npm start"
cd ..\mobile
call SETUP_WINDOWS.bat
if errorlevel 1 exit /b 1
cd ..
echo.
echo ==========================================
echo READY - Android debug build passed.
echo Emulator API: http://10.0.2.2:8000/api
echo Real phone: use your PC LAN IP instead.
echo ==========================================
pause
