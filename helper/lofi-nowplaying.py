#!/usr/bin/env python3
"""lofi-nowplaying — publish the track lofiradio.ru is currently playing.

The Icecast stream carries the song title in-band as `StreamTitle='Artist - Title'`
(one metadata block per `icy-metaint` audio bytes). Qt's multimedia backend does
not expose it, so this tiny sidecar reads it straight from the socket and serves
it as JSON on localhost for the Plasma widget.

Endpoints:
    GET /nowplaying.json   {"artist": ..., "title": ..., "station": ..., "updated": ...}
    GET /health            "ok"

Stdlib only, no dependencies.
"""
from __future__ import annotations

import json
import os
import re
import socket
import sys
import threading
import time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

STREAM_HOST = "live.lofiradio.ru"
STREAM_PORT = 8000
STREAM_PATH = "/lofi_mp3_128"
USER_AGENT = "lofi-radio-mini/1.0"

HTTP_HOST = "127.0.0.1"
HTTP_PORTS = (8731, 8732, 8733)

CONNECT_TIMEOUT = 10.0
READ_TIMEOUT = 20.0
TITLE_RE = re.compile(rb"StreamTitle='(.*?)';", re.S)

STATE_LOCK = threading.Lock()
STATE = {
    "raw": "",
    "artist": "",
    "title": "",
    "station": "LoFi Radio",
    "stream": "http://%s:%d%s" % (STREAM_HOST, STREAM_PORT, STREAM_PATH),
    "updated": 0,
    "connected": False,
}


def log(message: str) -> None:
    print("lofi-nowplaying: %s" % message, flush=True)


def parse_title(raw: str):
    """Split `Artist - Title` the way the widget displays it."""
    text = raw.strip()
    if not text or text.lower() in ("unknown", "null"):
        return "", ""
    parts = re.split(r"\s+[-\u2013\u2014|]\s+", text, maxsplit=1)
    if len(parts) == 2 and parts[0] and parts[1]:
        return parts[0].strip(), parts[1].strip()
    return "", text


def publish(raw: str) -> None:
    artist, title = parse_title(raw)
    with STATE_LOCK:
        STATE["raw"] = raw.strip()
        STATE["artist"] = artist
        STATE["title"] = title
        STATE["updated"] = int(time.time())
        STATE["connected"] = True


def snapshot() -> bytes:
    with STATE_LOCK:
        payload = dict(STATE)
    return json.dumps(payload, ensure_ascii=False).encode("utf-8")


def follow_stream() -> None:
    """Connect, read the icy headers, then publish every metadata block."""
    request = (
        "GET %s HTTP/1.1\r\n"
        "Host: %s:%d\r\n"
        "User-Agent: %s\r\n"
        "Icy-MetaData: 1\r\n"
        "Connection: keep-alive\r\n"
        "\r\n" % (STREAM_PATH, STREAM_HOST, STREAM_PORT, USER_AGENT)
    )
    with socket.create_connection((STREAM_HOST, STREAM_PORT), timeout=CONNECT_TIMEOUT) as sock:
        sock.settimeout(READ_TIMEOUT)
        sock.sendall(request.encode("ascii"))

        header = b""
        while b"\r\n\r\n" not in header:
            chunk = sock.recv(4096)
            if not chunk:
                raise ConnectionError("no response headers")
            header += chunk
        head, _, pending = header.partition(b"\r\n\r\n")

        meta_interval = 0
        for line in head.decode("utf-8", "replace").splitlines():
            if line.lower().startswith("icy-metaint:"):
                meta_interval = int(line.split(":", 1)[1].strip())
        if meta_interval <= 0:
            raise ConnectionError("server did not enable icy metadata")

        log("connected to the stream, icy-metaint=%d" % meta_interval)
        last_published = ""

        while True:
            while len(pending) < meta_interval + 1:
                chunk = sock.recv(32768)
                if not chunk:
                    raise ConnectionError("stream closed")
                pending += chunk

            pending = pending[meta_interval:]
            meta_len = pending[0] * 16
            pending = pending[1:]
            while len(pending) < meta_len:
                chunk = sock.recv(32768)
                if not chunk:
                    raise ConnectionError("stream closed")
            block, pending = pending[:meta_len], pending[meta_len:]

            match = TITLE_RE.search(block)
            if match:
                raw = match.group(1).decode("utf-8", "replace").strip()
                if raw and raw != last_published:
                    last_published = raw
                    publish(raw)
                    artist, title = parse_title(raw)
                    log("now playing: %s - %s" % (artist, title))


