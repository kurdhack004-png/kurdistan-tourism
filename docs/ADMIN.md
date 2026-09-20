# Admin system

## Access rules
* `/api/admin/*` requires a JWT of a user with `role = admin`. The role and the ban flag are re-checked in the database on every request,
  so demoting or banning a user takes effect immediately.
* Failed logins are rate limited (10 failures / 15 min / IP).
* Uploaded images are validated by content (JPG, PNG, GIF, WEBP only, max 8 MB) and stored in `backend-node/uploads` (`UPLOAD_DIR`).
  Set `PUBLIC_URL` in `.env` when the API is deployed so image links use the public address.

## Public endpoints for the mobile app (no login)
| Endpoint | Returns |
|---|---|
| `GET /api/hero` | `{interval_sec, images:[url,…]}` for the home slider |
| `GET /api/ads` | Advertisements that are active right now |
| `GET /api/emergency` | Emergency contact numbers (`label`, `label_ku`, `label_ar`, `phone`) |
| `GET /api/notifications` | Latest 50 notifications |
| `GET /api/settings/public` | `booking_fee`, `currency`, `hero_interval_sec` |
| `GET /api/categories` | Allowed place categories and accommodation types |
| `GET /api/accommodations?type=hotel\|house\|cabin\|chalet` | Active accommodation only |

Only accommodation (hotel, house, cabin, chalet) can be booked and paid. Places (mountain, lake, waterfall, cave, nature, park,
historical, cultural) are free and have no booking.

## Admin endpoints
`GET/POST /api/admin/{locations,accommodations,ads,hero,emergency}`, `PUT/DELETE /api/admin/<resource>/:id`,
`GET/POST/DELETE /api/admin/notifications`, `GET /api/admin/bookings`, `PUT /api/admin/bookings/:id`,
`GET/POST /api/admin/users`, `PUT/DELETE /api/admin/users/:id`, `POST /api/admin/users/:id/reset-password`,
`GET /api/admin/reviews`, `DELETE /api/admin/reviews/:id`, `GET/PUT /api/admin/settings`, `GET /api/admin/stats`,
`POST /api/admin/accommodations/:id/renew-listing`, `POST /api/admin/upload`, `POST /api/admin/change-password`.
