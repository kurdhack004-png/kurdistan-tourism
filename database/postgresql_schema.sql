-- ============================================================
-- KURDISTAN TOURISM — V9 CORE SCHEMA (PostgreSQL 16 + PostGIS)
-- ============================================================
-- NOTE: This migrates the highest-value tables from the V8.1
-- MySQL schema (users, locations, trails, accommodations,
-- bookings, reviews, events, offline_packages) into PostGIS-aware
-- structures. The remaining ~55 supporting tables from V8.1
-- (mountain_details, cave_details, water_systems, tags,
-- translations, GIS layers, etc.) follow the same pattern shown
-- here — flat MySQL columns become normalized foreign keys and
-- any lat/lng pair becomes a single `geography(Point,4326)`
-- column so it can be spatially indexed and queried.
-- ============================================================

CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS pg_trgm; -- fast fuzzy text search on names/descriptions

-- ---------- ENUM TYPES ----------
CREATE TYPE user_role AS ENUM ('tourist', 'guide', 'accommodation_owner', 'admin');
CREATE TYPE location_category AS ENUM (
  'mountain', 'cave', 'lake', 'river', 'waterfall', 'spring',
  'historical', 'archaeological', 'nature_reserve', 'other'
);
CREATE TYPE booking_status AS ENUM ('pending', 'confirmed', 'cancelled', 'completed');
CREATE TYPE payment_method AS ENUM ('fib', 'visa', 'cash', 'bank_transfer');
CREATE TYPE payment_status AS ENUM ('pending', 'paid', 'failed', 'refunded');

