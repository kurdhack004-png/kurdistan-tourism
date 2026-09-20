# Kurdistan Tourism API — v10 (Laravel + PostgreSQL/PostGIS)

This backend is a production-oriented foundation for the Kurdistan Tourism platform. It includes core patterns for authentication, locations, accommodations, bookings, payments, reviews, spatial queries, and admin operations.

> **Production status:** this repository is not yet ready to accept real customer payments or public traffic without deployment configuration, provider credentials, webhook verification, security review, tests, and operational monitoring. No payment should be marked as successful merely because a client calls the payment endpoint.

## Architecture

- Laravel 11 API
- PostgreSQL + PostGIS for spatial data and distance queries
- Laravel Sanctum for token authentication
- Role-based access: tourist, owner, guide, admin
- Flutter mobile client under `mobile/`
- Admin dashboard under `admin-dashboard/`
- Deployment target: Render or another managed hosting provider

## Core capabilities

- Register, login, logout, and current-user profile
- Locations with category, governorate, coordinates, verification, and nearby search
- Accommodations with hotel/house/cabin/chalet types and availability checks
- Booking creation with date-overlap protection and a 10,000 IQD booking fee
- Idempotent payment-intent creation
- Reviews and favorites
- Admin management for locations, accommodations, users, bookings, reviews, ads, and media

## Required before production launch

1. Create a managed PostgreSQL database with PostGIS enabled.
2. Configure all environment variables in the hosting provider; never commit `.env`, API keys, private keys, or payment secrets.
3. Configure object storage for images and videos, with private upload handling and size/type validation.
4. Integrate an approved payment provider (for example, FIB or a supported card provider) using its official server-side API.
5. Implement and verify signed payment webhooks. The server must transition a payment to `paid` only after provider-side verification.
6. Add payment states such as `pending`, `processing`, `paid`, `failed`, `expired`, and `refunded`, plus reconciliation handling.
7. Add automated tests for authentication, authorization, booking overlap, price calculation, idempotency, webhook replay, and admin permissions.
8. Configure HTTPS, CORS restrictions, rate limits, logging, backups, database migrations, and monitoring.
9. Configure production map keys and restrictions through environment variables.
10. Review privacy, terms, cancellation/refund rules, owner verification, and local payment/legal requirements before launch.

## Local setup

```bash
composer install
cp .env.example .env
php artisan key:generate
php artisan migrate
php artisan serve
```

For PostgreSQL/PostGIS, create the database first and enable the PostGIS extension:

```sql
CREATE EXTENSION IF NOT EXISTS postgis;
```

## Payment safety rule

The current `POST /bookings/{id}/pay` endpoint creates a **pending payment record** and supports idempotency. It must not be treated as proof of payment. Provider-specific checkout creation and a signed webhook handler must be added before enabling real-money transactions.

## Recommended implementation order

1. Deploy PostgreSQL/PostGIS and run migrations.
2. Configure Sanctum, roles, CORS, rate limiting, and production environment secrets.
3. Complete owner/guide/admin authorization rules.
4. Add real location and accommodation records through the admin API.
5. Add secure object-storage uploads and media processing.
6. Add provider-specific payment checkout and signed webhooks.
7. Add automated tests and CI gates.
8. Connect Flutter production API configuration.
9. Perform staging acceptance tests, then publish the release APK.

## Important limitation

A real database, storage bucket, map key, and payment account cannot be created solely by changing source code. The required services must be provisioned by the project owner, and their credentials must be entered as protected environment variables in the deployment platform.
