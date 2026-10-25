"""SudarX - Python port of the Flutter consumer + admin clients.

Consumer client  -> mobile web app (hero billboard, 3 shelves, details sheet,
                    player, search, downloads, my list, settings, profile)
Admin console    -> ingestion + catalog manager wired to the same database
"""
from __future__ import annotations

import os
from contextlib import asynccontextmanager
from datetime import datetime, timezone
from pathlib import Path

from fastapi import FastAPI, Form, Request
from fastapi.responses import HTMLResponse, RedirectResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates

from . import auth, db, media

BASE_DIR = Path(__file__).resolve().parent.parent
TEMPLATES = Jinja2Templates(directory=str(BASE_DIR / "templates"))

# The Flutter paywall listed ['Basic','Pro','Premium','VIP'] as required tiers for
# the trending row, so it never actually blocked anyone. Here the premium row is
# gated for real, and Basic accounts see the upgrade wall.
PREMIUM_SHELF = "trending"
PREMIUM_TIERS = ("Pro", "Premium", "VIP")


@asynccontextmanager
async def lifespan(app: FastAPI):
    db.init_db()
    yield


app = FastAPI(title="SudarX", lifespan=lifespan)
app.mount("/static", StaticFiles(directory=str(BASE_DIR / "static")), name="static")


# --------------------------------------------------------------------------- #
# helpers
# --------------------------------------------------------------------------- #
def current_user(request: Request) -> dict | None:
    return auth.user_for_token(request.cookies.get(auth.COOKIE_NAME))


def flash_url(target: str, msg: str | None = None) -> RedirectResponse:
    if msg:
        sep = "&" if "?" in target else "?"
        from urllib.parse import quote

        target = f"{target}{sep}msg={quote(msg)}"
    return RedirectResponse(target, status_code=303)


def render(request: Request, template: str, status_code: int = 200, **ctx) -> HTMLResponse:
    user = current_user(request)
    ctx.setdefault("user", user)
    ctx.setdefault("msg", request.query_params.get("msg"))
    ctx.setdefault("tiers", auth.TIERS)
    return TEMPLATES.TemplateResponse(request, template, ctx, status_code=status_code)


def require_user(request: Request):
    user = current_user(request)
    if not user:
        return None, RedirectResponse("/login?msg=" + "Please sign in to continue.", status_code=303)
    return user, None


def serialize(title: dict) -> dict:
    """Same document shape the Dart screens consumed from Firestore."""
    return {
        "title": title["title"],
        "subtitle": title["subtitle"],
        "stream_url": title["stream_url"],
        "image_url": title["image_url"],
        "duration": title["duration"],
        "year": title["year"],
        "genre": title["genre"],
        "director": title["director"],
        "cast": title["cast_list"],
        "studio": title["studio"],
    }


# --------------------------------------------------------------------------- #
# auth
# --------------------------------------------------------------------------- #
@app.get("/login", response_class=HTMLResponse)
def login_page(request: Request):
    if current_user(request):
        return RedirectResponse("/", status_code=303)
    return render(request, "login.html")


@app.post("/login")
def login_submit(request: Request, email: str = Form(""), password: str = Form("")):
    email = email.strip().lower()
    if not email or not password:
        return flash_url("/login", "Please enter both email and password.")
    user = auth.find_user(email)
    if not user or not auth.verify_password(password, user["password_hash"]):
        return flash_url("/login", "Auth Failed: invalid email or password.")
    token = auth.create_session(user["id"])
    target = "/admin" if user["is_admin"] else "/"
    resp = flash_url(target, f"Welcome back, {user['email']}")
    resp.set_cookie(auth.COOKIE_NAME, token, httponly=True, samesite="lax", max_age=60 * 60 * 24 * 30)
    return resp


