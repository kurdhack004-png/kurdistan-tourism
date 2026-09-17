# Quickstart backend (PHP + SQLite) — optional

This is an **alternative** to `backend/` (Laravel + PostgreSQL/PostGIS),
not a replacement. Use it only when you want to run the Flutter app
against a real server in under a minute, with nothing to install beyond
PHP itself — no Postgres, no Composer, no Redis.

```bash
php -S 0.0.0.0:8080 -t api api/index.php
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080
```

It creates `data.sqlite` automatically and seeds six sample Kurdistan
destinations, with endpoints for auth, locations, and bookings.

**Coverage note:** this quickstart API only implements the endpoints
listed in `api/README.md` (health, locations, auth, bookings). It does
**not** implement `/reviews`, `/accommodations`, or `/bookings/{id}/pay`
that the mobile app's Reviews and Nearby-Stays screens call — those
screens will show an error against this backend until you either add
those routes here yourself or switch to the Laravel backend.

## Why the Laravel backend is still the one to build on

This PHP/SQLite version is deliberately minimal:

- No spatial indexing — `locations` stores plain lat/lng, so a "nearby"
  query means scanning and sorting every row in PHP, not a GiST index.
- No role-based access, no rate limiting, no idempotency key on payments.
- SQLite has a single writer at a time — fine for a demo, not for
  concurrent bookings in production.

Treat this folder as a fast way to click through the mobile app end to
end while the Laravel/PostGIS backend is still being set up — not as
the production backend.
