#!/usr/bin/env bash
# Start the SudarX Python port: seeds demo data on first run, then serves it.
set -euo pipefail
cd "$(dirname "$0")"

if [ ! -d .venv ]; then
  uv venv .venv
  uv pip install --python .venv/bin/python -e . 2>/dev/null || uv pip install --python .venv/bin/python \
    fastapi "uvicorn[standard]" jinja2 python-multipart
fi

if [ ! -f sudarx.db ]; then
  .venv/bin/python -m app.seed
fi

exec .venv/bin/python -m uvicorn app.main:app --host "${HOST:-127.0.0.1}" --port "${PORT:-8801}" "$@"
