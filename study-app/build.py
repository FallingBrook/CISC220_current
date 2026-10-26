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


# Past-paper practice: one JSON file per paper in content/practice/, shown in this order.
PAPER_ORDER = ["m24", "q23a", "q23b", "f22", "f16", "f15", "f14"]
PAPER_NOTES = {"m24": "closest to your exam", "q23a": "with posted solutions", "q23b": "Bash parts only"}


def load_practice():
    papers, questions = [], []
    files = sorted((CONTENT / "practice").glob("*.json"),
                   key=lambda p: PAPER_ORDER.index(p.stem) if p.stem in PAPER_ORDER else 99)
    for p in files:
        d = json.loads(p.read_text())
        papers.append({"sourceId": d["sourceId"], "source": d["source"], "note": PAPER_NOTES.get(d["sourceId"], "")})
        for q in d["questions"]:
            questions.append(dict(q, sourceId=d["sourceId"]))
    return {"papers": papers, "questions": questions}


def main():
    days = []
    for p in sorted(CONTENT.glob("day*.json"), key=lambda p: int(p.stem[3:])):
        days.append(json.loads(p.read_text()))
    data = {
        "days": days,
        "mocks": load("mocks.json", {"exams": []}),
        "sheet": load("cheatsheet.json", {"sections": []}),
        "practice": load_practice(),
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
          f"{len(data['mocks'].get('exams', []))} mock exams, {len(data['sheet'].get('sections', []))} sheet sections, "
          f"{len(data['practice']['questions'])} practice questions from {len(data['practice']['papers'])} papers")


if __name__ == "__main__":
    main()