-- ---------- USERS ----------
CREATE TABLE users (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  full_name       VARCHAR(150) NOT NULL,
  email           VARCHAR(190) NOT NULL UNIQUE,
  phone_number    VARCHAR(30),
  password_hash   VARCHAR(255) NOT NULL,
  role            user_role NOT NULL DEFAULT 'tourist',
  preferred_lang  VARCHAR(5) NOT NULL DEFAULT 'ckb', -- ckb = Sorani Kurdish
  is_active       BOOLEAN NOT NULL DEFAULT TRUE,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE personal_access_tokens ( -- Laravel Sanctum-compatible
  id              BIGSERIAL PRIMARY KEY,
  tokenable_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  name            VARCHAR(100) NOT NULL,
  token_hash      VARCHAR(64) NOT NULL UNIQUE,
  abilities       TEXT,
  last_used_at    TIMESTAMPTZ,
  expires_at      TIMESTAMPTZ,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ---------- GOVERNORATES / DISTRICTS ----------
CREATE TABLE governorates (
  id    SERIAL PRIMARY KEY,
  name_ckb VARCHAR(100) NOT NULL,
  name_ar  VARCHAR(100),
  name_en  VARCHAR(100) NOT NULL
);

CREATE TABLE districts (
  id              SERIAL PRIMARY KEY,
  governorate_id  INT NOT NULL REFERENCES governorates(id),
  name_ckb VARCHAR(100) NOT NULL,
  name_ar  VARCHAR(100),
  name_en  VARCHAR(100) NOT NULL
);

-- ---------- LOCATIONS (core GIS table) ----------
CREATE TABLE locations (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  category        location_category NOT NULL,
  governorate_id  INT REFERENCES governorates(id),
  district_id     INT REFERENCES districts(id),
  name_ckb        VARCHAR(200) NOT NULL,
  name_ar         VARCHAR(200),
  name_en         VARCHAR(200),
  description_ckb TEXT,
  description_en  TEXT,
  geom            geography(Point, 4326) NOT NULL, -- lat/lng replaced by a real spatial column
  elevation_meters INT,
  is_verified     BOOLEAN NOT NULL DEFAULT FALSE, -- matches V8.1's "verify before publishing" note
  created_by      UUID REFERENCES users(id),
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_locations_geom ON locations USING GIST (geom);
CREATE INDEX idx_locations_category ON locations (category);
CREATE INDEX idx_locations_name_trgm ON locations USING GIN (name_ckb gin_trgm_ops);

-- ---------- TRAILS (hiking / 4x4 / climbing) ----------
CREATE TABLE trails (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  location_id     UUID REFERENCES locations(id),
  name_ckb        VARCHAR(200) NOT NULL,
  difficulty      VARCHAR(20) NOT NULL DEFAULT 'moderate', -- easy/moderate/hard
  distance_km     NUMERIC(6,2),
  elevation_gain_m INT,
  route           geography(LineString, 4326), -- the GPX/GeoJSON track lives here natively
  waypoints       JSONB, -- named points of interest along the trail
  created_by      UUID REFERENCES users(id),
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_trails_route ON trails USING GIST (route);

-- ---------- MEDIA (images/video/360/audio for any entity) ----------
CREATE TABLE media (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  mediable_type   VARCHAR(50) NOT NULL, -- polymorphic: 'location' | 'trail' | 'accommodation' | ...
  mediable_id     UUID NOT NULL,
  type            VARCHAR(20) NOT NULL, -- image|video|360|audio|gpx
  storage_key     VARCHAR(500) NOT NULL, -- S3/MinIO object key, not a local path
  caption         VARCHAR(255),
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_media_mediable ON media (mediable_type, mediable_id);

-- ---------- ACCOMMODATIONS ----------
CREATE TABLE accommodations (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  owner_id        UUID REFERENCES users(id),
  type            VARCHAR(30) NOT NULL, -- hotel|chalet|guesthouse|campsite|eco_lodge
  name_ckb        VARCHAR(200) NOT NULL,
  geom            geography(Point, 4326) NOT NULL,
  price_per_night NUMERIC(10,2),
  amenities       JSONB, -- {wifi: true, parking: true, ...}
  is_active       BOOLEAN NOT NULL DEFAULT TRUE,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_accommodations_geom ON accommodations USING GIST (geom);

-- ---------- BOOKINGS + PAYMENTS ----------
CREATE TABLE bookings (
  id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id           UUID NOT NULL REFERENCES users(id),
  accommodation_id  UUID NOT NULL REFERENCES accommodations(id),
  check_in          DATE NOT NULL,
  check_out         DATE NOT NULL,
  guests            INT NOT NULL DEFAULT 1,
  status            booking_status NOT NULL DEFAULT 'pending',
  total_price       NUMERIC(10,2) NOT NULL,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE payments (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  booking_id      UUID NOT NULL REFERENCES bookings(id),
  method          payment_method NOT NULL,
  status          payment_status NOT NULL DEFAULT 'pending',
  amount          NUMERIC(10,2) NOT NULL,
  provider_ref    VARCHAR(120), -- FIB/Visa transaction id
  idempotency_key VARCHAR(64) NOT NULL UNIQUE, -- prevents double-charging on retry
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ---------- REVIEWS ----------
CREATE TABLE reviews (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id         UUID NOT NULL REFERENCES users(id),
  reviewable_type VARCHAR(50) NOT NULL, -- 'location' | 'accommodation' | 'trail'
  reviewable_id   UUID NOT NULL,
  rating          SMALLINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
  comment         TEXT,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_reviews_reviewable ON reviews (reviewable_type, reviewable_id);

-- ---------- EVENTS / FESTIVALS ----------
CREATE TABLE events (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  location_id     UUID REFERENCES locations(id),
  name_ckb        VARCHAR(200) NOT NULL,
  starts_at       TIMESTAMPTZ NOT NULL,
  ends_at         TIMESTAMPTZ,
  description_ckb TEXT,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ---------- OFFLINE PACKAGES (for the mobile app's offline-first sync) ----------
CREATE TABLE offline_packages (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  district_id     INT REFERENCES districts(id),
  name_ckb        VARCHAR(200) NOT NULL,
  bundle_storage_key VARCHAR(500) NOT NULL, -- pre-built tile+data bundle in object storage
  size_mb         INT,
  version         INT NOT NULL DEFAULT 1,
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ---------- FAVORITES ----------
CREATE TABLE favorites (
  user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  favoritable_type VARCHAR(50) NOT NULL,
  favoritable_id  UUID NOT NULL,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, favoritable_type, favoritable_id)
);

-- ---------- EXAMPLE SPATIAL QUERY ----------
-- Nearest 20 locations to a given point (e.g. the tourist's GPS position):
-- SELECT id, name_ckb, ST_Distance(geom, ST_MakePoint(:lng,:lat)::geography) AS distance_m
-- FROM locations
-- ORDER BY geom <-> ST_MakePoint(:lng,:lat)::geography
-- LIMIT 20;
