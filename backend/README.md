# Kurdistan Tourism API — v9 (Laravel + PostGIS)

This is a starter skeleton that replaces the V8.1 PHP/MySQL backend with a
production-oriented Laravel + PostgreSQL/PostGIS API. It is not a full
implementation of all 64 V8.1 tables — it ports the highest-value core
(auth, locations, trails, accommodations, bookings/payments, reviews,
events, offline packages) and establishes the patterns (spatial columns,
form-request validation, role middleware, rate limiting) to extend to the
rest of the schema.

## Setup

```bash
composer create-project laravel/laravel:^11.0 kurdistan-tourism-api
cd kurdistan-tourism-api
# copy the app/, database/, routes/, config/ files from this package
# over the freshly generated project, then:

composer require laravel/sanctum clickbar/laravel-magellan spatie/laravel-query-builder

cp .env.example .env
php artisan key:generate

# Create the Postgres database first, with the postgis extension available:
#   createdb kurdistan_tourism_v9
php artisan migrate

php artisan serve
```

## Why these choices over the V8.1 starter

- **PostgreSQL + PostGIS** instead of MySQL: `geography(Point,4326)` and
  `geography(LineString,4326)` columns give native spatial indexing
  (GiST) and distance queries (`ST_DWithin`, `<->` nearest-neighbor)
  instead of manually comparing lat/lng floats.
- **Laravel Sanctum** instead of a hand-rolled HMAC token: battle-tested,
  supports token expiration, abilities, and revocation.
- **Form Requests** per endpoint instead of a generic
  `information_schema`-driven CRUD: real validation, no accidental
  exposure of arbitrary tables/columns.
- **Rate limiting** on auth endpoints (`throttle:10,1`) and a dedicated
  login attempt limiter — the V8.1 starter had none.
- **Role middleware** (`role:admin,guide`) instead of a single
  `require_role()` helper function — composable per-route.
- **Idempotency key** on payments to prevent double-charging on client
  retries — not present in the V8.1 schema.

## Next steps to extend

1. Port the remaining V8.1 tables (mountain_details, cave_details,
   water_systems, tags, translations, GIS layers, ...) following the
   `locations`/`trails` migration pattern.
2. Add `spatie/laravel-query-builder` filters/sorts to `LocationController`
   for richer client-side querying without hand-writing each filter.
3. Add a queued job for image processing (thumbnails, WebP conversion)
   on media upload.
4. Wire the FIB/Visa payment webhook handlers referenced in `payments`
   — `BookingController::pay()` currently marks card payments 'paid'
   immediately, which is only correct until you have a real webhook to
   confirm the charge server-side.
5. Add `php artisan test` coverage — none exists yet in this skeleton.

## What's implemented (v10)

- `AuthController` — register/login/logout/me via Sanctum, with login
  rate limiting.
- `LocationController` — spatial nearby search, category/governorate
  filters, submit-for-verification flow.
- `AccommodationController` — spatial nearby search, type filter.
- `BookingController` — create a booking, list the user's own bookings,
  and an idempotent `pay()` endpoint.
- `ReviewController` — polymorphic reviews for locations, accommodations,
  or trails.
