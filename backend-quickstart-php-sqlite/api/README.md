# Simple production-friendly PHP API

This API is intentionally dependency-free: PHP 8.1+ with PDO SQLite is enough. It creates `data.sqlite` automatically and seeds six Kurdistan destinations.

## Local test
```bash
php -S 0.0.0.0:8080 -t api api/index.php
```
Then set Flutter:
```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080
```
For a real Android phone use your computer's LAN IP instead of `10.0.2.2`.

## Shared hosting
Upload the `api` folder to your PHP hosting, make sure PHP 8.1+ and PDO SQLite are enabled, and allow the web server to write the folder so `data.sqlite` can be created. Then use the HTTPS API folder URL as `API_BASE_URL`.

Endpoints:
- GET /health
- GET /locations?q=...
- GET /locations/{id}
- POST /auth/register
- POST /auth/login
- GET /auth/me
- POST /auth/logout
- POST /bookings
- GET /bookings
