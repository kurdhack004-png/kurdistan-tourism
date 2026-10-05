const { Pool } = require('pg');
require('dotenv').config();

const connectionString = process.env.DATABASE_URL;
const ssl = process.env.PGSSL === 'disable' || !process.env.DATABASE_URL ? false : { rejectUnauthorized: false };

const pool = new Pool({
  ...(connectionString ? { connectionString } : {
    host: process.env.PGHOST,
    port: process.env.PGPORT || 5432,
    database: process.env.PGDATABASE || 'defaultdb',
    user: process.env.PGUSER || 'avnadmin',
    password: process.env.PGPASSWORD
  }),
  ssl,
  max: Number(process.env.PGPOOL_MAX || 5),
  connectionTimeoutMillis: 15000,
  idleTimeoutMillis: 30000
});

pool.on('error', err => console.error('PostgreSQL pool error:', err.message));

const q = (text, params=[]) => pool.query(text, params);
module.exports = { pool, q };
