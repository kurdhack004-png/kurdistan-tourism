# PostgreSQL deployment

The Node API uses the `pg` package and PostgreSQL.

Set these environment variables in the hosting provider. Never commit real credentials:

- `DATABASE_URL`: Aiven PostgreSQL service URI ending in `?sslmode=require`
- `JWT_SECRET`: random secret with at least 32 characters
- `ADMIN_EMAIL`
- `ADMIN_PASSWORD`
- `CORS_ORIGIN`
- `PORT`

Build command:

```
npm install
```

Start command:

```
npm start
```

The API listens on `0.0.0.0:$PORT` and creates the PostgreSQL tables on startup.