@app.post("/signup")
def signup_submit(request: Request, email: str = Form(""), password: str = Form("")):
    email = email.strip().lower()
    if not email or not password:
        return flash_url("/login", "Please enter both email and password.")
    if len(password) < 6:
        return flash_url("/login", "Password must be at least 6 characters.")
    if auth.find_user(email):
        return flash_url("/login", "That email is already registered.")
    user_id = auth.create_user(email, password, tier="Basic")
    token = auth.create_session(user_id)
    resp = flash_url("/", "Account created. Your tier is Basic.")
    resp.set_cookie(auth.COOKIE_NAME, token, httponly=True, samesite="lax", max_age=60 * 60 * 24 * 30)
    return resp


@app.post("/reset")
def reset_password(request: Request, email: str = Form("")):
    email = email.strip().lower()
    if not email:
        return flash_url("/login", "Please enter your email to reset password.")
    # No mail transport in the port; report what the backend would do.
    return flash_url("/login", f"Password reset link would be sent to {email}.")


@app.get("/logout")
def logout(request: Request):
    auth.destroy_session(request.cookies.get(auth.COOKIE_NAME))
    resp = flash_url("/login", "Signed out.")
    resp.delete_cookie(auth.COOKIE_NAME)
    return resp


# --------------------------------------------------------------------------- #
# consumer
# --------------------------------------------------------------------------- #
@app.get("/", response_class=HTMLResponse)
def home(request: Request):
    user, redirect = require_user(request)
    if redirect:
        return redirect
    shelves = [
        {"key": "trending", "label": "Trending Now", "is_premium": True},
        {"key": "originals", "label": "SudarX Originals", "is_premium": False},
        {"key": "movies", "label": "Blockbuster Movies", "is_premium": False},
    ]
    for shelf in shelves:
        shelf["entries"] = db.titles_for_shelf(shelf["key"])
    return render(
        request,
        "home.html",
        hero=db.latest_hero(),
        shelves=shelves,
        my_list_ids=mylist_ids(user["id"]),
    )


@app.get("/search", response_class=HTMLResponse)
def search(request: Request, q: str = ""):
    user, redirect = require_user(request)
    if redirect:
        return redirect
    q = q.strip()
    # The Dart search only read the `movies` collection; here every shelf is
    # searchable, which is what the UI text promised.
    if q:
        pattern = f"%{q.lower()}%"
        rows = db.query(
            f"""SELECT * FROM titles
                WHERE ({db.visible_clause()})
                  AND (lower(title) LIKE ? OR lower(genre) LIKE ? OR lower(subtitle) LIKE ?)
                ORDER BY datetime(created_at) DESC, id DESC""",
            (pattern, pattern, pattern),
        )
        results = [dict(r) for r in rows]
    else:
        results = []
        for shelf in db.SHELVES:
            results.extend(db.titles_for_shelf(shelf)[:4])
    return render(request, "search.html", q=q, results=results)


@app.get("/title/{title_id}", response_class=HTMLResponse)
def title_details(request: Request, title_id: int):
    user, redirect = require_user(request)
    if redirect:
        return redirect
    item = db.get_title(title_id)
    if not item or not db.is_visible(item):
        return flash_url("/", "That title is not available.")
    return render(
        request,
        "details.html",
        item=item,
        is_premium=item["shelf"] == PREMIUM_SHELF,
        in_list=is_in_table("my_list", user["id"], title_id),
        in_downloads=is_in_table("downloads", user["id"], title_id),
    )


@app.get("/watch/{title_id}", response_class=HTMLResponse)
def watch(request: Request, title_id: int):
    user, redirect = require_user(request)
    if redirect:
        return redirect
    item = db.get_title(title_id)
    if not item or not db.is_visible(item):
        return flash_url("/", "That title is not available.")
    required = PREMIUM_TIERS if item["shelf"] == PREMIUM_SHELF else auth.TIERS
    if not auth.tier_allows(user["subscription_tier"], required):
        return render(request, "paywall.html", item=item, required=list(required), status_code=402)
    record_session(user, item["title"])
    return render(
        request,
        "watch.html",
        page_title=item["title"],
        play_url=media.embed_url(item["stream_url"]),
        is_youtube=media.is_youtube(item["stream_url"]),
        back_url=f"/title/{title_id}",
        end_action=f"/watch/{title_id}/end",
        tier=user["subscription_tier"],
    )


