# Render deployment checklist

## 1. Create the database

- Create a managed PostgreSQL database in Render.
- Copy the internal database connection values into the API service environment.
- Enable PostGIS if spatial queries are required:

```sql
CREATE EXTENSION IF NOT EXISTS postgis;
```

## 2. Create the web service

- Root directory: `backend`
- Runtime: PHP/Laravel using the repository's supported build process
- Start command must run migrations safely and then start the web server.
- Set `APP_ENV=production`, `APP_DEBUG=false`, and the public `APP_URL`.

## 3. Required environment variables

Set these in Render's secret environment settings, not in GitHub:

- `APP_KEY`
- `APP_URL`
- `DB_*`
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_BUCKET`
- `AWS_ENDPOINT` when required
- `FIB_API_BASE`
- `FIB_API_KEY`
- `PAYMENT_WEBHOOK_SECRET`

## 4. Production checks before launch

- Run migrations against a staging database first.
- Confirm `/api/health` returns online.
- Confirm authentication and role authorization.
- Test booking date-overlap protection.
- Test webhook signature verification and replay protection.
- Confirm payments remain pending until the provider confirms them.
- Confirm uploaded media is validated and stored outside the repository.
- Enable HTTPS, restricted CORS, rate limits, logs, backups, and monitoring.

Do not publish the app or accept real payments until these checks pass and the payment provider's official integration has been completed.
