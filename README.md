# SudarX - Python port

The original repo held two loose Dart files (Flutter): a consumer streaming app
(`gemini-code-1792917332565.dart`) and a web admin console (`main_admin_copy.dart`),
both talking straight to Firebase (Auth, Firestore, Storage). Neither could be
built or run here: there is no Flutter SDK on this machine, no `pubspec.yaml`, no
Firebase project config, and three imported files are missing
(`shared/firebase_config.dart`, `controllers/advanced_player_controller.dart`,
`components/premium_paywall_gate.dart`).

So "run it" means this port: the same product, same screens, same colours, same
behaviour, rewritten in Python with a local database. It is a web app, so it runs
in a browser at phone width (the consumer side) and full width (the admin side).

## Run it

```bash
./run.sh                 # seeds demo data on first run, serves on 127.0.0.1:8801
```

Or by hand:

```bash
uv venv .venv
uv pip install --python .venv/bin/python fastapi "uvicorn[standard]" jinja2 python-multipart pytest httpx
.venv/bin/python -m app.seed
.venv/bin/python -m uvicorn app.main:app --port 8801
```

Open http://127.0.0.1:8801

| Account | Password | What it shows |
| --- | --- | --- |
| viewer@sudarx.com | Viewer@123 | Basic plan: trending row is locked behind the paywall |
| pro@sudarx.com | Pro@12345 | Pro plan: everything plays |
| admin@sudarx.com | Admin@123 | Admin console at /admin |

Tests: `.venv/bin/python -m pytest` (21 tests, all passing).

## What each side does

Consumer (`/`): hero billboard from the newest banner, then three shelves
(Trending Now, SudarX Originals, Blockbuster Movies), details sheet with
Director / Cast / Studio, player for YouTube embeds and direct MP4s with playback
speed, server-side search, My List, Downloads, App Settings, Profile, Account,
Help, sign up / sign in / reset.

Admin (`/admin`): login restricted to approved emails, Content Ingestion
(title metadata, shelf chips, YouTube link validation that auto-fills the
artwork, release scheduling, hero billboard form), Catalog Manager (every shelf,
edit / view / delete), plus active stream accounting.

## Layout

```
app/
  main.py     routes for consumer + admin
  db.py       SQLite schema and queries (Firestore collections -> tables)
  auth.py     scrypt password hashing, cookie sessions, tiers
  media.py    YouTube id parsing, artwork, embed urls
  seed.py     demo accounts, titles, billboard, local sample clips
templates/    Jinja pages (consumer shell + admin console)
static/       app.css, sample videos for offline playback
tests/        pytest suite against a throwaway database
```

Firestore collections map like this: `trending` / `originals` / `movies` -> one
`titles` table with a `shelf` column; `hero_banners`, `active_sessions`, `users`
keep their names. Downloads and My List were device-local in the Flutter build
(SharedPreferences); here they are per account in the database.

## Differences from the Dart source, and why

1. **The premium gate now actually gates.** The Flutter player passed
   `requiredTiers: ['Basic','Pro','Premium','VIP']`, which includes every tier, so
   nobody was ever blocked. Trending Now now requires Pro or above; Basic sees the
   paywall and can switch plan from Profile.
2. **Scheduled releases go live on their own.** The admin wrote
   `is_published: false` with a `release_date` and nothing ever flipped it. The
   storefront query now shows a title when `is_published = 1` or its release date
   has passed.
3. **Search covers every shelf.** The Dart search only read the `movies`
   collection, so trending and originals titles were invisible to search.
4. **Downloads / My List are per account, not per device.** SharedPreferences do
   not exist in a browser; a device-local store also meant the lists vanished with
   the app data.
5. **Stream URLs are not stored in Firebase.** No Firebase project was provided,
   so the port stores everything in `sudarx.db` (SQLite) and seeds sample media in
   `static/media/`. The Google sample-video bucket the Dart file referenced now
   returns 403, so the demo clips are generated locally and a YouTube id is kept
   on one title to exercise the embed path.
6. **Session accounting is pruned, not disposed.** The Flutter player deleted its
   `active_sessions` doc in `dispose()`; a browser cannot reliably know when a tab
   closes, so entries refresh on re-open, can be ended from the player, and are
   pruned after two hours. The admin now shows them, which the Dart build never
   did.
7. **No file upload.** Admin image and video upload went to Firebase Storage.
   Here artwork is a URL (auto-filled from YouTube) and video is a URL or a file
   under `static/media/`.

## Missing pieces to decide on

- Real authentication, email verification and password reset mail (reset is
  currently a no-op message, same as it looks in the app).
- Payments: switching plan is free and instant so the gate can be tested.
- Uploads for artwork and MP4s (needs an object store or a local upload endpoint).
- The Flutter app itself: it still exists only as these two files. Rebuilding it
  as a mobile client against this FastAPI backend is a separate job.
