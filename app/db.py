"""SQLite storage layer for the SudarX Python port.

Mirrors the Firestore collections used by the Flutter clients:
  trending / originals / movies  -> titles (discriminated by `shelf`)
  hero_banners                   -> hero_banners
  active_sessions                -> active_sessions
  users                          -> users
Plus server-side my_list / downloads (the Flutter app kept these in
SharedPreferences on the device).
"""
from __future__ import annotations

import os
import sqlite3
from datetime import datetime, timezone
from typing import Any, Iterable

SHELVES = ("trending", "originals", "movies")

SCHEMA = """
CREATE TABLE IF NOT EXISTS users (
    id                INTEGER PRIMARY KEY AUTOINCREMENT,
    email             TEXT NOT NULL UNIQUE,
    password_hash     TEXT NOT NULL,
    subscription_tier TEXT NOT NULL DEFAULT 'Basic',
    is_admin          INTEGER NOT NULL DEFAULT 0,
    cellular_data     TEXT NOT NULL DEFAULT 'Automatic',
    download_quality  TEXT NOT NULL DEFAULT 'Standard',
    created_at        TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS sessions (
    token      TEXT PRIMARY KEY,
    user_id    INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS titles (
    id           INTEGER PRIMARY KEY AUTOINCREMENT,
    shelf        TEXT NOT NULL,
    title        TEXT NOT NULL,
    subtitle     TEXT NOT NULL DEFAULT 'Premium Feature',
    stream_url   TEXT NOT NULL DEFAULT '',
    image_url    TEXT NOT NULL DEFAULT '',
    duration     TEXT NOT NULL DEFAULT 'N/A',
    year         TEXT NOT NULL DEFAULT '2026',
    genre        TEXT NOT NULL DEFAULT 'General',
    director     TEXT NOT NULL DEFAULT '',
    cast_list    TEXT NOT NULL DEFAULT '',
    studio       TEXT NOT NULL DEFAULT '',
    is_published INTEGER NOT NULL DEFAULT 1,
    release_date TEXT,
    created_at   TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS hero_banners (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    title       TEXT NOT NULL,
    tagline     TEXT NOT NULL DEFAULT 'Now Streaming',
    network_tag TEXT NOT NULL DEFAULT 'EXCLUSIVE',
    stream_url  TEXT NOT NULL DEFAULT '',
    image_url   TEXT NOT NULL DEFAULT '',
    created_at  TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS active_sessions (
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id    INTEGER,
    email      TEXT NOT NULL,
    title      TEXT NOT NULL,
    tier       TEXT NOT NULL,
    started_at TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS my_list (
    user_id    INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title_id   INTEGER NOT NULL REFERENCES titles(id) ON DELETE CASCADE,
    created_at TEXT NOT NULL,
    PRIMARY KEY (user_id, title_id)
);

CREATE TABLE IF NOT EXISTS downloads (
    user_id    INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title_id   INTEGER NOT NULL REFERENCES titles(id) ON DELETE CASCADE,
    created_at TEXT NOT NULL,
    PRIMARY KEY (user_id, title_id)
);
"""

DEFAULT_MOVIE_IMAGE = "https://images.unsplash.com/photo-1536440136628-849c177e76a1?w=500"
DEFAULT_HERO_IMAGE = "https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=1200"


def db_path() -> str:
    return os.environ.get("SUDARX_DB", os.path.join(os.path.dirname(os.path.dirname(__file__)), "sudarx.db"))


def now_iso() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat()


def connect() -> sqlite3.Connection:
    conn = sqlite3.connect(db_path())
    conn.row_factory = sqlite3.Row
    conn.execute("PRAGMA foreign_keys = ON")
    return conn


def init_db() -> None:
    with connect() as conn:
        conn.executescript(SCHEMA)


def query(sql: str, params: Iterable[Any] = ()) -> list[sqlite3.Row]:
    with connect() as conn:
        return conn.execute(sql, tuple(params)).fetchall()


def query_one(sql: str, params: Iterable[Any] = ()) -> sqlite3.Row | None:
    with connect() as conn:
        return conn.execute(sql, tuple(params)).fetchone()


def execute(sql: str, params: Iterable[Any] = ()) -> int:
    """Run a write and return lastrowid (or rowcount when no insert)."""
    with connect() as conn:
        cur = conn.execute(sql, tuple(params))
        conn.commit()
        return cur.lastrowid if cur.lastrowid else cur.rowcount


def visible_clause(alias: str = "") -> str:
    """Rows that are live now.

    Flutter only ever wrote `is_published`, so a "scheduled" title was queued
    but nothing ever flipped it live. Here a queued title becomes visible the
    moment its release_date passes, which is what the admin UI promises.
    """
    p = f"{alias}." if alias else ""
    return (
        f"({p}is_published = 1 OR "
        f"({p}release_date IS NOT NULL AND {p}release_date <= datetime('now')))"
    )


def titles_for_shelf(shelf: str) -> list[dict]:
    rows = query(
        f"SELECT * FROM titles WHERE shelf = ? AND {visible_clause()} ORDER BY datetime(created_at) DESC, id DESC",
        (shelf,),
    )
    return [dict(r) for r in rows]


def latest_hero() -> dict | None:
    row = query_one("SELECT * FROM hero_banners ORDER BY datetime(created_at) DESC, id DESC LIMIT 1")
    return dict(row) if row else None


def get_title(title_id: int) -> dict | None:
    row = query_one("SELECT * FROM titles WHERE id = ?", (title_id,))
    return dict(row) if row else None


def is_visible(title: dict) -> bool:
    if title.get("is_published"):
        return True
    rd = title.get("release_date")
    if not rd:
        return False
    return rd.replace(" ", "T")[:19] <= datetime.now(timezone.utc).replace(microsecond=0).strftime("%Y-%m-%dT%H:%M:%S")