def stream_worker() -> None:
    delay = 2.0
    while True:
        try:
            follow_stream()
            delay = 2.0
        except Exception as exc:
            with STATE_LOCK:
                STATE["connected"] = False
            log("reconnecting after error: %s" % exc)
            time.sleep(delay)
            delay = min(delay * 2, 30.0)


class Handler(BaseHTTPRequestHandler):
    server_version = "lofi-nowplaying/1.0"

    def _send(self, body: bytes, content_type: str) -> None:
        self.send_response(200)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Cache-Control", "no-store")
        self.send_header("Access-Control-Allow-Origin", "*")
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self) -> None:
        path = self.path.split("?", 1)[0]
        if path in ("/nowplaying.json", "/", "/nowplaying"):
            self._send(snapshot(), "application/json; charset=utf-8")
        elif path == "/health":
            self._send(b"ok\n", "text/plain; charset=utf-8")
        else:
            self.send_error(404, "not found")

    def do_POST(self) -> None:
        path = self.path.split("?", 1)[0]
        if path == "/notify":
            content_length = int(self.headers.get("Content-Length", 0))
            body = self.rfile.read(content_length)
            try:
                data = json.loads(body.decode("utf-8"))
                title = data.get("title", "Lofi Radio")
                text = data.get("text", "")
                log("sending notification: %s - %s" % (title, text))
                # Отправка уведомления через notify-send
                import subprocess
                result = subprocess.run(
                    ["notify-send", "-a", "Lofi Radio", "-i", "audio-x-generic", title, text],
                    check=False,
                    capture_output=True,
                    text=True
                )
                if result.returncode == 0:
                    log("notification sent successfully")
                else:
                    log("notify-send failed: %s" % result.stderr)
                self._send(b'{"status": "ok"}', "application/json")
            except Exception as e:
                log("notify error: %s" % e)
                self.send_error(500, str(e))
        elif path == "/update":
            log("update requested")
            try:
                import subprocess
                import os
                
                log("running update.sh...")
                
                # Запускаем update.sh синхронно
                update_script = os.path.expanduser("~/.local/share/lofi-radio-mini/update.sh")
                
                # Проверяем что скрипт существует
                if not os.path.exists(update_script):
                    log("update.sh not found at: %s" % update_script)
                    self._send(b'{"status": "error", "message": "update.sh not found"}', "application/json")
                    return
                
                result = subprocess.run(
                    ["/bin/bash", update_script],
                    capture_output=True,
                    text=True,
                    timeout=180
                )
                
                log("update.sh exit code: %d" % result.returncode)
                if result.stdout:
                    log("update.sh stdout: %s" % result.stdout)
                if result.stderr:
                    log("update.sh stderr: %s" % result.stderr)
                
                if result.returncode == 0:
                    log("update completed successfully")
                    self._send(b'{"status": "ok", "message": "update completed"}', "application/json")
                else:
                    log("update failed with code %d" % result.returncode)
                    self._send(b'{"status": "error", "message": "update failed"}', "application/json")
                    
            except subprocess.TimeoutExpired:
                log("update.sh timed out after 180 seconds")
                self._send(b'{"status": "error", "message": "update timeout"}', "application/json")
            except Exception as e:
                log("update error: %s" % e)
                import traceback
                log(traceback.format_exc())
                self._send(b'{"status": "error", "message": "update exception"}', "application/json")
        else:
            self.send_error(404, "not found")

    def do_OPTIONS(self) -> None:
        self.send_response(204)
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Headers", "*")
        self.end_headers()

    def log_message(self, fmt, *args):
        pass


def start_http_server() -> ThreadingHTTPServer:
    last_error = None
    for port in HTTP_PORTS:
        try:
            server = ThreadingHTTPServer((HTTP_HOST, port), Handler)
            server.daemon_threads = True
            log("serving http://%s:%d/nowplaying.json" % (HTTP_HOST, port))
            return server
        except OSError as exc:
            last_error = exc
            log("port %d busy (%s)" % (port, exc))
    raise SystemExit("no free port in %s: %s" % (HTTP_PORTS, last_error))


def main() -> int:
    log("starting (pid %d)" % os.getpid())
    server = start_http_server()
    threading.Thread(target=stream_worker, name="stream", daemon=True).start()
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()
    return 0


if __name__ == "__main__":
    sys.exit(main())
