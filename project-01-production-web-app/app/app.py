"""
Notes API: the small-but-real application this project deploys.

  GET  /            HTML page: version, which app server answered, note count
  GET  /health      JSON used by the load balancer and by the rolling deploy
  GET  /api/notes   list notes (PostgreSQL)
  POST /api/notes   create a note  {"text": "..."}

Config comes from environment variables (written by Ansible into /opt/notes-api/.env):
  DATABASE_URL  postgresql://user:password@host:5432/dbname
  APP_VERSION   shown on the page so you can SEE a rolling deploy happen
"""
import os
import socket
from datetime import datetime, timezone

import psycopg2
from flask import Flask, jsonify, request

app = Flask(__name__)
DATABASE_URL = os.environ.get("DATABASE_URL", "")
APP_VERSION = os.environ.get("APP_VERSION", "dev")
HOSTNAME = socket.gethostname()


def db():
    return psycopg2.connect(DATABASE_URL)


def init_db():
    with db() as conn, conn.cursor() as cur:
        cur.execute(
            "CREATE TABLE IF NOT EXISTS notes ("
            "id SERIAL PRIMARY KEY, text TEXT NOT NULL, "
            "created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(), created_on TEXT NOT NULL)"
        )


@app.get("/health")
def health():
    try:
        with db() as conn, conn.cursor() as cur:
            cur.execute("SELECT 1")
        return jsonify(status="ok", version=APP_VERSION, server=HOSTNAME, db="ok")
    except Exception as exc:  # noqa: BLE001
        return jsonify(status="degraded", version=APP_VERSION, server=HOSTNAME, db=str(exc)), 503


@app.get("/api/notes")
def list_notes():
    with db() as conn, conn.cursor() as cur:
        cur.execute("SELECT id, text, created_at, created_on FROM notes ORDER BY id DESC LIMIT 50")
        rows = cur.fetchall()
    return jsonify([{"id": r[0], "text": r[1], "created_at": r[2].isoformat(), "created_on": r[3]} for r in rows])


@app.post("/api/notes")
def create_note():
    text = (request.get_json(silent=True) or {}).get("text", "").strip()
    if not text:
        return jsonify(error="text is required"), 400
    with db() as conn, conn.cursor() as cur:
        cur.execute("INSERT INTO notes (text, created_on) VALUES (%s, %s) RETURNING id", (text, HOSTNAME))
        new_id = cur.fetchone()[0]
    return jsonify(id=new_id, text=text, created_on=HOSTNAME), 201


@app.get("/")
def index():
    try:
        with db() as conn, conn.cursor() as cur:
            cur.execute("SELECT COUNT(*) FROM notes")
            count = cur.fetchone()[0]
        db_state = "connected"
    except Exception as exc:  # noqa: BLE001
        count, db_state = "?", f"error: {exc}"
    now = datetime.now(timezone.utc).strftime("%H:%M:%S UTC")
    return f"""<!doctype html>
<html><head><meta charset="utf-8"><title>Notes API · {APP_VERSION}</title>
<style>
 body{{font-family:system-ui,sans-serif;background:#0f172a;color:#e2e8f0;display:grid;place-items:center;min-height:100vh;margin:0}}
 .card{{background:#1e293b;border-radius:18px;padding:36px 44px;box-shadow:0 20px 60px rgba(0,0,0,.4);min-width:420px}}
 h1{{margin:0 0 6px;font-size:28px}} .v{{color:#4ade80;font-weight:800}} .k{{color:#94a3b8}}
 code{{background:#0f172a;padding:2px 8px;border-radius:6px}}
</style></head><body><div class="card">
<h1>Notes API <span class="v">v{APP_VERSION}</span></h1>
<p><span class="k">served by</span> <code>{HOSTNAME}</code> <span class="k">at</span> {now}</p>
<p><span class="k">database</span> {db_state} · <span class="k">notes stored</span> {count}</p>
<p class="k">Deployed by Ansible. Rolling updates with <code>serial: 1</code>, secrets from Ansible Vault.</p>
</div></body></html>"""


init_db()

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.environ.get("PORT", "8000")))