@app.get("/watch-hero", response_class=HTMLResponse)
def watch_hero(request: Request):
    user, redirect = require_user(request)
    if redirect:
        return redirect
    hero = db.latest_hero()
    if not hero:
        return flash_url("/", "No billboard has been published yet.")
    record_session(user, hero["title"])
    return render(
        request,
        "watch.html",
        page_title=hero["title"],
        play_url=media.embed_url(hero["stream_url"]),
        is_youtube=media.is_youtube(hero["stream_url"]),
        back_url="/",
        end_action=None,
        tier=user["subscription_tier"],
    )


def record_session(user: dict, title: str) -> None:
    """active_sessions bookkeeping, as the Flutter player did on initState.

    The app deleted the doc in dispose(); a web page cannot reliably know when
    the tab closes, so entries refresh on re-open and are pruned after 2 hours.
    """
    db.execute("DELETE FROM active_sessions WHERE datetime(started_at) < datetime('now', '-2 hours')")
    existing = db.query_one(
        "SELECT id FROM active_sessions WHERE user_id = ? AND title = ?", (user["id"], title)
    )
    if existing:
        db.execute("UPDATE active_sessions SET started_at = ? WHERE id = ?", (db.now_iso(), existing["id"]))
    else:
        db.execute(
            "INSERT INTO active_sessions (user_id, email, title, tier, started_at) VALUES (?, ?, ?, ?, ?)",
            (user["id"], user["email"], title, user["subscription_tier"], db.now_iso()),
        )


@app.post("/watch/{title_id}/end")
def watch_end(request: Request, title_id: int):
    user = current_user(request)
    if not user:
        return RedirectResponse("/login", status_code=303)
    item = db.get_title(title_id)
    if item:
        db.execute("DELETE FROM active_sessions WHERE user_id = ? AND title = ?", (user["id"], item["title"]))
    return RedirectResponse("/", status_code=303)


# --------------------------------------------------------------------------- #
# library: my list + downloads
# --------------------------------------------------------------------------- #
TABLE_LABELS = {"my_list": "My List", "downloads": "Downloads"}
# /mylist and /my_list both address the same table in URLs.
TABLE_ALIASES = {"mylist": "my_list", "my_list": "my_list", "downloads": "downloads"}


def is_in_table(table: str, user_id: int, title_id: int) -> bool:
    return db.query_one(f"SELECT 1 FROM {table} WHERE user_id = ? AND title_id = ?", (user_id, title_id)) is not None


def library_items(table: str, user_id: int) -> list[dict]:
    rows = db.query(
        f"""SELECT t.* FROM {table} l JOIN titles t ON t.id = l.title_id
            WHERE l.user_id = ? ORDER BY datetime(l.created_at) DESC, t.id DESC""",
        (user_id,),
    )
    return [dict(r) for r in rows]


def mylist_ids(user_id: int) -> set[int]:
    return {r["title_id"] for r in db.query("SELECT title_id FROM my_list WHERE user_id = ?", (user_id,))}


@app.post("/title/{title_id}/{table}")
def library_add(request: Request, title_id: int, table: str):
    user, redirect = require_user(request)
    if redirect:
        return redirect
    table = TABLE_ALIASES.get(table, table)
    if table not in TABLE_LABELS:
        return flash_url("/", "Unknown list.")
    item = db.get_title(title_id)
    if not item:
        return flash_url("/", "Title not found.")
    if is_in_table(table, user["id"], title_id):
        return flash_url(f"/title/{title_id}", f"Already in {TABLE_LABELS[table]}")
    db.execute(
        f"INSERT INTO {table} (user_id, title_id, created_at) VALUES (?, ?, ?)",
        (user["id"], title_id, db.now_iso()),
    )
    saved = "Saved to My List!" if table == "my_list" else "Added to Downloads List"
    return flash_url(f"/title/{title_id}", saved)


