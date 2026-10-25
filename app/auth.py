"""Password hashing and cookie sessions (stdlib only)."""
from __future__ import annotations

import hashlib
import hmac
import secrets

from . import db

TIERS = ("Basic", "Pro", "Premium", "VIP")
# Mirrors the Flutter admin whitelist: only these accounts may open the console.
APPROVED_ADMINS = ("admin@sudarx.com", "biyas.123kc@gmail.com")
COOKIE_NAME = "sudarx_session"

_SCRYPT_N, _SCRYPT_R, _SCRYPT_P = 2**14, 8, 1


def hash_password(password: str) -> str:
    salt = secrets.token_bytes(16)
    digest = hashlib.scrypt(password.encode(), salt=salt, n=_SCRYPT_N, r=_SCRYPT_R, p=_SCRYPT_P, dklen=32)
    return f"scrypt${salt.hex()}${digest.hex()}"


def verify_password(password: str, stored: str) -> bool:
    try:
        scheme, salt_hex, digest_hex = stored.split("$")
    except ValueError:
        return False
    if scheme != "scrypt":
        return False
    digest = hashlib.scrypt(
        password.encode(), salt=bytes.fromhex(salt_hex), n=_SCRYPT_N, r=_SCRYPT_R, p=_SCRYPT_P, dklen=32
    )
    return hmac.compare_digest(digest.hex(), digest_hex)


def create_session(user_id: int) -> str:
    token = secrets.token_urlsafe(32)
    db.execute("INSERT INTO sessions (token, user_id, created_at) VALUES (?, ?, ?)", (token, user_id, db.now_iso()))
    return token


def user_for_token(token: str | None) -> dict | None:
    if not token:
        return None
    row = db.query_one(
        "SELECT u.* FROM sessions s JOIN users u ON u.id = s.user_id WHERE s.token = ?",
        (token,),
    )
    return dict(row) if row else None


def destroy_session(token: str | None) -> None:
    if token:
        db.execute("DELETE FROM sessions WHERE token = ?", (token,))


def create_user(email: str, password: str, tier: str = "Basic", is_admin: bool = False) -> int:
    return db.execute(
        "INSERT INTO users (email, password_hash, subscription_tier, is_admin, created_at) VALUES (?, ?, ?, ?, ?)",
        (email.strip().lower(), hash_password(password), tier, 1 if is_admin else 0, db.now_iso()),
    )


def find_user(email: str) -> dict | None:
    row = db.query_one("SELECT * FROM users WHERE email = ?", (email.strip().lower(),))
    return dict(row) if row else None


def tier_allows(tier: str, required: tuple[str, ...] | list[str]) -> bool:
    return tier in required
