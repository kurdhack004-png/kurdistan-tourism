# Production deployment

This repository contains a Laravel API under `backend/` and a Flutter client under `mobile/`.

## Render API

The root `render.yaml` defines the Laravel web service and declares the production-only values that must be supplied in Render:

- `DATABASE_URL` — PostgreSQL connection string.
- `APP_URL` — the public HTTPS URL of the deployed API.

Do not commit either secret/value to Git. Render supports `sync: false` placeholders for values that are entered in the Dashboard. citeturn2search0turn2search6

The service health endpoint is:

`/api/health`

Render's health check is configured to use that path.

## Database

The Laravel database configuration already supports `DATABASE_URL` for PostgreSQL. For a Render-hosted API, use the database connection string supplied by your Render PostgreSQL instance. Render recommends wiring a database through a Blueprint `fromDatabase` reference when the database is managed by the same Blueprint. citeturn0search0turn0search1

For an existing Render database, add its connection string to `DATABASE_URL` in the service environment. Do not place credentials in the repository.

## Flutter API URL

The Flutter client reads:

`API_BASE_URL`

with `--dart-define`. The local development default remains:

`http://10.0.2.2:8000/api`

For a release build, pass the deployed API URL explicitly, for example:

`flutter build apk --release --dart-define=API_BASE_URL=https://YOUR-API-DOMAIN/api`

This avoids baking an unverified deployment hostname into the app.

## Deployment order

1. Configure PostgreSQL and `DATABASE_URL` in Render.
2. Configure `APP_URL`.
3. Deploy the Laravel service.
4. Confirm `GET /api/health` returns a successful response.
5. Build the Flutter app with the verified API URL.
6. Test registration, login, locations, favorites, booking and logout against the deployed API.

The Laravel container runs migrations and the curated tourism seed during startup. The seed contains verified reference locations and intentionally does not fabricate hotels, prices, ratings or reviews.
