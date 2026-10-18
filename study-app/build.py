#!/usr/bin/env python3
"""Build the single-file study app from src/ and content/*.json.

Writes:
  index.html          a complete page you can open directly in a browser
  dist/artifact.html  the same page without the document skeleton (for publishing as a claude.ai artifact)
"""
import json
import pathlib
import sys

ROOT = pathlib.Path(__file__).resolve().parent
CONTENT = ROOT / "content"


def load(name, default):
    p = CONTENT / name
    if not p.exists():
        print(f"warning: {name} missing", file=sys.stderr)
        return default
    return json.loads(p.read_text())


def main():
    days = []
    for n in range(1, 7):
        d = load(f"day{n}.json", None)
        if d:
            days.append(d)
    data = {
        "days": days,
        "mocks": load("mocks.json", {"exams": []}),
        "sheet": load("cheatsheet.json", {"sections": []}),
    }
    blob = json.dumps(data, ensure_ascii=False, separators=(",", ":")).replace("</", "<\\/")
    head = (ROOT / "src/head.html").read_text()
    css = (ROOT / "src/app.css").read_text()
    js = (ROOT / "src/app.js").read_text()
    body = (
        f"{head}<style>\n{css}</style>\n"
        '<div class="shell"><aside class="rail" id="rail"></aside><main class="main" id="main"></main></div>\n'
        f"<script>window.STUDY_DATA = {blob};</script>\n<script>\n{js}</script>\n"
    )
    (ROOT / "dist").mkdir(exist_ok=True)
    (ROOT / "dist/artifact.html").write_text(body)
    full = (
        '<!doctype html>\n<html lang="en">\n<head>\n<meta charset="utf-8">\n'
        '<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">\n'
        f"</head>\n<body>\n{body}</body>\n</html>\n"
    )
    (ROOT / "index.html").write_text(full)
    n_items = sum(len(d.get("flashcards", [])) + len(d.get("quiz", [])) for d in days)
    print(f"built index.html ({len(full) // 1024} KB): {len(days)} days, {n_items} review items, "
          f"{len(data['mocks'].get('exams', []))} mock exams, {len(data['sheet'].get('sections', []))} sheet sections")


if __name__ == "__main__":
    main()
