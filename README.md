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

## Admin dashboard

Start the API, then open **http://localhost:8000/admin** (the API serves the dashboard itself, so there are no CORS problems).
Log in with `ADMIN_EMAIL` / `ADMIN_PASSWORD` from `backend-node/.env`, then change the password under *My account*.

From the dashboard you can manage everything without touching the database:

| Section | What you can do |
|---|---|
| Dashboard | Users, places, bookings, reviews, active ads, income (booking fees + listing fees + ads) |
| Places | Add / edit / delete mountains, lakes, waterfalls, caves, nature, parks, historical and cultural places (Kurdish / Arabic / English text, GPS, main image + gallery upload, video link, directions, new / featured flags) |
| Accommodation | Hotels, houses, cabins, chalets: price, GPS, images, active on/off, monthly listing fee renewal |
| Bookings | See all bookings, change booking status and payment status (incl. refunds) |
| Users | Create users or **new admins**, change role, ban / unban, reset password, delete |
| Reviews | Moderate (delete) reviews; place ratings are recalculated automatically |
| Advertisements | Create ads for companies (24h by default at the configured price) |
| Home slider | Images that rotate on the app home screen, order and on/off |
| Emergency | Police, ambulance, fire, tourism contact numbers |
| Notifications | Publish notifications shown in the app |
| Settings & fees | Booking fee, monthly listing fee, ad price, slider interval, currency |

The dashboard is available in Kurdish (RTL) and English. See `docs/ADMIN.md` for the API endpoints the mobile app can use
(`/api/hero`, `/api/ads`, `/api/emergency`, `/api/notifications`, `/api/settings/public`).

## Production notes

The bundled payment endpoint is a demo confirmation endpoint, not a real payment gateway. Replace it with Stripe, a local bank gateway, or another provider before charging real money. Configure production maps, HTTPS, database backups, CORS, secrets, monitoring and AI provider credentials.
