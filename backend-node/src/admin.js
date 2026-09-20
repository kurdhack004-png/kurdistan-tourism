'use strict';
/**
 * Admin system for Kurdistan Tourism.
 * Registered from server.js:  require('./admin')(app, db, {auth, admin, now, randomUUID, bcrypt})
 *
 *  - schema migrations (additive, safe to run on an existing database)
 *  - /api/admin/*   -> admin only (JWT with role=admin)
 *  - public read endpoints the mobile app can use: /api/hero, /api/ads, /api/emergency,
 *    /api/notifications, /api/settings/public
 *  - serves the dashboard at /admin and uploaded images at /uploads
 */
const fs = require('fs');
const path = require('path');
const express = require('express');

module.exports = function registerAdmin(app, db, { auth, admin, now, randomUUID, bcrypt }) {
  /* ------------------------------------------------------------------ migrations */
  const addCol = (table, col, def) => { try { db.exec(`ALTER TABLE ${table} ADD COLUMN ${col} ${def}`); } catch (_) { /* already exists */ } };

  addCol('users', 'banned', 'INTEGER DEFAULT 0');

  for (const c of ['name_ku', 'name_ar', 'description_ku', 'description_ar', 'city', 'video', 'directions']) addCol('locations', c, "TEXT DEFAULT ''");
  addCol('locations', 'images', "TEXT DEFAULT '[]'");
  addCol('locations', 'is_new', 'INTEGER DEFAULT 0');
  addCol('locations', 'is_featured', 'INTEGER DEFAULT 0');

  addCol('accommodations', 'type', "TEXT DEFAULT 'hotel'");
  for (const c of ['name_ku', 'name_ar', 'description', 'description_ku', 'description_ar', 'phone']) addCol('accommodations', c, "TEXT DEFAULT ''");
  addCol('accommodations', 'lat', 'REAL');
  addCol('accommodations', 'lng', 'REAL');
  addCol('accommodations', 'images', "TEXT DEFAULT '[]'");
  addCol('accommodations', 'active', 'INTEGER DEFAULT 1');
  addCol('accommodations', 'listing_until', 'TEXT');

  addCol('bookings', 'fee', 'REAL DEFAULT 0');

  db.exec(`
    CREATE TABLE IF NOT EXISTS settings(key TEXT PRIMARY KEY, value TEXT);
    CREATE TABLE IF NOT EXISTS ads(id TEXT PRIMARY KEY, title TEXT, company TEXT DEFAULT '', image TEXT DEFAULT '', link TEXT DEFAULT '', price REAL DEFAULT 0, starts_at TEXT, ends_at TEXT, active INTEGER DEFAULT 1, created_at TEXT);
    CREATE TABLE IF NOT EXISTS hero_images(id TEXT PRIMARY KEY, image TEXT, sort_order INTEGER DEFAULT 0, active INTEGER DEFAULT 1, created_at TEXT);
    CREATE TABLE IF NOT EXISTS emergency_contacts(id TEXT PRIMARY KEY, label TEXT, label_ku TEXT DEFAULT '', label_ar TEXT DEFAULT '', phone TEXT, sort_order INTEGER DEFAULT 0, created_at TEXT);
    CREATE TABLE IF NOT EXISTS notifications(id TEXT PRIMARY KEY, title TEXT, body TEXT DEFAULT '', created_at TEXT);
    CREATE TABLE IF NOT EXISTS listing_payments(id TEXT PRIMARY KEY, accommodation_id TEXT, amount REAL, months INTEGER DEFAULT 1, until TEXT, created_at TEXT);
  `);

  const DEFAULT_SETTINGS = { booking_fee: '10000', listing_fee: '30000', ad_price_24h: '10000', hero_interval_sec: '5', currency: 'IQD' };
  for (const [k, v] of Object.entries(DEFAULT_SETTINGS)) db.prepare('INSERT OR IGNORE INTO settings(key,value) VALUES(?,?)').run(k, v);
  const getSettings = () => Object.fromEntries(db.prepare('SELECT key,value FROM settings').all().map(r => [r.key, r.value]));
  const setting = (k) => Number(getSettings()[k] ?? DEFAULT_SETTINGS[k]);

  /* ------------------------------------------------------------------ helpers */
  const ok = (res, data) => res.json({ success: true, data });
  const fail = (res, code, message) => res.status(code).json({ success: false, message });
  const str = (v, max = 2000) => String(v ?? '').trim().slice(0, max);
  const URL_RE = /^(https?:\/\/[^\s]+|\/uploads\/[\w.\-]+)$/;
  const recalcRating = (locationId) => {
    const avg = db.prepare('SELECT AVG(rating) a FROM reviews WHERE location_id=?').get(locationId).a || 0;
    db.prepare('UPDATE locations SET rating=? WHERE id=?').run(Number(avg.toFixed(1)), locationId);
  };

  const CATEGORIES = ['mountain', 'lake', 'waterfall', 'cave', 'nature', 'park', 'heritage', 'cultural', 'other'];
  const ACCOMMODATION_TYPES = ['hotel', 'house', 'cabin', 'chalet'];

  // Column spec types: s=string n=number b=bool(0/1) e=enum u=url j=json array of urls d=date
  function parse(cols, body, partial) {
    body = body && typeof body === 'object' ? body : {};
    const v = {};
    for (const c of cols) {
      const has = Object.prototype.hasOwnProperty.call(body, c.k);
      if (partial && !has) continue;
      let x = has ? body[c.k] : undefined;
      switch (c.t) {
        case 's': { x = str(x, c.max || 500); if (c.req && !x) return { error: `${c.k} is required` }; v[c.k] = x; break; }
        case 'n': {
          if (x === undefined || x === null || x === '') { if (c.req) return { error: `${c.k} is required` }; v[c.k] = c.def ?? null; break; }
          const n = Number(x);
          if (!Number.isFinite(n) || (c.min !== undefined && n < c.min) || (c.max !== undefined && n > c.max)) return { error: `${c.k} is invalid` };
          v[c.k] = n; break;
        }
        case 'b': { v[c.k] = x === undefined ? (c.def ?? 0) : (x === true || x === 1 || x === '1' || x === 'true') ? 1 : 0; break; }
        case 'e': { if (x === undefined || x === '') x = c.def; if (!c.vals.includes(x)) return { error: `${c.k} must be one of: ${c.vals.join(', ')}` }; v[c.k] = x; break; }
        case 'u': { x = str(x, 2000); if (x && !URL_RE.test(x)) return { error: `${c.k} must be an http(s) link or an uploaded file` }; v[c.k] = x; break; }
        case 'j': {
          let a = x;
          if (typeof a === 'string') { try { a = JSON.parse(a); } catch { a = []; } }
          if (!Array.isArray(a)) a = [];
          v[c.k] = JSON.stringify(a.map(i => str(i, 2000)).filter(i => URL_RE.test(i)).slice(0, 20)); break;
        }
        case 'd': { if (!x) { v[c.k] = null; break; } const d = new Date(x); if (isNaN(d)) return { error: `${c.k} is not a valid date` }; v[c.k] = d.toISOString(); break; }
      }
    }
    return { v };
  }

  const outRow = (cols, row) => {
    const r = { ...row };
    for (const c of cols) if (c.t === 'j') { try { r[c.k] = JSON.parse(r[c.k] || '[]'); } catch { r[c.k] = []; } }
    return r;
  };

  /**
   * Generic list / create / update / delete for a table.
   * prep(values, {create, existing}) may mutate values and return an error string.
   */
  function crud(route, table, cols, { order = 'created_at DESC', prep, onDelete } = {}) {
    app.get(`/api/admin/${route}`, auth, admin, (req, res) => ok(res, db.prepare(`SELECT * FROM ${table} ORDER BY ${order}`).all().map(r => outRow(cols, r))));
    app.post(`/api/admin/${route}`, auth, admin, (req, res) => {
      const { v, error } = parse(cols, req.body, false);
      if (error) return fail(res, 422, error);
      const e = prep && prep(v, { create: true }); if (e) return fail(res, 422, e);
      const id = randomUUID();
      const keys = Object.keys(v);
      db.prepare(`INSERT INTO ${table}(id,${keys.join(',')},created_at) VALUES(?,${keys.map(() => '?').join(',')},?)`).run(id, ...keys.map(k => v[k]), now());
      res.status(201).json({ success: true, data: outRow(cols, db.prepare(`SELECT * FROM ${table} WHERE id=?`).get(id)) });
    });
    app.put(`/api/admin/${route}/:id`, auth, admin, (req, res) => {
      const existing = db.prepare(`SELECT * FROM ${table} WHERE id=?`).get(req.params.id);
      if (!existing) return fail(res, 404, 'Not found');
      const { v, error } = parse(cols, req.body, true);
      if (error) return fail(res, 422, error);
      const e = prep && prep(v, { create: false, existing }); if (e) return fail(res, 422, e);
      const keys = Object.keys(v);
      if (!keys.length) return fail(res, 422, 'Nothing to update');
      db.prepare(`UPDATE ${table} SET ${keys.map(k => `${k}=?`).join(',')} WHERE id=?`).run(...keys.map(k => v[k]), req.params.id);
      ok(res, outRow(cols, db.prepare(`SELECT * FROM ${table} WHERE id=?`).get(req.params.id)));
    });
    app.delete(`/api/admin/${route}/:id`, auth, admin, (req, res) => {
      const existing = db.prepare(`SELECT * FROM ${table} WHERE id=?`).get(req.params.id);
      if (!existing) return fail(res, 404, 'Not found');
      const e = onDelete && onDelete(existing); if (e) return fail(res, 409, e);
      db.prepare(`DELETE FROM ${table} WHERE id=?`).run(req.params.id);
      res.json({ success: true });
    });
  }

  /* ------------------------------------------------------------------ login brute-force guard */
  const WINDOW = 15 * 60 * 1000, MAX_FAILS = 10, fails = new Map();
  app.use('/api/auth/login', (req, res, next) => {
    if (req.method !== 'POST') return next();
    const k = req.ip, e = fails.get(k);
    if (e && Date.now() - e.t < WINDOW && e.n >= MAX_FAILS) return fail(res, 429, 'Too many failed attempts. Try again later.');
    res.on('finish', () => {
      if (res.statusCode === 401) {
        const c = fails.get(k);
        if (c && Date.now() - c.t < WINDOW) c.n++; else fails.set(k, { n: 1, t: Date.now() });
      } else if (res.statusCode === 200) fails.delete(k);
    });
    next();
  });
  setInterval(() => { for (const [k, e] of fails) if (Date.now() - e.t >= WINDOW) fails.delete(k); }, WINDOW).unref();

  /* ------------------------------------------------------------------ static: dashboard + uploads */
  const UPLOAD_DIR = process.env.UPLOAD_DIR ? path.resolve(process.env.UPLOAD_DIR) : path.join(__dirname, '..', 'uploads');
  fs.mkdirSync(UPLOAD_DIR, { recursive: true });
  app.use('/uploads', express.static(UPLOAD_DIR, { maxAge: '7d', setHeaders: r => r.setHeader('X-Content-Type-Options', 'nosniff') }));
  const DASH_DIR = process.env.ADMIN_DASHBOARD_DIR ? path.resolve(process.env.ADMIN_DASHBOARD_DIR) : path.join(__dirname, '..', '..', 'admin-dashboard');
  if (fs.existsSync(DASH_DIR)) app.use('/admin', express.static(DASH_DIR));

  /* ------------------------------------------------------------------ resources */
  const S = (k, max, req) => ({ k, t: 's', max, req });

  const LOCATION_COLS = [
    S('name', 200, true), S('name_ku', 200), S('name_ar', 200),
    S('description', 5000), S('description_ku', 5000), S('description_ar', 5000),
    { k: 'category', t: 'e', vals: CATEGORIES, def: 'other' }, S('city', 100),
    { k: 'lat', t: 'n', min: -90, max: 90, req: true }, { k: 'lng', t: 'n', min: -180, max: 180, req: true },
    { k: 'rating', t: 'n', min: 0, max: 5, def: 0 },
    { k: 'image', t: 'u' }, { k: 'images', t: 'j' }, { k: 'video', t: 'u' }, S('directions', 2000),
    { k: 'verified', t: 'b', def: 1 }, { k: 'is_new', t: 'b', def: 0 }, { k: 'is_featured', t: 'b', def: 0 },
  ];
  crud('locations', 'locations', LOCATION_COLS, {
    onDelete: (l) => { db.prepare('DELETE FROM favorites WHERE location_id=?').run(l.id); db.prepare('DELETE FROM reviews WHERE location_id=?').run(l.id); },
  });

  const ACCOMMODATION_COLS = [
    S('name', 200, true), S('name_ku', 200), S('name_ar', 200),
    { k: 'type', t: 'e', vals: ACCOMMODATION_TYPES, def: 'hotel' }, S('city', 100),
    { k: 'price', t: 'n', min: 0, req: true }, { k: 'rating', t: 'n', min: 0, max: 5, def: 0 },
    S('description', 5000), S('description_ku', 5000), S('description_ar', 5000),
    { k: 'lat', t: 'n', min: -90, max: 90 }, { k: 'lng', t: 'n', min: -180, max: 180 },
    { k: 'image', t: 'u' }, { k: 'images', t: 'j' }, S('phone', 50), { k: 'active', t: 'b', def: 1 },
  ];
  crud('accommodations', 'accommodations', ACCOMMODATION_COLS, {
    onDelete: (a) => (db.prepare('SELECT 1 FROM bookings WHERE accommodation_id=?').get(a.id) ? 'This place has bookings. Deactivate it instead of deleting.' : null),
  });

  // Listing fee: records a payment and extends the listing by 30 days per month paid.
  app.post('/api/admin/accommodations/:id/renew-listing', auth, admin, (req, res) => {
    const a = db.prepare('SELECT * FROM accommodations WHERE id=?').get(req.params.id);
    if (!a) return fail(res, 404, 'Not found');
    const months = Math.max(1, Math.min(12, parseInt(req.body?.months, 10) || 1));
    const base = a.listing_until && new Date(a.listing_until) > new Date() ? new Date(a.listing_until) : new Date();
    const until = new Date(base.getTime() + months * 30 * 86400000).toISOString();
    const amount = setting('listing_fee') * months;
    db.prepare('INSERT INTO listing_payments(id,accommodation_id,amount,months,until,created_at) VALUES(?,?,?,?,?,?)').run(randomUUID(), a.id, amount, months, until, now());
    db.prepare('UPDATE accommodations SET listing_until=?,active=1 WHERE id=?').run(until, a.id);
    ok(res, { listing_until: until, amount });
  });

  const ADS_COLS = [
    S('title', 200, true), S('company', 200), { k: 'image', t: 'u' }, { k: 'link', t: 'u' },
    { k: 'price', t: 'n', min: 0 }, { k: 'starts_at', t: 'd' }, { k: 'ends_at', t: 'd' }, { k: 'active', t: 'b', def: 1 },
  ];
  crud('ads', 'ads', ADS_COLS, {
    prep: (v, { create, existing }) => {
      if (create) {
        v.starts_at = v.starts_at || now();
        v.ends_at = v.ends_at || new Date(new Date(v.starts_at).getTime() + 24 * 3600000).toISOString();
        if (v.price === null || v.price === undefined) v.price = setting('ad_price_24h');
      }
      if (!create && (v.starts_at === null || v.ends_at === null)) return 'starts_at and ends_at cannot be empty';
      const s = v.starts_at ?? existing?.starts_at, e = v.ends_at ?? existing?.ends_at;
      if (s && e && new Date(e) <= new Date(s)) return 'ends_at must be after starts_at';
      return null;
    },
  });

  crud('hero', 'hero_images', [{ k: 'image', t: 'u', req: true }, { k: 'sort_order', t: 'n', def: 0 }, { k: 'active', t: 'b', def: 1 }], {
    order: 'sort_order ASC, created_at ASC',
    prep: (v) => (v.image === '' ? 'image is required' : null),
  });

  crud('emergency', 'emergency_contacts', [S('label', 100, true), S('label_ku', 100), S('label_ar', 100), S('phone', 50, true), { k: 'sort_order', t: 'n', def: 0 }], { order: 'sort_order ASC, created_at ASC' });

  // Notifications: create / list / delete (the app reads them from GET /api/notifications)
  const NOTIF_COLS = [S('title', 200, true), S('body', 2000)];
  app.get('/api/admin/notifications', auth, admin, (q, s) => ok(s, db.prepare('SELECT * FROM notifications ORDER BY created_at DESC').all()));
  app.post('/api/admin/notifications', auth, admin, (req, res) => {
    const { v, error } = parse(NOTIF_COLS, req.body, false);
    if (error) return fail(res, 422, error);
    const id = randomUUID();
    db.prepare('INSERT INTO notifications(id,title,body,created_at) VALUES(?,?,?,?)').run(id, v.title, v.body, now());
    res.status(201).json({ success: true, data: db.prepare('SELECT * FROM notifications WHERE id=?').get(id) });
  });
  app.delete('/api/admin/notifications/:id', auth, admin, (req, res) => { db.prepare('DELETE FROM notifications WHERE id=?').run(req.params.id); res.json({ success: true }); });

  /* ------------------------------------------------------------------ bookings */
  const BOOKING_STATUS = ['pending', 'confirmed', 'cancelled', 'completed'];
  const PAYMENT_STATUS = ['unpaid', 'paid', 'refunded'];
  app.get('/api/admin/bookings', auth, admin, (q, s) => ok(s, db.prepare(`
    SELECT b.*, u.name user_name, u.email user_email, a.name accommodation_name, a.type accommodation_type
    FROM bookings b LEFT JOIN users u ON u.id=b.user_id LEFT JOIN accommodations a ON a.id=b.accommodation_id
    ORDER BY b.created_at DESC`).all()));
  app.put('/api/admin/bookings/:id', auth, admin, (req, res) => {
    const b = db.prepare('SELECT id FROM bookings WHERE id=?').get(req.params.id);
    if (!b) return fail(res, 404, 'Not found');
    const { status, payment_status } = req.body || {};
    if (status !== undefined && !BOOKING_STATUS.includes(status)) return fail(res, 422, 'Invalid status');
    if (payment_status !== undefined && !PAYMENT_STATUS.includes(payment_status)) return fail(res, 422, 'Invalid payment_status');
    if (status !== undefined) db.prepare('UPDATE bookings SET status=? WHERE id=?').run(status, b.id);
    if (payment_status !== undefined) db.prepare('UPDATE bookings SET payment_status=? WHERE id=?').run(payment_status, b.id);
    res.json({ success: true });
  });

  /* ------------------------------------------------------------------ users */
  const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  app.get('/api/admin/users', auth, admin, (q, s) => ok(s, db.prepare(`
    SELECT u.id,u.name,u.email,u.role,COALESCE(u.banned,0) banned,u.created_at,
      (SELECT count(*) FROM bookings b WHERE b.user_id=u.id) bookings
    FROM users u ORDER BY u.created_at DESC`).all()));
  app.post('/api/admin/users', auth, admin, (req, res) => {
    const b = req.body || {}, name = str(b.name, 100), email = str(b.email, 200).toLowerCase(), role = b.role === 'admin' ? 'admin' : 'user';
    if (!name || !EMAIL_RE.test(email)) return fail(res, 422, 'Valid name and email are required');
    if (String(b.password || '').length < 8) return fail(res, 422, 'Password must be at least 8 characters');
    if (db.prepare('SELECT 1 FROM users WHERE lower(email)=?').get(email)) return fail(res, 409, 'Email already exists');
    const id = randomUUID();
    db.prepare('INSERT INTO users(id,name,email,password,role,created_at) VALUES(?,?,?,?,?,?)').run(id, name, email, bcrypt.hashSync(String(b.password), 10), role, now());
    res.status(201).json({ success: true, data: { id, name, email, role } });
  });
  app.put('/api/admin/users/:id', auth, admin, (req, res) => {
    const u = db.prepare('SELECT id FROM users WHERE id=?').get(req.params.id);
    if (!u) return fail(res, 404, 'Not found');
    const b = req.body || {};
    if (u.id === req.user.sub && (b.role !== undefined || b.banned !== undefined)) return fail(res, 409, 'You cannot change your own role or ban yourself');
    if (b.role !== undefined) { if (!['user', 'admin'].includes(b.role)) return fail(res, 422, 'Invalid role'); db.prepare('UPDATE users SET role=? WHERE id=?').run(b.role, u.id); }
    if (b.banned !== undefined) db.prepare('UPDATE users SET banned=? WHERE id=?').run(b.banned ? 1 : 0, u.id);
    if (b.name !== undefined) { const n = str(b.name, 100); if (!n) return fail(res, 422, 'Name is required'); db.prepare('UPDATE users SET name=? WHERE id=?').run(n, u.id); }
    res.json({ success: true });
  });
  app.post('/api/admin/users/:id/reset-password', auth, admin, (req, res) => {
    const pw = String(req.body?.password || '');
    if (pw.length < 8) return fail(res, 422, 'Password must be at least 8 characters');
    const r = db.prepare('UPDATE users SET password=? WHERE id=?').run(bcrypt.hashSync(pw, 10), req.params.id);
    r.changes ? res.json({ success: true }) : fail(res, 404, 'Not found');
  });
  app.delete('/api/admin/users/:id', auth, admin, (req, res) => {
    const u = db.prepare('SELECT id FROM users WHERE id=?').get(req.params.id);
    if (!u) return fail(res, 404, 'Not found');
    if (u.id === req.user.sub) return fail(res, 409, 'You cannot delete your own account');
    if (db.prepare('SELECT 1 FROM bookings WHERE user_id=?').get(u.id)) return fail(res, 409, 'This user has bookings. Ban the account instead of deleting it.');
    const locs = db.prepare('SELECT DISTINCT location_id FROM reviews WHERE user_id=?').all(u.id);
    db.prepare('DELETE FROM reviews WHERE user_id=?').run(u.id);
    db.prepare('DELETE FROM favorites WHERE user_id=?').run(u.id);
    db.prepare('DELETE FROM users WHERE id=?').run(u.id);
    locs.forEach(l => recalcRating(l.location_id));
    res.json({ success: true });
  });
  app.post('/api/admin/change-password', auth, admin, (req, res) => {
    const { current, password } = req.body || {};
    const u = db.prepare('SELECT * FROM users WHERE id=?').get(req.user.sub);
    if (!u || !bcrypt.compareSync(String(current || ''), u.password)) return fail(res, 401, 'Current password is wrong');
    if (String(password || '').length < 8) return fail(res, 422, 'New password must be at least 8 characters');
    db.prepare('UPDATE users SET password=? WHERE id=?').run(bcrypt.hashSync(String(password), 10), u.id);
    res.json({ success: true });
  });

  /* ------------------------------------------------------------------ reviews */
  app.get('/api/admin/reviews', auth, admin, (q, s) => ok(s, db.prepare(`
    SELECT r.*, u.name user_name, l.name location_name
    FROM reviews r LEFT JOIN users u ON u.id=r.user_id LEFT JOIN locations l ON l.id=r.location_id
    ORDER BY r.created_at DESC`).all()));
  app.delete('/api/admin/reviews/:id', auth, admin, (req, res) => {
    const r = db.prepare('SELECT * FROM reviews WHERE id=?').get(req.params.id);
    if (!r) return fail(res, 404, 'Not found');
    db.prepare('DELETE FROM reviews WHERE id=?').run(r.id);
    recalcRating(r.location_id);
    res.json({ success: true });
  });

  /* ------------------------------------------------------------------ settings */
  app.get('/api/admin/settings', auth, admin, (q, s) => ok(s, getSettings()));
  app.put('/api/admin/settings', auth, admin, (req, res) => {
    const b = req.body || {}, upd = {};
    for (const k of ['booking_fee', 'listing_fee', 'ad_price_24h']) if (b[k] !== undefined) { const n = Number(b[k]); if (!Number.isFinite(n) || n < 0) return fail(res, 422, `${k} is invalid`); upd[k] = String(n); }
    if (b.hero_interval_sec !== undefined) { const n = Number(b.hero_interval_sec); if (!Number.isFinite(n) || n < 1 || n > 60) return fail(res, 422, 'hero_interval_sec must be 1-60'); upd.hero_interval_sec = String(Math.round(n)); }
    if (b.currency !== undefined) { const c = str(b.currency, 8); if (!c) return fail(res, 422, 'currency is required'); upd.currency = c; }
    const st = db.prepare('INSERT INTO settings(key,value) VALUES(?,?) ON CONFLICT(key) DO UPDATE SET value=excluded.value');
    for (const [k, v] of Object.entries(upd)) st.run(k, v);
    ok(res, getSettings());
  });

  /* ------------------------------------------------------------------ stats */
  app.get('/api/admin/stats', auth, admin, (q, s) => {
    const one = (sql, ...a) => db.prepare(sql).get(...a);
    const bookingFees = one("SELECT COALESCE(sum(fee),0) v FROM bookings WHERE payment_status='paid'").v;
    const listings = one('SELECT COALESCE(sum(amount),0) v FROM listing_payments').v;
    const ads = one('SELECT COALESCE(sum(price),0) v FROM ads').v;
    ok(s, {
      users: one('SELECT count(*) c FROM users').c,
      locations: one('SELECT count(*) c FROM locations').c,
      accommodations: one('SELECT count(*) c FROM accommodations').c,
      bookings: one('SELECT count(*) c FROM bookings').c,
      reviews: one('SELECT count(*) c FROM reviews').c,
      active_ads: one('SELECT count(*) c FROM ads WHERE active=1 AND starts_at<=? AND ends_at>=?', now(), now()).c,
      revenue: one("SELECT COALESCE(sum(total),0) v FROM bookings WHERE payment_status='paid'").v, // total booking value paid by guests
      income: { booking_fees: bookingFees, listings, ads, total: bookingFees + listings + ads },
      currency: getSettings().currency,
      bookings_by_status: Object.fromEntries(db.prepare('SELECT status,count(*) c FROM bookings GROUP BY status').all().map(r => [r.status, r.c])),
      recent_bookings: db.prepare(`SELECT b.id,b.date,b.nights,b.total,b.status,b.payment_status,u.name user_name,a.name accommodation_name
        FROM bookings b LEFT JOIN users u ON u.id=b.user_id LEFT JOIN accommodations a ON a.id=b.accommodation_id ORDER BY b.created_at DESC LIMIT 5`).all(),
    });
  });

  /* ------------------------------------------------------------------ image upload (JSON/base64, no extra dependency) */
  const MAX_UPLOAD = 8 * 1024 * 1024;
  const sniff = (b) => {
    if (b.length > 12 && b[0] === 0xff && b[1] === 0xd8 && b[2] === 0xff) return 'jpg';
    if (b.length > 8 && b.slice(0, 8).equals(Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]))) return 'png';
    if (b.length > 6 && b.slice(0, 4).toString('latin1') === 'GIF8') return 'gif';
    if (b.length > 12 && b.slice(0, 4).toString('latin1') === 'RIFF' && b.slice(8, 12).toString('latin1') === 'WEBP') return 'webp';
    return null;
  };
  app.post('/api/admin/upload', auth, admin, (req, res) => {
    let data = String(req.body?.data || '');
    data = data.replace(/^data:[^;,]+;base64,/, '');
    const buf = Buffer.from(data, 'base64');
    if (!buf.length) return fail(res, 422, 'No file data');
    if (buf.length > MAX_UPLOAD) return fail(res, 413, 'Image is larger than 8 MB');
    const ext = sniff(buf);
    if (!ext) return fail(res, 415, 'Only JPG, PNG, GIF and WEBP images are allowed');
    const name = `${randomUUID()}.${ext}`;
    fs.writeFileSync(path.join(UPLOAD_DIR, name), buf);
    const base = (process.env.PUBLIC_URL || `${req.protocol}://${req.get('host')}`).replace(/\/$/, '');
    ok(res, { url: `${base}/uploads/${name}` });
  });

  /* ------------------------------------------------------------------ public endpoints for the mobile app */
  app.get('/api/hero', (q, s) => ok(s, {
    interval_sec: setting('hero_interval_sec') || 5,
    images: db.prepare('SELECT image FROM hero_images WHERE active=1 ORDER BY sort_order ASC, created_at ASC').all().map(r => r.image),
  }));
  app.get('/api/ads', (q, s) => ok(s, db.prepare('SELECT id,title,company,image,link,starts_at,ends_at FROM ads WHERE active=1 AND starts_at<=? AND ends_at>=? ORDER BY starts_at DESC').all(now(), now())));
  app.get('/api/emergency', (q, s) => ok(s, db.prepare('SELECT id,label,label_ku,label_ar,phone FROM emergency_contacts ORDER BY sort_order ASC, created_at ASC').all()));
  app.get('/api/notifications', (q, s) => ok(s, db.prepare('SELECT id,title,body,created_at FROM notifications ORDER BY created_at DESC LIMIT 50').all()));
  app.get('/api/settings/public', (q, s) => { const st = getSettings(); ok(s, { booking_fee: Number(st.booking_fee), currency: st.currency, hero_interval_sec: Number(st.hero_interval_sec) }); });
  app.get('/api/categories', (q, s) => ok(s, { locations: CATEGORIES, accommodations: ACCOMMODATION_TYPES }));
};
