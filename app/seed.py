"""Seed the port with demo accounts, shelves and a hero billboard."""
from __future__ import annotations

import os
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app import auth, db  # noqa: E402

MOVIES = [
    # shelf, title, subtitle, stream_url, image, duration, year, genre, director, cast, studio
    (
        "trending",
        "Nightfall Protocol",
        "A black-site analyst has 12 hours to prove the leak came from inside.",
        "/static/media/demo-1.mp4",
        "https://images.unsplash.com/photo-1478720568477-152d9b164e26?w=600",
        "1h 58m",
        "2026",
        "Thriller",
        "Anya Kriel",
        "R. Maharjan, S. Iyer, D. Okafor",
        "SudarX Studios",
    ),
    (
        "trending",
        "Kathmandu Run",
        "Two couriers race a monsoon across the valley with a package nobody should open.",
        "/static/media/demo-2.mp4",
        "https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=600",
        "2h 06m",
        "2026",
        "Action",
        "Bikash Shrestha",
        "P. Gurung, A. Tamang, N. Rai",
        "Himal Cine",
    ),
    (
        "originals",
        "The Quiet Ledger",
        "A forensic accountant unravels a cooperative bank built on borrowed names.",
        "/static/media/demo-3.mp4",
        "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=600",
        "48m",
        "2026",
        "Drama",
        "Mira Joshi",
        "K. Basnet, L. Chen",
        "SudarX Originals",
    ),
    (
        "originals",
        "Signal Hill",
        "A radio engineer starts hearing tomorrow's broadcast on an abandoned frequency.",
        "https://www.youtube.com/watch?v=aqz-KE-bpKQ",
        "https://img.youtube.com/vi/aqz-KE-bpKQ/maxresdefault.jpg",
        "1h 12m",
        "2025",
        "Sci-Fi",
        "Dawa Sherpa",
        "T. Watanabe, R. Khadka",
        "SudarX Originals",
    ),
    (
        "movies",
        "Big Buck Bunny",
        "The open-source classic: a giant rabbit settles a score with three rodents.",
        "/static/media/demo-4.mp4",
        "https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=600",
        "9m",
        "2008",
        "Animation",
        "Sacha Goedegebure",
        "Blender Foundation",
        "Blender",
    ),
    (
        "movies",
        "Elephants Dream",
        "Two men wander a machine world that keeps rebuilding itself around them.",
        "/static/media/demo-2.mp4",
        "https://images.unsplash.com/photo-1536440136628-849c177e76a1?w=600",
        "11m",
        "2006",
        "Animation",
        "Bassam Kurdali",
        "Orange Open Movie",
        "Blender",
    ),
    (
        "movies",
        "Sintel",
        "A lone hunter crosses a desert to find the dragon she raised.",
        "/static/media/demo-1.mp4",
        "https://images.unsplash.com/photo-1440404653325-ab127d49abc1?w=600",
        "15m",
        "2010",
        "Fantasy",
        "Colin Levy",
        "Durian Open Movie",
        "Blender",
    ),
]

HEROES = [
    (
        "Nightfall Protocol",
        "Every hour the leak gets closer to the top floor. Streaming now.",
        "EXCLUSIVE",
        "/static/media/demo-1.mp4",
        "https://images.unsplash.com/photo-1478720568477-152d9b164e26?w=1400",
    ),
]

ACCOUNTS = [
    ("viewer@sudarx.com", "Viewer@123", "Basic", False),
    ("pro@sudarx.com", "Pro@12345", "Pro", False),
    ("admin@sudarx.com", "Admin@123", "VIP", True),
]


def main() -> None:
    db.init_db()
    with db.connect() as conn:
        conn.execute("DELETE FROM my_list")
        conn.execute("DELETE FROM downloads")
        conn.execute("DELETE FROM active_sessions")
        conn.execute("DELETE FROM titles")
        conn.execute("DELETE FROM hero_banners")
        conn.execute("DELETE FROM sessions")
        conn.execute("DELETE FROM users")
        conn.execute(
            "DELETE FROM sqlite_sequence WHERE name IN "
            "('titles','hero_banners','users','active_sessions')"
        )
        conn.commit()

    for email, password, tier, is_admin in ACCOUNTS:
        auth.create_user(email, password, tier=tier, is_admin=is_admin)

    for row in MOVIES:
        db.execute(
            """INSERT INTO titles
               (shelf, title, subtitle, stream_url, image_url, duration, year, genre,
                director, cast_list, studio, is_published, release_date, created_at)
               VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 1, NULL, ?)""",
            (*row, db.now_iso()),
        )

    for hero in HEROES:
        db.execute(
            """INSERT INTO hero_banners (title, tagline, network_tag, stream_url, image_url, created_at)
               VALUES (?, ?, ?, ?, ?, ?)""",
            (*hero, db.now_iso()),
        )

    print(f"Seeded {db.query_one('SELECT COUNT(*) c FROM titles')['c']} titles, "
          f"{db.query_one('SELECT COUNT(*) c FROM hero_banners')['c']} hero banners, "
          f"{db.query_one('SELECT COUNT(*) c FROM users')['c']} accounts into {db.db_path()}")


if __name__ == "__main__":
    main()
