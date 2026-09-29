const { q } = require('./db');

async function initDb() {
  await q(`
    CREATE TABLE IF NOT EXISTS users (
      id TEXT PRIMARY KEY, name TEXT NOT NULL, email TEXT UNIQUE NOT NULL,
      password TEXT NOT NULL, role TEXT DEFAULT 'user', banned BOOLEAN DEFAULT FALSE,
      created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );
    CREATE TABLE IF NOT EXISTS locations (
      id TEXT PRIMARY KEY, name TEXT NOT NULL, description TEXT DEFAULT '',
      category TEXT DEFAULT 'other', city TEXT DEFAULT '', lat DOUBLE PRECISION,
      lng DOUBLE PRECISION, rating DOUBLE PRECISION DEFAULT 0, image TEXT DEFAULT '',
      images JSONB DEFAULT '[]'::jsonb, verified BOOLEAN DEFAULT TRUE,
      name_ku TEXT DEFAULT '', name_ar TEXT DEFAULT '', description_ku TEXT DEFAULT '',
      description_ar TEXT DEFAULT '', video TEXT DEFAULT '', directions TEXT DEFAULT '',
      is_new BOOLEAN DEFAULT FALSE, is_featured BOOLEAN DEFAULT FALSE,
      created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );
    CREATE TABLE IF NOT EXISTS accommodations (
      id TEXT PRIMARY KEY, name TEXT NOT NULL, city TEXT DEFAULT '',
      type TEXT DEFAULT 'hotel', price DOUBLE PRECISION DEFAULT 0,
      rating DOUBLE PRECISION DEFAULT 0, image TEXT DEFAULT '', images JSONB DEFAULT '[]'::jsonb,
      description TEXT DEFAULT '', description_ku TEXT DEFAULT '', description_ar TEXT DEFAULT '',
      phone TEXT DEFAULT '', lat DOUBLE PRECISION, lng DOUBLE PRECISION,
      active BOOLEAN DEFAULT TRUE, listing_until TIMESTAMPTZ,
      created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );
    CREATE TABLE IF NOT EXISTS bookings (
      id TEXT PRIMARY KEY, user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      accommodation_id TEXT NOT NULL REFERENCES accommodations(id), date DATE NOT NULL,
      nights INTEGER NOT NULL DEFAULT 1, total DOUBLE PRECISION DEFAULT 0, guests INTEGER DEFAULT 1,
      status TEXT DEFAULT 'pending', payment_status TEXT DEFAULT 'unpaid',
      fee DOUBLE PRECISION DEFAULT 0, created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );
    CREATE TABLE IF NOT EXISTS reviews (
      id TEXT PRIMARY KEY, user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      location_id TEXT NOT NULL REFERENCES locations(id) ON DELETE CASCADE,
      rating INTEGER NOT NULL, comment TEXT DEFAULT '', created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );
    CREATE TABLE IF NOT EXISTS favorites (
      user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      location_id TEXT NOT NULL REFERENCES locations(id) ON DELETE CASCADE,
      PRIMARY KEY(user_id, location_id)
    );
    CREATE TABLE IF NOT EXISTS settings (key TEXT PRIMARY KEY, value TEXT);
    CREATE TABLE IF NOT EXISTS ads (
      id TEXT PRIMARY KEY, title TEXT, company TEXT DEFAULT '', image TEXT DEFAULT '',
      link TEXT DEFAULT '', price DOUBLE PRECISION DEFAULT 0, starts_at TIMESTAMPTZ,
      ends_at TIMESTAMPTZ, active BOOLEAN DEFAULT TRUE, created_at TIMESTAMPTZ DEFAULT NOW()
    );
    CREATE TABLE IF NOT EXISTS hero_images (
      id TEXT PRIMARY KEY, image TEXT NOT NULL, sort_order INTEGER DEFAULT 0,
      active BOOLEAN DEFAULT TRUE, created_at TIMESTAMPTZ DEFAULT NOW()
    );
    CREATE TABLE IF NOT EXISTS emergency_contacts (
      id TEXT PRIMARY KEY, label TEXT, label_ku TEXT DEFAULT '', label_ar TEXT DEFAULT '',
      phone TEXT, sort_order INTEGER DEFAULT 0, created_at TIMESTAMPTZ DEFAULT NOW()
    );
    CREATE TABLE IF NOT EXISTS notifications (
      id TEXT PRIMARY KEY, title TEXT, body TEXT DEFAULT '', created_at TIMESTAMPTZ DEFAULT NOW()
    );
    CREATE TABLE IF NOT EXISTS listing_payments (
      id TEXT PRIMARY KEY, accommodation_id TEXT REFERENCES accommodations(id) ON DELETE CASCADE,
      amount DOUBLE PRECISION, months INTEGER DEFAULT 1, until TIMESTAMPTZ, created_at TIMESTAMPTZ DEFAULT NOW()
    );
    INSERT INTO settings(key,value) VALUES
      ('booking_fee','10000'),('listing_fee','30000'),('ad_price_24h','10000'),
      ('hero_interval_sec','5'),('currency','IQD')
    ON CONFLICT (key) DO NOTHING;
  `);
}
module.exports = { initDb };
