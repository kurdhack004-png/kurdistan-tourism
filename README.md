# Kurdistan Tourism V12 PRO

Flutter mobile app + Node.js API + dependency-free admin dashboard.

## Windows quick start

1. Install Flutter 3.47+ and JDK 21.
2. Run `REPAIR_ANDROID_WINDOWS.bat` if the Android Gradle wrapper is missing.
3. Run `SETUP_ALL_WINDOWS.bat`.
4. For Android Emulator, the app uses `http://10.0.2.2:8000/api`.
5. For a physical phone, use the PC LAN address, e.g. `http://192.168.1.10:8000/api`.

## Backend

```text
cd backend-node
copy .env.example .env
npm install
npm start
```

Health: `http://localhost:8000/api/health`

Change `JWT_SECRET` and `ADMIN_PASSWORD` before production. In production set `NODE_ENV=production` and use a long random JWT secret.

## Mobile

```text
cd mobile
flutter pub get
flutter analyze
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api
```

## Admin

Open `admin-dashboard/index.html` after starting the API. The dashboard stores its token in browser local storage.

## Production notes

The bundled payment endpoint is a demo confirmation endpoint, not a real payment gateway. Replace it with Stripe, a local bank gateway, or another provider before charging real money. Configure production maps, HTTPS, database backups, CORS, secrets, monitoring and AI provider credentials.
