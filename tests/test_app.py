"""Test harness: every test runs against a throwaway SQLite file."""
from __future__ import annotations

import os
import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from fastapi.testclient import TestClient  # noqa: E402

from app import auth, db  # noqa: E402
from app.main import app  # noqa: E402

SEED_TITLES = [
    ("trending", "Trending One", "premium plot", "https://cdn.example/t1.mp4", "1h 30m", "2026", "Thriller"),
    ("originals", "Original Signal", "signal plot", "https://www.youtube.com/watch?v=aqz-KE-bpKQ", "48m", "2026", "Sci-Fi"),
    ("movies", "Movie Night", "movie plot", "https://cdn.example/m1.mp4", "2h", "2025", "Drama"),
]


@pytest.fixture()
def client(tmp_path, monkeypatch):
    monkeypatch.setenv("SUDARX_DB", str(tmp_path / "test.db"))
    db.init_db()

    auth.create_user("viewer@sudarx.com", "Viewer@123", tier="Basic")
    auth.create_user("pro@sudarx.com", "Pro@12345", tier="Pro")
    auth.create_user("admin@sudarx.com", "Admin@123", tier="VIP", is_admin=True)
    auth.create_user("stranger@sudarx.com", "Stranger@1", tier="Premium")

    for shelf, title, subtitle, stream, duration, year, genre in SEED_TITLES:
        db.execute(
            """INSERT INTO titles (shelf, title, subtitle, stream_url, image_url, duration, year,
                                   genre, director, cast_list, studio, is_published, created_at)
               VALUES (?, ?, ?, ?, '', ?, ?, ?, 'Dir Person', 'Cast A, Cast B', 'Studio X', 1, ?)""",
            (shelf, title, subtitle, stream, duration, year, genre, db.now_iso()),
        )

    db.execute(
        """INSERT INTO hero_banners (title, tagline, network_tag, stream_url, image_url, created_at)
           VALUES ('Hero Feature', 'Big tagline', 'EXCLUSIVE', 'https://www.youtube.com/watch?v=aqz-KE-bpKQ', '', ?)""",
        (db.now_iso(),),
    )

    with TestClient(app) as test_client:
        yield test_client


def login(client: TestClient, email: str, password: str) -> None:
    response = client.post("/login", data={"email": email, "password": password})
    assert response.status_code == 200


def login_admin(client: TestClient) -> None:
    response = client.post("/admin/login", data={"email": "admin@sudarx.com", "password": "Admin@123"})
    assert response.status_code == 200


def title_id(title: str) -> int:
    return db.query_one("SELECT id FROM titles WHERE title = ?", (title,))["id"]


# --------------------------------------------------------------------------- #
# auth + storefront
# --------------------------------------------------------------------------- #
def test_anonymous_visitor_is_sent_to_login(client):
    response = client.get("/")
    assert response.status_code == 200
    assert "Please sign in to continue" in response.text
    assert "Sign In" in response.text


def test_signup_creates_basic_account(client):
    response = client.post("/signup", data={"email": "new@sudarx.com", "password": "secret123"})
    assert response.status_code == 200
    user = auth.find_user("new@sudarx.com")
    assert user is not None
    assert user["subscription_tier"] == "Basic"
    assert "SudarX" in response.text


def test_login_shows_hero_and_all_three_shelves(client):
    login(client, "viewer@sudarx.com", "Viewer@123")
    response = client.get("/")
    assert response.status_code == 200
    for expected in ("Hero Feature", "Big tagline", "Trending Now", "SudarX Originals", "Blockbuster Movies",
                     "Trending One", "Original Signal", "Movie Night"):
        assert expected in response.text


def test_bad_password_is_rejected(client):
    response = client.post("/login", data={"email": "viewer@sudarx.com", "password": "wrong"})
    assert "Auth Failed" in response.text


# --------------------------------------------------------------------------- #
# premium gate
# --------------------------------------------------------------------------- #
def test_basic_account_hits_paywall_on_trending(client):
    login(client, "viewer@sudarx.com", "Viewer@123")
    response = client.get(f"/watch/{title_id('Trending One')}")
    assert response.status_code == 402
    assert "is premium" in response.text
    assert "Switch to Pro" in response.text


def test_pro_account_can_watch_trending(client):
    login(client, "pro@sudarx.com", "Pro@12345")
    response = client.get(f"/watch/{title_id('Trending One')}")
    assert response.status_code == 200
    assert "<video" in response.text


def test_switching_plan_unlocks_the_premium_row(client):
    login(client, "viewer@sudarx.com", "Viewer@123")
    assert client.get(f"/watch/{title_id('Trending One')}").status_code == 402
    client.post("/profile/tier", data={"tier": "Pro"})
    assert client.get(f"/watch/{title_id('Trending One')}").status_code == 200


def test_free_shelf_plays_for_basic(client):
    login(client, "viewer@sudarx.com", "Viewer@123")
    response = client.get(f"/watch/{title_id('Movie Night')}")
    assert response.status_code == 200
    assert "cdn.example/m1.mp4" in response.text


def test_youtube_title_renders_iframe(client):
    login(client, "viewer@sudarx.com", "Viewer@123")
    response = client.get(f"/watch/{title_id('Original Signal')}")
    assert response.status_code == 200
    assert "youtube.com/embed/aqz-KE-bpKQ" in response.text