@app.post("/{table}/{title_id}/remove")
def library_remove(request: Request, table: str, title_id: int):
    user, redirect = require_user(request)
    if redirect:
        return redirect
    table = TABLE_ALIASES.get(table, table)
    if table not in TABLE_LABELS:
        return flash_url("/", "Unknown list.")
    db.execute(f"DELETE FROM {table} WHERE user_id = ? AND title_id = ?", (user["id"], title_id))
    return flash_url(f"/{table.replace('_', '')}", f"Removed from {TABLE_LABELS[table]}")


@app.get("/mylist", response_class=HTMLResponse)
def my_list_page(request: Request):
    user, redirect = require_user(request)
    if redirect:
        return redirect
    return render(request, "library.html", heading="My List", empty="Nothing saved yet.", items=library_items("my_list", user["id"]), table="my_list", active="profile")


@app.get("/downloads", response_class=HTMLResponse)
def downloads_page(request: Request):
    user, redirect = require_user(request)
    if redirect:
        return redirect
    return render(request, "library.html", heading="Downloads", empty="No downloads on this device.", items=library_items("downloads", user["id"]), table="downloads", active="downloads")


# --------------------------------------------------------------------------- #
# profile / settings / account / help
# --------------------------------------------------------------------------- #
@app.get("/profile", response_class=HTMLResponse)
def profile(request: Request):
    user, redirect = require_user(request)
    if redirect:
        return redirect
    downloads = db.query_one("SELECT COUNT(*) c FROM downloads WHERE user_id = ?", (user["id"],))["c"]
    saved = db.query_one("SELECT COUNT(*) c FROM my_list WHERE user_id = ?", (user["id"],))["c"]
    return render(request, "profile.html", downloads=downloads, saved=saved, active="profile")


@app.get("/settings", response_class=HTMLResponse)
def settings(request: Request):
    user, redirect = require_user(request)
    if redirect:
        return redirect
    return render(request, "settings.html", active="profile")


@app.post("/settings")
def settings_save(
    request: Request,
    cellular_data: str = Form("Automatic"),
    download_quality: str = Form("Standard"),
):
    user, redirect = require_user(request)
    if redirect:
        return redirect
    db.execute(
        "UPDATE users SET cellular_data = ?, download_quality = ? WHERE id = ?",
        (cellular_data, download_quality, user["id"]),
    )
    return flash_url("/settings", "Preferences saved.")


@app.post("/profile/tier")
def change_tier(request: Request, tier: str = Form("Basic")):
    user, redirect = require_user(request)
    if redirect:
        return redirect
    if tier in auth.TIERS:
        db.execute("UPDATE users SET subscription_tier = ? WHERE id = ?", (tier, user["id"]))
    return flash_url("/profile", f"Plan switched to {tier}.")


@app.get("/account", response_class=HTMLResponse)
def account(request: Request):
    user, redirect = require_user(request)
    if redirect:
        return redirect
    return render(request, "account.html", active="profile")


@app.get("/help", response_class=HTMLResponse)
def help_page(request: Request):
    user, redirect = require_user(request)
    if redirect:
        return redirect
    return render(request, "help.html", active="profile")


# --------------------------------------------------------------------------- #
# admin console
# --------------------------------------------------------------------------- #
def require_admin(request: Request):
    user = current_user(request)
    if not user or not user["is_admin"]:
        return None, RedirectResponse("/admin/login?msg=" + "Administrative credentials required.", status_code=303)
    return user, None


@app.get("/admin/login", response_class=HTMLResponse)
def admin_login_page(request: Request):
    return render(request, "admin_login.html")


