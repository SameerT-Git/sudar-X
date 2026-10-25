"""Title parsing helpers shared by the admin console and the player."""
from __future__ import annotations

import re

YOUTUBE_RE = re.compile(
    r"^.*(youtu\.be/|v/|u/\w/|embed/|shorts/|watch\?v=|&v=)([^#&?]*).*",
    re.IGNORECASE,
)

# The Flutter admin fills artwork from the YouTube thumbnail as soon as a
# valid 11-character video id appears in the stream field.
YOUTUBE_ART = "https://img.youtube.com/vi/{video_id}/maxresdefault.jpg"


def youtube_id(url: str) -> str | None:
    if not url:
        return None
    match = YOUTUBE_RE.match(url.strip())
    if not match:
        return None
    video_id = match.group(2)
    return video_id if video_id and len(video_id) == 11 else None


def is_youtube(url: str) -> bool:
    low = (url or "").lower()
    return "youtube.com" in low or "youtu.be" in low


def artwork_for(url: str) -> str | None:
    video_id = youtube_id(url)
    return YOUTUBE_ART.format(video_id=video_id) if video_id else None


def embed_url(url: str) -> str:
    video_id = youtube_id(url)
    if video_id:
        return f"https://www.youtube.com/embed/{video_id}?rel=0&modestbranding=1"
    return url