# --------------------------------------------------------------------------- #
# session accounting
# --------------------------------------------------------------------------- #
def test_watching_registers_and_ends_an_active_session(client):
    login(client, "viewer@sudarx.com", "Viewer@123")
    movie = title_id("Movie Night")
    client.get(f"/watch/{movie}")
    rows = db.query("SELECT * FROM active_sessions")
    assert len(rows) == 1
    assert rows[0]["title"] == "Movie Night"
    assert rows[0]["email"] == "viewer@sudarx.com"

    client.get(f"/watch/{movie}")  # re-open must not duplicate
    assert len(db.query("SELECT * FROM active_sessions")) == 1

    client.post(f"/watch/{movie}/end")
    assert db.query("SELECT * FROM active_sessions") == []


# --------------------------------------------------------------------------- #
# library
# --------------------------------------------------------------------------- #
def test_add_and_remove_from_my_list(client):
    login(client, "viewer@sudarx.com", "Viewer@123")
    movie = title_id("Movie Night")
    client.post(f"/title/{movie}/my_list")
    assert "Movie Night" in client.get("/mylist").text
    client.post(f"/mylist/{movie}/remove")
    assert "Nothing saved yet" in client.get("/mylist").text


def test_downloads_are_per_account(client):
    login(client, "viewer@sudarx.com", "Viewer@123")
    movie = title_id("Movie Night")
    client.post(f"/title/{movie}/downloads")
    assert "Movie Night" in client.get("/downloads").text

    client.get("/logout")
    login(client, "pro@sudarx.com", "Pro@12345")
    assert "No downloads on this device" in client.get("/downloads").text


def test_settings_persist(client):
    login(client, "viewer@sudarx.com", "Viewer@123")
    client.post("/settings", data={"cellular_data": "Wi-Fi Only", "download_quality": "High"})
    user = auth.find_user("viewer@sudarx.com")
    assert user["cellular_data"] == "Wi-Fi Only"
    assert user["download_quality"] == "High"


# --------------------------------------------------------------------------- #
# search
# --------------------------------------------------------------------------- #
def test_search_covers_every_shelf(client):
    login(client, "viewer@sudarx.com", "Viewer@123")
    assert "Original Signal" in client.get("/search?q=original").text
    assert "Trending One" in client.get("/search?q=thriller").text
    assert "No titles matched your search" in client.get("/search?q=zzzz").text


# --------------------------------------------------------------------------- #
# admin console
# --------------------------------------------------------------------------- #
def test_admin_console_requires_approved_admin(client):
    login(client, "viewer@sudarx.com", "Viewer@123")
    response = client.get("/admin")
    assert "Administrative credentials required" in response.text

    response = client.post("/admin/login", data={"email": "stranger@sudarx.com", "password": "Stranger@1"})
    assert "not an approved administrator" in response.text


def test_admin_can_publish_a_title_with_youtube_artwork(client):
    login_admin(client)
    response = client.post(
        "/admin/titles",
        data={"shelf": "originals", "title": "New Drop", "stream_url": "https://youtu.be/aqz-KE-bpKQ",
              "duration": "1h", "year": "2026", "genre": "Sci-Fi"},
    )
    assert response.status_code == 200
    row = db.query_one("SELECT * FROM titles WHERE title = 'New Drop'")
    assert row["image_url"] == "https://img.youtube.com/vi/aqz-KE-bpKQ/maxresdefault.jpg"
    assert row["is_published"] == 1
    assert row["subtitle"] == "Premium Feature"
    assert "New Drop" in response.text  # redirected to the catalog manager


def test_admin_requires_a_title(client):
    login_admin(client)
    response = client.post("/admin/titles", data={"shelf": "movies", "title": "   "})
    assert "Deployment halted" in response.text


def test_scheduled_title_stays_hidden_until_release_date(client):
    login_admin(client)
    client.post(
        "/admin/titles",
        data={"shelf": "movies", "title": "Next Month", "stream_url": "https://cdn.example/x.mp4",
              "release_date": "2999-01-01"},
    )
    row = db.query_one("SELECT * FROM titles WHERE title = 'Next Month'")
    assert row["is_published"] == 0
    assert row["release_date"].startswith("2999")
    assert "queued" in client.get("/admin?tab=catalog").text.lower()

    login(client, "pro@sudarx.com", "Pro@12345")
    assert "Next Month" not in client.get("/").text
    assert "Next Month" not in client.get("/search?q=next").text


def test_past_release_date_publishes_itself(client):
    login_admin(client)
    client.post(
        "/admin/titles",
        data={"shelf": "movies", "title": "Backdated", "stream_url": "https://cdn.example/y.mp4",
              "release_date": "2020-01-01"},
    )
    login(client, "pro@sudarx.com", "Pro@12345")
    assert "Backdated" in client.get("/").text


def test_admin_edits_and_deletes(client):
    login_admin(client)
    movie = title_id("Movie Night")
    client.post(
        f"/admin/titles/{movie}/update",
        data={"shelf": "originals", "title": "Movie Night Redux", "stream_url": "https://cdn.example/m1.mp4",
              "genre": "Comedy", "year": "2027"},
    )
    row = db.get_title(movie)
    assert row["title"] == "Movie Night Redux"
    assert row["shelf"] == "originals"
    assert row["genre"] == "Comedy"

    client.post(f"/admin/titles/{movie}/delete")
    assert db.get_title(movie) is None


def test_admin_publishes_and_deletes_a_billboard(client):
    login_admin(client)
    client.post(
        "/admin/hero",
        data={"hero_title": "Second Feature", "tagline": "", "network_tag": "", "stream_url": ""},
    )
    hero = db.latest_hero()
    assert hero["title"] == "Second Feature"
    assert hero["tagline"] == "Now Streaming"
    assert hero["network_tag"] == "EXCLUSIVE"
    assert hero["image_url"].startswith("https://images.unsplash.com/")

    client.post(f"/admin/hero/{hero['id']}/delete")
    assert "Second Feature" not in client.get("/admin?tab=catalog").text