@app.post("/admin/login")
def admin_login(request: Request, email: str = Form(""), password: str = Form("")):
    email = email.strip().lower()
    if not email or not password:
        return flash_url("/admin/login", "Please enter your administrative credentials.")
    user = auth.find_user(email)
    if not user or not auth.verify_password(password, user["password_hash"]):
        return flash_url("/admin/login", "Authentication failed.")
    if email not in auth.APPROVED_ADMINS and not user["is_admin"]:
        return flash_url("/admin/login", "That account is not an approved administrator.")
    token = auth.create_session(user["id"])
    resp = flash_url("/admin", f"Console unlocked for {email}")
    resp.set_cookie(auth.COOKIE_NAME, token, httponly=True, samesite="lax", max_age=60 * 60 * 12)
    return resp


@app.get("/admin/logout")
def admin_logout(request: Request):
    auth.destroy_session(request.cookies.get(auth.COOKIE_NAME))
    resp = flash_url("/admin/login", "Console locked.")
    resp.delete_cookie(auth.COOKIE_NAME)
    return resp


def admin_context(user: dict, tab: str = "ingestion", edit_id: int | None = None) -> dict:
    shelves = []
    for shelf in (*db.SHELVES, "hero_banners"):
        if shelf == "hero_banners":
            rows = db.query("SELECT * FROM hero_banners ORDER BY datetime(created_at) DESC, id DESC")
        else:
            rows = db.query("SELECT * FROM titles WHERE shelf = ? ORDER BY datetime(created_at) DESC, id DESC", (shelf,))
        shelves.append({"key": shelf, "entries": [dict(r) for r in rows]})
    return {
        "tab": tab,
        "shelves": shelves,
        "edit": db.get_title(edit_id) if edit_id else None,
        "admin": user,
        "stats": {
            "titles": db.query_one("SELECT COUNT(*) c FROM titles")["c"],
            "heroes": db.query_one("SELECT COUNT(*) c FROM hero_banners")["c"],
            "sessions": db.query_one("SELECT COUNT(*) c FROM active_sessions")["c"],
            "users": db.query_one("SELECT COUNT(*) c FROM users")["c"],
        },
        "sessions": [dict(r) for r in db.query("SELECT * FROM active_sessions ORDER BY datetime(started_at) DESC LIMIT 8")],
        "db_file": os.path.basename(db.db_path()),
    }


def normalise_release(date_str: str) -> str | None:
    date_str = (date_str or "").strip()
    if not date_str:
        return None
    for fmt in ("%Y-%m-%d", "%Y-%m-%dT%H:%M", "%Y-%m-%d %H:%M"):
        try:
            return datetime.strptime(date_str, fmt).strftime("%Y-%m-%d %H:%M:%S")
        except ValueError:
            continue
    return None


@app.get("/admin", response_class=HTMLResponse)
def admin_dashboard(request: Request, tab: str = "ingestion", edit: int | None = None):
    user, redirect = require_admin(request)
    if redirect:
        return redirect
    return render(request, "admin.html", **admin_context(user, tab, edit))


@app.post("/admin/titles")
def admin_create_title(
    request: Request,
    shelf: str = Form("trending"),
    title: str = Form(""),
    subtitle: str = Form(""),
    stream_url: str = Form(""),
    image_url: str = Form(""),
    duration: str = Form(""),
    year: str = Form(""),
    genre: str = Form(""),
    director: str = Form(""),
    cast: str = Form(""),
    studio: str = Form(""),
    release_date: str = Form(""),
):
    user, redirect = require_admin(request)
    if redirect:
        return redirect
    title = title.strip()
    if not title:
        return flash_url("/admin", "Deployment halted: please supply a title entry.")
    if shelf not in db.SHELVES:
        shelf = "trending"
    stream_url = stream_url.strip()
    artwork = image_url.strip() or media.artwork_for(stream_url) or db.DEFAULT_MOVIE_IMAGE
    release = normalise_release(release_date)
    db.execute(
        """INSERT INTO titles
           (shelf, title, subtitle, stream_url, image_url, duration, year, genre,
            director, cast_list, studio, is_published, release_date, created_at)
           VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)""",
        (
            shelf,
            title,
            subtitle.strip() or "Premium Feature",
            stream_url,
            artwork,
            duration.strip() or "N/A",
            year.strip() or "2026",
            genre.strip() or "General",
            director.strip(),
            cast.strip(),
            studio.strip(),
            0 if release else 1,
            release,
            db.now_iso(),
        ),
    )
    msg = "Success: release queued in the temporal engine!" if release else "Success: content live!"
    return flash_url("/admin?tab=catalog", msg)


@app.post("/admin/titles/{title_id}/update")
def admin_update_title(
    request: Request,
    title_id: int,
    shelf: str = Form("trending"),
    title: str = Form(""),
    subtitle: str = Form(""),
    stream_url: str = Form(""),
    image_url: str = Form(""),
    duration: str = Form(""),
    year: str = Form(""),
    genre: str = Form(""),
    director: str = Form(""),
    cast: str = Form(""),
    studio: str = Form(""),
    release_date: str = Form(""),
):
    user, redirect = require_admin(request)
    if redirect:
        return redirect
    if not db.get_title(title_id):
        return flash_url("/admin", "Title not found.")
    stream_url = stream_url.strip()
    artwork = image_url.strip() or media.artwork_for(stream_url) or db.DEFAULT_MOVIE_IMAGE
    release = normalise_release(release_date)
    db.execute(
        """UPDATE titles SET shelf=?, title=?, subtitle=?, stream_url=?, image_url=?,
           duration=?, year=?, genre=?, director=?, cast_list=?, studio=?,
           is_published=?, release_date=? WHERE id=?""",
        (
            shelf if shelf in db.SHELVES else "trending",
            title.strip() or "Untitled Production",
            subtitle.strip() or "Premium Feature",
            stream_url,
            artwork,
            duration.strip() or "N/A",
            year.strip() or "2026",
            genre.strip() or "General",
            director.strip(),
            cast.strip(),
            studio.strip(),
            0 if release else 1,
            release,
            title_id,
        ),
    )
    return flash_url("/admin?tab=catalog", "Success: catalog document updated!")


@app.post("/admin/titles/{title_id}/delete")
def admin_delete_title(request: Request, title_id: int):
    user, redirect = require_admin(request)
    if redirect:
        return redirect
    db.execute("DELETE FROM titles WHERE id = ?", (title_id,))
    return flash_url("/admin?tab=catalog", "Title removed.")


@app.post("/admin/hero")
def admin_create_hero(
    request: Request,
    hero_title: str = Form(""),
    tagline: str = Form(""),
    network_tag: str = Form(""),
    stream_url: str = Form(""),
    image_url: str = Form(""),
):
    user, redirect = require_admin(request)
    if redirect:
        return redirect
    hero_title = hero_title.strip()
    if not hero_title:
        return flash_url("/admin", "Hero title is required.")
    stream_url = stream_url.strip()
    artwork = image_url.strip() or media.artwork_for(stream_url) or db.DEFAULT_HERO_IMAGE
    db.execute(
        """INSERT INTO hero_banners (title, tagline, network_tag, stream_url, image_url, created_at)
           VALUES (?, ?, ?, ?, ?, ?)""",
        (
            hero_title,
            tagline.strip() or "Now Streaming",
            (network_tag.strip() or "EXCLUSIVE").upper(),
            stream_url,
            artwork,
            db.now_iso(),
        ),
    )
    return flash_url("/admin?tab=catalog", "Success: billboard live!")


@app.post("/admin/hero/{hero_id}/delete")
def admin_delete_hero(request: Request, hero_id: int):
    user, redirect = require_admin(request)
    if redirect:
        return redirect
    db.execute("DELETE FROM hero_banners WHERE id = ?", (hero_id,))
    return flash_url("/admin?tab=catalog", "Billboard removed.")


@app.get("/healthz")
def healthz():
    return {"status": "ok", "database": db.db_path()}
