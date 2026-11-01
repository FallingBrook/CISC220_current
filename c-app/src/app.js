/* CISC220 C Sprint: a day-by-day C course and final-exam planner, built on retrieval practice and spaced repetition.
   All course content is in window.STUDY_DATA (inlined at build time from c-app/content/*.json). */
(function () {
  "use strict";

  const DATA = window.STUDY_DATA || { days: [], plan: { days: [] }, mocks: { exams: [] }, sheet: { sections: [] } };
  const PLAN = (DATA.plan && DATA.plan.days) || [];
  const EXAM_DATE = (DATA.plan && DATA.plan.exam) || "2026-12-10";
  const DAY_DATES = PLAN.map((p) => p.date);
  const LAST_DAY = DAY_DATES.length;
  const QUIZ_CAP = 15;
  const REPO = "https://github.com/FallingBrook/CISC220_current/blob/main/";
  const STORE_KEY = "cisc220-c-sprint-v1";
  const INTERVALS = [0, 1, 2, 4, 7]; // days until next review, by box

  // ---------------------------------------------------------------- state
  const blank = () => ({
    v: 1, srs: {}, steps: {}, topicsDone: {}, quizRuns: {}, write: {}, drills: {}, dumps: {}, mocks: {},
    topicStats: {}, reviewDone: {}, drafts: {}, dayOverride: null, theme: null, practice: { status: {}, papers: null }, a4: {},
  });
  let S = blank();
  try {
    const raw = localStorage.getItem(STORE_KEY);
    if (raw) S = Object.assign(blank(), JSON.parse(raw));
  } catch (e) { /* storage unavailable: work in memory */ }
  let saveTimer = null;
  function save() {
    clearTimeout(saveTimer);
    saveTimer = setTimeout(() => {
      try { localStorage.setItem(STORE_KEY, JSON.stringify(S)); } catch (e) { /* ignore */ }
    }, 150);
  }

  // ---------------------------------------------------------------- dates
  function localISO(d) {
    const z = (n) => String(n).padStart(2, "0");
    return d.getFullYear() + "-" + z(d.getMonth() + 1) + "-" + z(d.getDate());
  }
  function addDays(iso, n) {
    const [y, m, d] = iso.split("-").map(Number);
    return localISO(new Date(y, m - 1, d + n));
  }
  function diffDays(a, b) {
    const [y1, m1, d1] = a.split("-").map(Number);
    const [y2, m2, d2] = b.split("-").map(Number);
    return Math.round((new Date(y2, m2 - 1, d2) - new Date(y1, m1 - 1, d1)) / 86400000);
  }
  const today = () => localISO(new Date());
  function fmtDate(iso, opts) {
    const [y, m, d] = iso.split("-").map(Number);
    return new Date(y, m - 1, d).toLocaleDateString(undefined, opts || { weekday: "short", month: "short", day: "numeric" });
  }
  // Which plan day is today (1..LAST_DAY); 0 = before the plan starts, LAST_DAY + 1 = exam day or later.
  function calendarDay() {
    const t = today();
    if (t < DAY_DATES[0]) return 0;
    if (t > DAY_DATES[LAST_DAY - 1]) return LAST_DAY + 1;
    let n = 0;
    DAY_DATES.forEach((d, i) => { if (d <= t) n = i + 1; });
    return n;
  }
  function currentDay() {
    if (S.dayOverride) return S.dayOverride;
    const c = calendarDay();
    return c === 0 ? 1 : Math.min(c, LAST_DAY);
  }

  // ---------------------------------------------------------------- content index
  const dayData = {};
  const topics = {};
  const items = {}; // every flashcard and quiz item by id, with .kind and .day
  const writes = {};
  (DATA.days || []).forEach((d) => {
    dayData[d.day] = d;
    (d.topics || []).forEach((t) => { topics[t.id] = Object.assign({ day: d.day }, t); });
    (d.flashcards || []).forEach((c) => { items[c.id] = Object.assign({ kind: "card", day: d.day }, c); });
    (d.quiz || []).forEach((q) => { items[q.id] = Object.assign({ kind: "quiz", day: d.day }, q); });
    (d.write || []).forEach((w) => { writes[w.id] = Object.assign({ day: d.day }, w); });
  });
  const mocks = {};
  ((DATA.mocks && DATA.mocks.exams) || []).forEach((m) => { mocks[m.id] = m; });
  function topicForTag(tag) {
    return Object.values(topics).find((t) => (t.notebook || "").indexOf(tag) >= 0);
  }

  // ---------------------------------------------------------------- the plan
  const planOf = (n) => PLAN[n - 1] || { kind: "learn", title: "Day " + n };
  const A4_DAYS = { 3: "concat2.c", 4: "sin.c", 5: "sumones.c" };
  function dayTitle(n) { return (dayData[n] && dayData[n].title) || planOf(n).title; }
  function dayGoal(n) {
    if (dayData[n] && dayData[n].goal) return dayData[n].goal;
    const k = planOf(n).kind;
    if (k === "learn") return "Lessons for this day are on their way. Use the time for review: " + (planOf(n).notebooks || "") + ".";
    return {
      a4due: "Run the checker on all three files one last time, zip them, and submit on onQ before the deadline.",
      review: "No new material: catch up on due cards, retry everything you've missed, and rewrite your weakest code from a blank page.",
      practice: "Past final-exam questions, one at a time, marked by Claude, plus your spaced review.",
      eve: "A short review of your summary and missed cards, then stop early and sleep.",
      exam: "Exam day. A 15-minute skim of your summary sheet, then go.",
    }[k] || "";
  }

  function stepsFor(n) {
    const steps = [];
    const p = planOf(n);
    const d = dayData[n];
    const nt = d ? d.topics.length : 0;
    if (p.kind === "learn") {
      if (n > 1) steps.push({ key: "review", title: "Warm-up: spaced review", mins: 10, href: "review",
        desc: "Cards and questions due from earlier days. Recalling yesterday's material first is what makes it stick." });
      steps.push({ key: "learn", title: d ? "Learn: " + nt + " short lesson" + (nt === 1 ? "" : "s") : "Lessons coming soon", mins: 25, href: null, topics: !!d,
        desc: "Read actively: answer every orange Check box before you reveal it, and do the green steps at your keyboard." });
      if (d) {
        steps.push({ key: "cards", title: "Flashcards", mins: 8, href: "cards-" + n, desc: "One pass through today's cards. Rate yourself honestly; misses come back sooner." });
        steps.push({ key: "quiz", title: "Quick quiz", mins: 10, href: "quiz-" + n, desc: "Mostly \"what does this print?\" questions, mixed with a few from earlier days." });
        steps.push({ key: "write", title: "Write the code by hand", mins: 12, href: "write-" + n,
          desc: "A worked example, one with blanks, then one from a blank page. The final exam is handwritten, so practise on paper." });
        steps.push({ key: "drills", title: "Lab: compile and test", mins: 15, href: "lab-" + n, optional: true,
          desc: "Small programs you write, compile and test with the checker. Optional on busy days." });
      }
      if (A4_DAYS[n]) steps.push({ key: "a4", title: "Assignment 4: write " + A4_DAYS[n], mins: 30, href: "a4",
        desc: "Today's lessons cover everything " + A4_DAYS[n] + " needs. Follow the plan in the last lesson, then check your file with the A4 checker." });
    } else if (p.kind === "a4due") {
      steps.push({ key: "a4final", title: "Run the A4 checker on all three files", mins: 15, href: "a4", desc: "Every test should pass, with no compiler warnings." });
      steps.push({ key: "a4submit", title: "Zip and submit on onQ", mins: 10, href: "a4", desc: "Then download your submission from onQ and check it contains all three files." });
      steps.push({ key: "review", title: "Spaced review", mins: 15, href: "review", desc: "Due cards and questions from Days 1 to 5." });
    } else if (p.kind === "review") {
      steps.push({ key: "review", title: "Spaced review: everything due", mins: 20, href: "review", desc: "Clear the review queue." });
      steps.push({ key: "missed", title: "Everything you've missed", mins: 20, href: "review-missed", desc: "Only the cards and questions you've got wrong at least once." });
      steps.push({ key: "weak", title: "Weak spots: rewrite your weakest code", mins: 20, href: "weak", desc: "Re-read the lessons with the lowest accuracy and redo their writing exercises from a blank page." });
    } else if (p.kind === "practice") {
      steps.push({ key: "review", title: "Spaced review", mins: 15, href: "review", desc: "Keep the earlier material fresh." });
      steps.push({ key: "practice", title: "Past-exam practice", mins: 45, href: "practice",
        desc: "C questions from past finals on your professor's list, one at a time, marked by Claude." });
    } else if (p.kind === "eve") {
      steps.push({ key: "sheet", title: "Write a one-page summary from memory", mins: 20, href: "sheet", desc: "Then compare with the reference and fill the gaps." });
      steps.push({ key: "missed", title: "Cards you've missed", mins: 15, href: "review-missed", desc: "Then stop and sleep." });
    } else if (p.kind === "exam") {
      steps.push({ key: "sheet", title: "Skim your summary", mins: 15, href: "sheet", desc: "Nothing new today." });
      steps.push({ key: "exam", title: "Final exam", mins: 0, href: null, desc: "Read each question fully, write every part, and check your semicolons, braces and '\\0'." });
    }
    return steps;
  }

  function autoDone(n, key) {
    const d = dayData[n];
    switch (key) {
      case "learn": return !!d && d.topics.every((t) => S.topicsDone[t.id]);
      case "cards": return !!d && d.flashcards.length > 0 && d.flashcards.every((c) => S.srs[c.id]);
      case "quiz": return !!S.quizRuns["d" + n];
      case "write": return !!d && d.write.length > 0 && d.write.every((w) => S.write[w.id]);
      case "drills": return !!S.drills[n];
      case "a4": return !!(S.a4 && S.a4[A4_DAYS[n]]);
      case "a4final": return !!(S.a4 && S.a4["concat2.c"] && S.a4["sin.c"] && S.a4["sumones.c"]);
      case "a4submit": return !!(S.a4 && S.a4.submitted);
      case "practice": return PRACTICE.length > 0 && PRACTICE.every((q) => mastered(q.id));
      case "dump": return !!(S.dumps[n] && S.dumps[n].trim());
      case "review": return !!S.reviewDone[n === currentDay() ? today() : dateOfDay(n)];
      default: return false;
    }
  }
  function stepDone(n, key) {
    const m = S.steps[n + ":" + key];
    if (m === true) return true;
    if (m === false) return false;
    return autoDone(n, key);
  }
  function dayProgress(n) {
    const st = stepsFor(n).filter((s) => !s.optional && s.key !== "exam");
    const done = st.filter((s) => stepDone(n, s.key)).length;
    return st.length ? done / st.length : 0;
  }
  const dateOfDay = (n) => DAY_DATES[Math.min(n, LAST_DAY) - 1];

  // ---------------------------------------------------------------- spaced repetition
  function rate(id, grade) { // grade 0 again, 1 hard, 2 good, 3 easy
    const it = items[id];
    const s = S.srs[id] || { box: 0, due: today(), lapses: 0, reps: 0 };
    s.reps++;
    if (grade === 0) { s.box = 0; s.lapses++; s.due = today(); }
    else if (grade === 1) { s.box = Math.max(1, s.box); s.due = addDays(today(), 1); }
    else {
      s.box = Math.min(INTERVALS.length - 1, s.box + (grade === 3 ? 2 : 1));
      s.due = addDays(today(), INTERVALS[s.box]);
    }
    s.last = today();
    S.srs[id] = s;
    if (it && it.topic) {
      const ts = S.topicStats[it.topic] || { right: 0, wrong: 0 };
      if (grade >= 2) ts.right++; else ts.wrong++;
      S.topicStats[it.topic] = ts;
    }
    save();
  }
  function dueItems(kind) {
    const t = today();
    return Object.keys(S.srs).filter((id) => items[id] && (!kind || items[id].kind === kind) && S.srs[id].due <= t);
  }
  function missedItems() { return Object.keys(S.srs).filter((id) => items[id] && S.srs[id].lapses > 0); }
  function shuffle(a) {
    for (let i = a.length - 1; i > 0; i--) { const j = Math.floor(Math.random() * (i + 1)); [a[i], a[j]] = [a[j], a[i]]; }
    return a;
  }
  // Interleave: no two consecutive items from the same topic when avoidable.
  function interleave(ids) {
    const pool = shuffle(ids.slice());
    const out = [];
    while (pool.length) {
      const prev = out.length ? items[out[out.length - 1]].topic : null;
      let k = pool.findIndex((id) => items[id].topic !== prev);
      if (k < 0) k = 0;
      out.push(pool.splice(k, 1)[0]);
    }
    return out;
  }

  // ---------------------------------------------------------------- markdown
  const esc = (s) => String(s == null ? "" : s).replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;");
  function inline(s) {
    // Code spans become placeholders first so emphasis can wrap them (**`/`**) and never reaches inside them.
    const codes = [];
    const text = String(s).replace(/(`+)([\s\S]*?)\1/g, (_, ticks, inner) => {
      codes.push("<code>" + esc(inner.replace(/^ (.*\S.*) $/, "$1")) + "</code>");
      return "\u0000" + (codes.length - 1) + "\u0000";
    });
    let h = esc(text);
    h = h.replace(/\[([^\]]+)\]\((https?:\/\/[^)\s]+)\)/g, '<a href="$2" target="_blank" rel="noopener">$1</a>');
    h = h.replace(/\*\*(?=\S)([\s\S]+?)\*\*/g, "<strong>$1</strong>");
    h = h.replace(/(^|[\s(>])\*([^*\s][^*]*?)\*(?=[\s).,;:!?<]|$)/g, "$1<em>$2</em>");
    return h.replace(/\u0000(\d+)\u0000/g, (_, k) => codes[+k]);
  }
  const BASH_KW = new Set(["if", "then", "else", "elif", "fi", "for", "while", "until", "do", "done", "case", "esac", "in", "function", "return", "local", "exit", "break", "continue", "shift", "source", "declare", "unset", "readonly", "export"]);
  function hlLine(s) {
    let out = "", i = 0;
    const span = (c, t) => '<span class="' + c + '">' + esc(t) + "</span>";
    while (i < s.length) {
      const c = s[i];
      const rest = s.slice(i);
      if (c === "#" && (i === 0 || /\s/.test(s[i - 1]))) { out += span("c", rest); break; }
      if (c === "\\" && i + 1 < s.length) { out += esc(s.substr(i, 2)); i += 2; continue; }
      if (c === "'") {
        let j = s.indexOf("'", i + 1); if (j < 0) j = s.length - 1;
        out += span("s", s.slice(i, j + 1)); i = j + 1; continue;
      }
      if (c === '"') {
        let j = i + 1;
        while (j < s.length && s[j] !== '"') { if (s[j] === "\\") j++; j++; }
        out += span("s", s.slice(i, j + 1)); i = j + 1; continue;
      }
      if (c === "$") {
        const m = rest.match(/^\$(\{[^}]*\}|\(\([^)]*\)\)|[A-Za-z_][A-Za-z0-9_]*|[0-9#@*?$!-])/);
        if (m) { out += span("v", m[0]); i += m[0].length; continue; }
      }
      const w = rest.match(/^[A-Za-z_][A-Za-z0-9_]*/);
      if (w) {
        const prev = i === 0 ? "" : s[i - 1];
        const isKw = BASH_KW.has(w[0]) && !/[\w\-./]/.test(prev) && !/^[\w\-./=]/.test(s.slice(i + w[0].length));
        out += isKw ? span("k", w[0]) : esc(w[0]);
        i += w[0].length; continue;
      }
      out += esc(c); i++;
    }
    return out;
  }
  function codeBlock(code, caption) {
    const lines = String(code).replace(/\n$/, "").split("\n");
    const transcript = lines.some((l) => /^\$ /.test(l) || l === "$");
    const html = lines.map((l) => {
      if (transcript) {
        if (/^\$ /.test(l)) return '<span class="pr">$ </span>' + hlLine(l.slice(2));
        if (/^> /.test(l)) return '<span class="pr">&gt; </span>' + hlLine(l.slice(2));
        return '<span class="outp">' + esc(l) + "</span>";
      }
      return hlLine(l);
    }).join("\n");
    const pre = '<pre class="code"><code>' + html + "</code></pre>";
    return caption ? "<figure>" + pre + "<figcaption>" + inline(caption) + "</figcaption></figure>" : pre;
  }
  function md(src) {
    if (src == null) return "";
    const lines = String(src).replace(/\r/g, "").split("\n");
    const out = [];
    let i = 0;
    const isBlockStart = (l) => /^```/.test(l) || /^#{1,4} /.test(l) || /^\s*[-*] /.test(l) || /^\s*\d+\. /.test(l) || /^\|/.test(l);
    while (i < lines.length) {
      const l = lines[i];
      if (/^```/.test(l)) {
        const buf = []; i++;
        while (i < lines.length && !/^```/.test(lines[i])) buf.push(lines[i++]);
        i++;
        out.push(codeBlock(buf.join("\n")));
        continue;
      }
      const h = l.match(/^(#{1,4}) (.*)$/);
      if (h) { const lv = Math.min(4, h[1].length + 1); out.push("<h" + lv + ">" + inline(h[2]) + "</h" + lv + ">"); i++; continue; }
      if (/^\s*[-*] /.test(l) || /^\s*\d+\. /.test(l)) {
        const ordered = /^\s*\d+\. /.test(l);
        const re = ordered ? /^\s*\d+\. (.*)$/ : /^\s*[-*] (.*)$/;
        const lis = [];
        while (i < lines.length && (re.test(lines[i]) || (/^\s{2,}\S/.test(lines[i]) && lis.length))) {
          const m = lines[i].match(re);
          if (m) lis.push(m[1]); else lis[lis.length - 1] += " " + lines[i].trim();
          i++;
        }
        out.push((ordered ? "<ol>" : "<ul>") + lis.map((x) => "<li>" + inline(x) + "</li>").join("") + (ordered ? "</ol>" : "</ul>"));
        continue;
      }
      if (/^\|/.test(l) && i + 1 < lines.length && /^\|?\s*:?-{2,}/.test(lines[i + 1])) {
        const row = (r) => r.trim().replace(/^\|/, "").replace(/\|$/, "").split(/(?<!\\)\|/).map((c) => c.trim().replace(/\\\|/g, "|"));
        const head = row(l); i += 2;
        const body = [];
        while (i < lines.length && /^\|/.test(lines[i])) body.push(row(lines[i++]));
        out.push('<div class="tablewrap"><table><thead><tr>' + head.map((c) => "<th>" + inline(c) + "</th>").join("") + "</tr></thead><tbody>" +
          body.map((r) => "<tr>" + r.map((c) => "<td>" + inline(c) + "</td>").join("") + "</tr>").join("") + "</tbody></table></div>");
        continue;
      }
      if (!l.trim()) { i++; continue; }
      const buf = [];
      while (i < lines.length && lines[i].trim() && !(buf.length && isBlockStart(lines[i]))) buf.push(lines[i++]);
      out.push("<p>" + inline(buf.join("\n")).replace(/\n/g, "<br>") + "</p>");
    }
    return out.join("");
  }

  // ---------------------------------------------------------------- rendering helpers
  const $ = (sel, root) => (root || document).querySelector(sel);
  const $$ = (sel, root) => Array.from((root || document).querySelectorAll(sel));
  const main = () => $("#main");
  let session = null; // active flashcard / quiz session
  let timerHandle = null;

  function toast(msg) {
    const t = document.createElement("div");
    t.className = "toast"; t.textContent = msg; t.setAttribute("role", "status");
    document.body.appendChild(t);
    setTimeout(() => t.remove(), 2200);
  }
  function prioChip(p) {
    if (p === "start") return '<span class="chip accent">start here</span>';
    return p ?'<span class="chip ' + esc(p) + '">' + esc(p) + " priority</span>" : ""; }

  function renderRail() {
    const cd = calendarDay();
    const daysLeft = diffDays(today(), EXAM_DATE);
    const cur = currentDay();
    const due = dueItems().length;
    const route = location.hash.replace(/^#/, "") || "today";
    const on = (r) => (route === r ? " on" : "");
    let cdText;
    if (daysLeft > 1) cdText = "<big>" + daysLeft + " days</big>until the final exam";
    else if (daysLeft === 1) cdText = "<big>Tomorrow</big>is the final. Sleep well.";
    else if (daysLeft === 0) cdText = "<big>Today</big>is the final. You've got this.";
    else cdText = "<big>Done</big>the final is behind you.";
    let days = "";
    for (let n = 1; n <= LAST_DAY; n++) {
      const p = Math.round(dayProgress(n) * 100);
      days += '<a href="#day-' + n + '" class="' + on("day-" + n).trim() + (n === cur ? " today-day" : "") + '"><span>Day ' + n +
        '<span class="sub">' + esc(fmtDate(dateOfDay(n))) + " · " + esc(shortTitle(n)) + '</span></span><span class="meter" title="' + p + '% done"><i style="width:' + p + '%"></i></span></a>';
    }
    $("#rail").innerHTML =
      '<div class="rail-top"><a class="brand" href="#today"><b>C Sprint</b><span>CISC220 final · ' + esc(fmtDate(EXAM_DATE, { weekday: "short", month: "short", day: "numeric" })) + '</span></a>' +
      '<button class="btn ghost menu-btn" id="menuBtn" aria-expanded="false">Menu</button></div>' +
      '<div class="countdown"><span class="pr">$</span> ./days_left<br>' + cdText + "</div>" +
      '<nav class="nav">' +
      '<a href="#today" class="' + on("today").trim() + '"><span>Today</span></a>' +
      '<a href="#review" class="' + on("review").trim() + '"><span>Spaced review</span><span class="badge' + (due ? "" : " zero") + '">' + due + "</span></a>" +
      '<a href="#plan" class="' + on("plan").trim() + '"><span>The plan</span></a>' +
      '<a href="#a4" class="' + on("a4").trim() + '"><span>Assignment 4</span>' + (S.a4.submitted ? '<span class="badge">done</span>' : '<span class="badge">Nov 6</span>') + "</a>" +
      "<h6>Days</h6>" + days +
      "<h6>Exam practice</h6>" +
      Object.keys(mocks).map((id) => '<a href="#mock-' + id + '" class="' + on("mock-" + id).trim() + '"><span>' + esc(mocks[id].title) + "</span>" + mockBadge(id) + "</a>").join("") +
      '<a href="#practice" class="' + on("practice").trim() + '"><span>Past-paper practice</span>' + (PRACTICE.length ? '<span class="badge' + (PRACTICE.some((q) => mastered(q.id)) ? "" : " zero") + '">' + PRACTICE.filter((q) => mastered(q.id)).length + "/" + PRACTICE.length + "</span>" : "") + "</a>" +
      '<a href="#weak" class="' + on("weak").trim() + '"><span>Weak spots</span></a>' +
      '<a href="#sheet" class="' + on("sheet").trim() + '"><span>Summary sheet</span></a>' +
      "<h6>More</h6>" +
      '<a href="#library" class="' + on("library").trim() + '"><span>All lessons</span></a>' +
      '<a href="#data" class="' + on("data").trim() + '"><span>Progress &amp; backup</span></a>' +
      "</nav>";
    void cd;
  }
  function shortTitle(n) {
    const t = dayTitle(n);
    return t.length > 30 ? t.slice(0, 28).replace(/[\s,:]+\S*$/, "") + "…" : t;
  }
  function mockBadge(id) {
    const r = S.mocks[id];
    return r && r.score != null ? '<span class="badge">' + r.score + "/" + mockTotal(id) + "</span>" : "";
  }
  function mockTotal(id) {
    const m = mocks[id];
    if (!m) return 30;
    return m.questions.reduce((a, q) => a + q.parts.reduce((b, p) => b + (p.marks || 0), 0), 0);
  }

  // ---------------------------------------------------------------- views
  function viewToday() {
    const cd = calendarDay();
    const n = currentDay();
    const daysLeft = diffDays(today(), EXAM_DATE);
    let intro;
    if (cd === 0) intro = "The plan starts " + fmtDate(DAY_DATES[0], { weekday: "long", month: "long", day: "numeric" }) + ".";
    else if (cd > LAST_DAY) intro = daysLeft === 0 ? "It's exam day. Skim your summary sheet and the cards you've missed, then stop. No new material." : "The plan is complete.";
    else intro = "Day " + n + " of " + LAST_DAY + " · " + fmtDate(today(), { weekday: "long", month: "long", day: "numeric" });
    const due = dueItems().length;
    const p = Math.round(dayProgress(n) * 100);
    const totalCards = Object.keys(items).length;
    const known = Object.keys(S.srs).filter((id) => items[id] && S.srs[id].box >= 2).length;
    const stepsHtml = stepsFor(n).map((s) => stepRow(n, s)).join("");
    return '<div class="col">' +
      '<div class="head"><div class="eyebrow">' + esc(intro) + "</div><h1>" + esc(dayTitle(n)) + '</h1><p class="lede">' + esc(dayGoal(n)) + "</p></div>" +
      '<div class="stats">' +
      stat(p + "%", "of today's steps done") +
      stat(due, due === 1 ? "item due for review" : "items due for review") +
      stat(known + " / " + totalCards, "review items you've got right twice in a row") +
      stat(Math.max(0, daysLeft), "days until the final exam") +
      "</div>" +
      (due && n >= 2 && !stepDone(n, "review") ? '<div class="callout exam"><div class="lab">Start here</div><div class="row"><span>' + due + ' review items are due. Do them first. Recalling yesterday\'s material before today\'s lesson is the single best use of your first 25 minutes.</span><span class="spacer"></span><a class="btn primary" href="#review">Start review</a></div></div>' : "") +
      '<div class="steps">' + stepsHtml + "</div>" +
      '<p class="small muted">Total for today: about ' + Math.round(stepsFor(n).reduce((a, s) => a + s.mins, 0) / 5) * 5 + " minutes. Take a 5-minute break between steps. " +
      '<a href="#day-' + n + '">Open the Day ' + n + " page</a> · <a href=\"#plan\">See the whole plan</a></p>" +
      "</div>";
  }
  function stat(v, label) { return '<div class="stat"><b>' + esc(v) + "</b><span>" + esc(label) + "</span></div>"; }

  function stepRow(n, s) {
    const done = stepDone(n, s.key);
    let extra = "";
    if (s.topics && dayData[n]) {
      extra = '<div class="topiclist">' + dayData[n].topics.map((t) =>
        '<a href="#topic-' + esc(t.id) + '" class="' + (S.topicsDone[t.id] ? "done" : "") + '"><span>' + esc(t.title) + "</span>" + prioChip(t.priority) + "</a>").join("") + "</div>";
    }
    let action = "";
    if (s.href) action = '<a class="btn' + (done ? "" : " primary") + '" href="#' + s.href + '">' + (done ? "Open again" : "Start") + "</a>";
    else if (s.topics && dayData[n]) {
      const next = dayData[n].topics.find((t) => !S.topicsDone[t.id]) || dayData[n].topics[0];
      action = '<a class="btn' + (done ? "" : " primary") + '" href="#topic-' + esc(next.id) + '">' + (done ? "Review" : "Continue") + "</a>";
    }
    return '<div class="step' + (done ? " done" : "") + '">' +
      '<button class="tick" data-act="toggle-step" data-day="' + n + '" data-key="' + s.key + '" aria-label="Mark ' + esc(s.title) + (done ? " not done" : " done") + '" aria-pressed="' + done + '"></button>' +
      "<div><h3>" + esc(s.title) + "</h3><p>" + esc(s.desc) + "</p>" + extra + "</div>" +
      '<div class="acts">' + (s.mins ? '<span class="mins">~' + s.mins + " min</span>" : "") + action + "</div></div>";
  }

  function viewDay(n) {
    if (!(n >= 1 && n <= LAST_DAY)) return notFound();
    const cur = currentDay();
    const dd = dayData[n];
    let extra = "";
    if (dd) {
      const counts = dd.topics.length + " lessons · " + dd.flashcards.length + " flashcards · " + dd.quiz.length + " quiz questions · " + dd.write.length + " writing exercises";
      extra = '<p class="small muted">' + counts + "</p>";
    }
    return '<div class="col"><div class="head"><div class="eyebrow">Day ' + n + " · " + esc(fmtDate(dateOfDay(n), { weekday: "long", month: "long", day: "numeric" })) +
      (n === cur ? " · today" : "") + "</div><h1>" + esc(dayTitle(n)) + '</h1><p class="lede">' + esc(dayGoal(n)) + "</p>" + extra + "</div>" +
      '<div class="steps">' + stepsFor(n).map((s) => stepRow(n, s)).join("") + "</div>" +
      (n !== cur ? '<p class="small muted">The plan puts this on ' + esc(fmtDate(dateOfDay(n), { weekday: "long", month: "short", day: "numeric" })) + ". Working ahead is fine; just don't skip the spaced reviews.</p>" : "") +
      dayNav(n) + "</div>";
  }
  function dayNav(n) {
    return '<div class="row">' + (n > 1 ? '<a class="btn ghost" href="#day-' + (n - 1) + '">← Day ' + (n - 1) + "</a>" : "") + '<span class="spacer"></span>' +
      (n < LAST_DAY ? '<a class="btn ghost" href="#day-' + (n + 1) + '">Day ' + (n + 1) + " →</a>" : "") + "</div>";
  }

  function viewTopic(id) {
    const t = topics[id];
    if (!t) return notFound();
    const d = dayData[t.day];
    const idx = d.topics.findIndex((x) => x.id === id);
    const next = d.topics[idx + 1];
    const blocks = (t.blocks || []).map((b, bi) => {
      switch (b.type) {
        case "md": return '<div class="prose">' + md(b.text) + "</div>";
        case "code": return codeBlock(b.code, b.caption);
        case "check": return '<div class="callout check"><div class="lab">Check: answer before you reveal</div><div class="prose">' + md(b.q) + "</div>" +
          '<div><button class="btn" data-act="reveal" data-target="rv-' + bi + '">Reveal answer</button></div><div class="reveal answer prose" id="rv-' + bi + '" hidden>' + md(b.a) + "</div></div>";
        case "why": return '<div class="callout why"><div class="lab">Why?</div><div class="prose">' + md(b.q) + "</div>" +
          '<div><button class="btn ghost" data-act="reveal" data-target="rv-' + bi + '">Explain it to yourself, then compare</button></div><div class="reveal answer prose" id="rv-' + bi + '" hidden>' + md(b.a) + "</div></div>";
        case "pitfall": return '<div class="callout pitfall"><div class="lab">Common mistake</div><div class="prose">' + md(b.text) + "</div></div>";
        case "try": return '<div class="callout try"><div class="lab">Do this now in your terminal</div><div class="prose">' + md(b.text) + "</div></div>";
        default: return "";
      }
    }).join("");
    const done = !!S.topicsDone[id];
    return '<div class="col"><div class="head"><div class="eyebrow"><a href="#day-' + t.day + '">Day ' + t.day + "</a> · Lesson " + (idx + 1) + " of " + d.topics.length + "</div>" +
      "<h1>" + esc(t.title) + '</h1><div class="row">' + prioChip(t.priority) +
      (t.notebook ? '<a class="small" href="' + REPO + esc(t.notebook) + '" target="_blank" rel="noopener">Course notebook: ' + esc(t.notebook) + "</a>" : "") + "</div></div>" +
      (t.examNote ? '<div class="callout exam"><div class="lab">On the exam</div><div class="prose">' + md(t.examNote) + "</div></div>" : "") +
      blocks +
      '<div class="card"><div class="row"><div><h3>' + (done ? "Lesson marked as learned" : "Finished this lesson?") + '</h3><p class="small muted" style="margin:0">Close it and say the key points out loud before moving on.</p></div><span class="spacer"></span>' +
      '<button class="btn' + (done ? "" : " primary") + '" data-act="topic-done" data-id="' + esc(id) + '">' + (done ? "Mark as not learned" : "Mark as learned") + "</button>" +
      (next ? '<a class="btn" href="#topic-' + esc(next.id) + '">Next: ' + esc(next.title) + " →</a>" : '<a class="btn" href="#cards-' + t.day + '">Next: flashcards →</a>') +
      "</div></div></div>";
  }

  // ----- flashcards
  function startCards(ids, label, back) {
    session = { type: "cards", queue: ids.slice(), done: 0, total: ids.length, again: 0, label: label, back: back, shown: false };
  }
  function viewCards(n) {
    const d = dayData[n];
    if (!d) return notFound();
    if (!session || session.type !== "cards" || session.key !== "cards-" + n) {
      const fresh = d.flashcards.filter((c) => !S.srs[c.id]).map((c) => c.id);
      const due = d.flashcards.filter((c) => S.srs[c.id] && S.srs[c.id].due <= today()).map((c) => c.id);
      const ids = fresh.length ? fresh : due;
      if (!ids.length) {
        return '<div class="col"><div class="head"><div class="eyebrow"><a href="#day-' + n + '">Day ' + n + "</a></div><h1>Flashcards</h1></div>" +
          '<div class="card empty"><h3>All of today\'s cards are scheduled</h3><p>They will come back in your spaced review when they are due. You can still drill them all again now.</p>' +
          '<div class="row" style="justify-content:center"><button class="btn primary" data-act="cards-all" data-day="' + n + '">Drill all ' + d.flashcards.length + ' cards</button><a class="btn" href="#day-' + n + '">Back to Day ' + n + "</a></div></div></div>";
      }
      startCards(ids, "Day " + n + (fresh.length ? " new cards" : " due cards"), "#day-" + n);
      session.key = "cards-" + n;
    }
    return cardSessionView();
  }
  function cardSessionView() {
    const s = session;
    if (!s.queue.length) {
      return '<div class="col"><div class="card empty"><h2>Session complete</h2><p>' + s.total + " cards · " + s.again + " marked Again.</p>" +
        '<p class="small">Cards you rated Again are due again tomorrow; cards you knew will come back in 1 to 7 days.</p>' +
        '<div class="row" style="justify-content:center"><a class="btn primary" href="' + esc(s.back) + '">Continue</a></div></div></div>';
    }
    const id = s.queue[0];
    const c = items[id];
    const pct = Math.round((s.done / Math.max(1, s.done + s.queue.length)) * 100);
    const box = S.srs[id] ? S.srs[id].box : -1;
    return '<div class="col"><div class="head"><div class="eyebrow">' + esc(s.label) + " · " + s.queue.length + ' left</div><div class="progress"><i style="width:' + pct + '%"></i></div></div>' +
      '<div class="card flash"><div class="row"><span class="chip">' + esc(topicTitle(c.topic)) + "</span>" + (box < 0 ? '<span class="chip accent">new</span>' : "") + "</div>" +
      '<div class="side prose">' + md(c.front) + "</div>" +
      (s.shown ? '<div class="back prose">' + md(c.back) + "</div>" : "") + "</div>" +
      (s.shown
        ? '<div class="rates">' +
          '<button class="btn bad" data-act="rate" data-g="0">Again<small>missed it · <kbd>1</kbd></small></button>' +
          '<button class="btn warn" data-act="rate" data-g="1">Hard<small>slow or partial · <kbd>2</kbd></small></button>' +
          '<button class="btn good" data-act="rate" data-g="2">Good<small>got it · <kbd>3</kbd></small></button>' +
          '<button class="btn" data-act="rate" data-g="3">Easy<small>instant · <kbd>4</kbd></small></button></div>'
        : '<div class="row"><button class="btn primary" data-act="show-back">Show answer <kbd>Space</kbd></button><span class="kbd-hint">Say your answer out loud first.</span></div>') +
      "</div>";
  }
  function topicTitle(tid) { return topics[tid] ? topics[tid].title : ""; }

  // ----- quiz
  function buildQuiz(n) {
    const d = dayData[n];
    const own = d.quiz.map((q) => q.id);
    let mixed = [];
    if (n >= 3) {
      const prior = Object.values(items).filter((it) => it.kind === "quiz" && it.day < n);
      const dueP = prior.filter((it) => S.srs[it.id] && S.srs[it.id].due <= today()).map((it) => it.id);
      const unseen = prior.filter((it) => !S.srs[it.id]).map((it) => it.id);
      mixed = shuffle(dueP).slice(0, 8);
      if (mixed.length < 6) mixed = mixed.concat(shuffle(unseen).slice(0, 6 - mixed.length));
    }
    let mine = own;
    if (own.length > QUIZ_CAP - 3) {
      // Unseen questions first, spread evenly over the day's topics.
      const byTopic = {};
      shuffle(own.slice()).sort((a, b) => (S.srs[a] ? 1 : 0) - (S.srs[b] ? 1 : 0)).forEach((id) => { (byTopic[items[id].topic] = byTopic[items[id].topic] || []).push(id); });
      const lists = Object.values(byTopic);
      mine = [];
      for (let k = 0; mine.length < QUIZ_CAP - 3 && lists.some((l) => l.length); k = (k + 1) % lists.length) if (lists[k].length) mine.push(lists[k].shift());
      mixed = mixed.slice(0, 3);
    }
    const ids = n >= 3 ? interleave(mine.concat(mixed)) : shuffle(own);
    return { type: "quiz", key: "quiz-" + n, day: n, queue: ids, i: 0, right: 0, results: [], answered: false, back: "#day-" + n, label: "Day " + n + " practice quiz" };
  }
  function viewQuiz(n) {
    const d = dayData[n];
    if (!d) return notFound();
    if (!session || session.key !== "quiz-" + n) {
      const last = S.quizRuns["d" + n];
      return '<div class="col"><div class="head"><div class="eyebrow"><a href="#day-' + n + '">Day ' + n + "</a></div><h1>Practice quiz</h1>" +
        '<p class="lede">' + (d.quiz.length > QUIZ_CAP - 3 ? QUIZ_CAP + " questions: a mixed set from today's " + d.quiz.length + " (unseen ones first) plus a few earlier ones. Retake for a fresh set" : d.quiz.length + " questions on today's topics" + (n >= 3 ? ", plus a few due questions from earlier days" : "")) +
        ". Answer before you look. Questions you miss come back in your spaced review.</p></div>" +
        (last ? '<p class="muted">Last run: ' + last.right + "/" + last.total + " on " + esc(fmtDate(last.date)) + (last.best ? " · best " + last.best + "%" : "") + "</p>" : "") +
        '<div class="row"><button class="btn primary" data-act="quiz-start" data-day="' + n + '">Start the quiz</button></div></div>';
    }
    return quizSessionView();
  }
  function quizSessionView() {
    const s = session;
    if (s.i >= s.queue.length) return quizSummary();
    const q = items[s.queue[s.i]];
    const pct = Math.round((s.i / s.queue.length) * 100);
    const fromEarlier = q.day !== s.day && s.day ? '<span class="chip accent">from Day ' + q.day + "</span>" : "";
    let body = '<div class="prose">' + md(q.q) + "</div>" + (q.code ? codeBlock(q.code) : "");
    const r = s.answered ? s.results[s.results.length - 1] : null;
    if (q.type === "mcq") {
      body += '<div class="opts">' + q.options.map((o, k) => {
        let cls = "";
        if (s.answered) { if (k === q.answer) cls = " right"; else if (r && r.pick === k) cls = " wrong"; }
        return '<button class="opt' + cls + '" data-act="mcq" data-k="' + k + '"' + (s.answered ? " disabled" : "") + '><span class="key">' + "ABCD"[k] + '</span><span class="prose">' + md(o) + "</span></button>";
      }).join("") + "</div>";
    } else {
      const ph = q.type === "output" ? "Type the exact output…" : "Type your answer…";
      body += '<textarea class="ans" id="qans" spellcheck="false" placeholder="' + ph + '"' + (s.answered ? " readonly" : "") + ">" + esc(r ? r.text : "") + "</textarea>";
      if (!s.answered) body += '<div class="row"><button class="btn primary" data-act="quiz-submit">' + (q.type === "output" ? "Check" : "Show model answer") + ' <kbd>Ctrl+Enter</kbd></button></div>';
    }
    if (s.answered) {
      if (q.type === "output") {
        body += '<div class="verdict ' + (r.ok ? "good" : "bad") + '">' + (r.ok ? "Correct." : "Not quite. Expected output:") + "</div>" + (r.ok ? "" : codeBlock(q.answer || "(no output)"));
      } else if (q.type === "short") {
        body += '<div class="callout check"><div class="lab">Model answer</div><div class="prose">' + md(q.answer) + "</div></div>";
      } else {
        body += '<div class="verdict ' + (r.ok ? "good" : "bad") + '">' + (r.ok ? "Correct." : "Not this time.") + "</div>";
      }
      if (q.explain) body += '<div class="prose small">' + md(q.explain) + "</div>";
      if (q.type === "short" && r.ok == null) {
        body += '<div class="row"><span>How did you do?</span><button class="btn bad" data-act="self" data-ok="0">Missed it</button><button class="btn warn" data-act="self" data-ok="1">Partly</button><button class="btn good" data-act="self" data-ok="2">Got it</button></div>';
      } else {
        body += '<div class="row">' + (q.type === "output" && !r.ok ? '<button class="btn ghost" data-act="override">My answer was equivalent; count it</button>' : "") +
          '<span class="spacer"></span><button class="btn primary" data-act="quiz-next">Next <kbd>Enter</kbd></button></div>';
      }
    }
    return '<div class="col"><div class="head"><div class="eyebrow">' + esc(s.label) + " · question " + (s.i + 1) + " of " + s.queue.length + "</div>" +
      '<div class="progress"><i style="width:' + pct + '%"></i></div></div>' +
      '<div class="card"><div class="row"><span class="chip">' + esc(topicTitle(q.topic)) + "</span>" + fromEarlier + "</div>" + body + "</div></div>";
  }
  function normOut(s) { return String(s || "").replace(/\r/g, "").split("\n").map((l) => l.replace(/\s+$/, "")).join("\n").replace(/\n+$/, "").replace(/^\n+/, ""); }
  function quizSummary() {
    const s = session;
    const total = s.results.length;
    const right = s.results.filter((r) => r.ok).length;
    if (!s.saved && s.day) {
      const k = "d" + s.day;
      const prev = S.quizRuns[k];
      const pct = Math.round((right / Math.max(1, total)) * 100);
      S.quizRuns[k] = { right: right, total: total, date: today(), best: Math.max(pct, prev ? prev.best || 0 : 0) };
      save();
    }
    if (!s.saved && s.review) { S.reviewDone[today()] = true; save(); }
    s.saved = true;
    const missed = s.results.filter((r) => !r.ok);
    return '<div class="col"><div class="card"><h2>' + right + " / " + total + " correct</h2>" +
      (missed.length ? "<p>Review these before moving on (they are also scheduled for tomorrow):</p><ul>" + missed.map((r) => {
        const q = items[r.id];
        return '<li><a href="#topic-' + esc(q.topic) + '">' + esc(topicTitle(q.topic)) + "</a>: " + inline(stripMd(q.q).slice(0, 110)) + "</li>";
      }).join("") + "</ul>" : "<p>Clean sweep. These questions will come back in a few days to make sure it lasts.</p>") +
      '<div class="row"><a class="btn primary" href="' + esc(s.back) + '">Continue</a>' + (s.day ? '<button class="btn" data-act="quiz-start" data-day="' + s.day + '">Retake</button>' : "") + "</div></div></div>";
  }
  function stripMd(s) { return String(s || "").replace(/```[\s\S]*?```/g, " [code] ").replace(/\n/g, " "); }

  // ----- spaced review
  function viewReview(mode) {
    const cards = mode === "missed" ? missedItems().filter((id) => items[id].kind === "card") : dueItems("card");
    const qs = mode === "missed" ? missedItems().filter((id) => items[id].kind === "quiz") : dueItems("quiz");
    const redo = Object.keys(S.write).filter((id) => writes[id] && S.write[id].redo && S.write[id].redo <= today());
    const doneToday = !!S.reviewDone[today()];
    return '<div class="col"><div class="head"><div class="eyebrow">' + (mode === "missed" ? "Everything you've missed at least once" : "Due today") + "</div><h1>" + (mode === "missed" ? "Missed-item review" : "Spaced review") + "</h1>" +
      '<p class="lede">Items come back after 1, 2, 4 and then 7 days while you keep getting them right, and the next day whenever you miss one. Spacing reviews out like this beats cramming the same material in one sitting.</p></div>' +
      '<div class="stats">' + stat(cards.length, "flashcards due") + stat(qs.length, "questions due") + stat(redo.length, "scripts to rewrite") + "</div>" +
      (cards.length + qs.length === 0 && !redo.length
        ? '<div class="card empty"><h3>' + (doneToday ? "Review done for today" : "Nothing is due right now") + "</h3><p>New items enter the review once you've studied them on their day.</p>" +
          (doneToday ? "" : '<div class="row" style="justify-content:center"><button class="btn" data-act="review-mark">Mark today\'s review as done</button></div>') + "</div>"
        : '<div class="row">' +
          (cards.length ? '<button class="btn primary" data-act="review-cards" data-mode="' + (mode || "") + '">Review ' + cards.length + " flashcards</button>" : "") +
          (qs.length ? '<button class="btn' + (cards.length ? "" : " primary") + '" data-act="review-quiz" data-mode="' + (mode || "") + '">Answer ' + qs.length + " mixed questions</button>" : "") +
          "</div>") +
      (redo.length ? '<div class="card"><h3>Rewrite these from a blank page</h3><p class="small muted">You scored under 70% on these. Rewrite them without looking.</p><ul>' +
        redo.map((id) => '<li><a href="#write-' + writes[id].day + '">' + esc(firstLine(writes[id].prompt)) + "</a> (Day " + writes[id].day + ")</li>").join("") + "</ul></div>" : "") +
      "</div>";
  }
  function firstLine(s) { return stripMd(s).replace(/[#*`]/g, "").trim().slice(0, 90); }

  // ----- writing exercises
  function viewWrite(n) {
    const d = dayData[n];
    if (!d) return notFound();
    const stageLab = { worked: "Worked example", faded: "Fill in the blanks", blank: "From a blank page" };
    const hasCore = d.write.some((w) => w.core);
    const list = d.write.map((w, k) => {
      const r = S.write[w.id];
      const max = (w.rubric || []).reduce((a, x) => a + (x.marks || 0), 0) || w.marks || 0;
      const status = r ? '<span class="chip ' + (r.score / Math.max(1, r.max) >= 0.7 ? "ok" : "high") + '">' + r.score + "/" + r.max + "</span>" : "";
      const draft = (S.drafts[w.id] != null ? S.drafts[w.id] : (w.stage === "faded" ? w.starter || "" : ""));
      const showSol = !!(session && session.type === "write" && session.open && session.open[w.id]);
      const worked = w.stage === "worked";
      const studied = !!(session && session.studied && session.studied[w.id]);
      let inner = '<div class="prose">' + md(w.prompt) + "</div>";
      if (worked && !studied) {
        inner += '<div class="callout check"><div class="lab">Study this solution</div>' + codeBlock(w.solution) + (w.explain ? '<div class="prose">' + md(w.explain) + "</div>" : "") + "</div>" +
          '<div class="row"><button class="btn primary" data-act="write-studied" data-id="' + esc(w.id) + '">I\'ve studied it: hide it and let me write it</button></div>';
      } else {
        inner += '<textarea class="ans tall" data-draft="' + esc(w.id) + '" id="w-' + esc(w.id) + '" spellcheck="false" placeholder="Write your answer here, or on paper first and then type it in.">' + esc(draft) + "</textarea>";
        if (!showSol) inner += '<div class="row"><button class="btn primary" data-act="write-check" data-id="' + esc(w.id) + '">Compare with the model answer</button></div>';
      }
      if (showSol) {
        inner += '<div class="callout check"><div class="lab">Model answer</div>' + codeBlock(w.solution) + (w.explain && !worked ? '<div class="prose">' + md(w.explain) + "</div>" : "") + "</div>" +
          (w.rubric && w.rubric.length ? '<div><h4>Mark yourself like a TA would</h4><div class="rubric" data-rubric="' + esc(w.id) + '">' + w.rubric.map((x, j) =>
            '<label><input type="checkbox" data-j="' + j + '" ' + (r && r.ticks && r.ticks[j] ? "checked" : "") + "><span>" + inline(x.item) + '</span><span class="m">' + x.marks + "</span></label>").join("") + "</div></div>" : "") +
          (w.pitfalls && w.pitfalls.length ? '<div class="callout pitfall"><div class="lab">Watch out for</div><div class="prose"><ul>' + w.pitfalls.map((p) => "<li>" + inline(p) + "</li>").join("") + "</ul></div></div>" : "") +
          '<div class="row"><button class="btn primary" data-act="write-save" data-id="' + esc(w.id) + '">Save my score</button><span class="small muted">Under 70% puts it on tomorrow\'s rewrite list.</span></div>';
      }
      const extraHead = hasCore && !w.core && (k === 0 || d.write[k - 1].core)
        ? '<div class="head"><h2>Extra practice</h2><p class="lede">Only if you have time after the core set. These cover the same topics again.</p></div>' : "";
      return extraHead + '<div class="card" id="card-' + esc(w.id) + '"><div class="row"><span class="eyebrow">' + (k + 1) + ". " + esc(stageLab[w.stage] || w.stage) + "</span>" + (w.core ? '<span class="chip accent">core</span>' : "") +
        '<span class="chip">' + esc(topicTitle(w.topic)) + "</span>" + (max ? '<span class="marks">' + max + " marks</span>" : "") + '<span class="spacer"></span>' + status + "</div>" + inner + "</div>";
    }).join("");
    return '<div class="col"><div class="head"><div class="eyebrow"><a href="#day-' + n + '">Day ' + n + "</a></div><h1>Write it by hand</h1>" +
      '<p class="lede">These go from a full worked example, to one with blanks, to a blank page, so you rely a little less on help each time. Use paper for the last ones: on the exam there is no autocomplete and no way to run your code.</p></div>' + list + dayNav(n) + "</div>";
  }

  // ----- drills
  function viewDrills(n) {
    const r = S.drills[n];
    const p = (h) => '<div class="prose">' + h + "</div>";
    const first = n === 1 ? '<div class="card"><h3>First time: get the C app\'s files</h3>' +
      p("<p>The C labs live in the same repository as your Bash study app, so you only need to update it:</p>") +
      codeBlock("$ cd ~/CISC220_current\n$ git pull\n$ cd c-app/drills\n$ ls\ncdrill.sh  days  solutions") +
      p("<p>If <code>gcc --version</code> prints <code>command not found</code>, install the compiler once with <code>sudo apt install build-essential</code>. Don't open <code>days</code> or <code>solutions</code>: they contain the answers.</p>") + "</div>" : "";
    return '<div class="col"><div class="head"><div class="eyebrow"><a href="#day-' + n + '">Day ' + n + "</a></div><h1>Lab: compile and test</h1>" +
      '<p class="lede">Write small programs, compile them with gcc, and let the checker run them. It compares what your program prints and its exit status with a reference program, so any correct code passes.</p></div>' + first +
      '<div class="card"><h3>Today\'s lab</h3>' +
      codeBlock("$ cd ~/CISC220_current/c-app/drills\n$ git pull\n$ ./cdrill.sh start " + n + "     # shows the tasks and makes ~/cisc220_c/day" + n + "/") +
      p("<p>Write each program in that folder with nano, for example <code>nano ~/cisc220_c/day" + n + "/hello.c</code>. Compile and run it yourself while you work:</p>") +
      codeBlock("$ cd ~/cisc220_c/day" + n + "\n$ gcc -Wall -o hello hello.c\n$ ./hello") +
      p("<p>Then let the checker test everything, as often as you like:</p>") +
      codeBlock("$ cd ~/CISC220_current/c-app/drills\n$ ./cdrill.sh check " + n) +
      p("<ul><li>A failing test shows the expected lines (<code>-</code>) next to yours (<code>+</code>).</li><li>Compiler <b>warnings</b> are shown too: treat them as bugs and fix them.</li><li>Stuck for more than 5 minutes? Re-read the lesson and move on.</li></ul>") + "</div>" +
      '<div class="card"><h3>Record your score</h3><div class="row"><label for="drillScore">Final <code>./cdrill.sh check ' + n + '</code> score</label>' +
      '<input id="drillScore" class="ans" style="width:110px;min-height:0" placeholder="e.g. 3/4" value="' + esc(r || "") + '">' +
      '<button class="btn primary" data-act="drill-save" data-day="' + n + '">Save</button></div></div>' + dayNav(n) + "</div>";
  }

  // ----- Assignment 4
  function viewA4() {
    const files = [
      { f: "concat2.c", w: "30%", day: 3, what: "Join its two command-line arguments into a NEW string, then print it. Only strlen, printf and puts allowed.",
        build: "gcc -Wall -o concat2 concat2.c", notes: ["The assignment's sample output \"marshmallo\" is a typo: the right output is <code>marshmallow</code>.", "No arguments: print nothing. One argument: print it."] },
      { f: "sin.c", w: "30%", day: 4, what: "Approximate sin(x) with the truncated Taylor series (terms up to x¹³/13!), using your own <code>fact</code>. Print with <code>%24.17f</code>; usage message to stderr and exit status 1 for the wrong number of arguments.",
        build: "gcc -Wall -o sin sin.c -lm", notes: ["Put <code>-lm</code> <b>after</b> sin.c. The assignment's order <code>gcc -o sin -lm sin.c</code> fails on Ubuntu with <code>undefined reference to `pow'</code>."] },
      { f: "sumones.c", w: "40%", day: 5, what: "Complete <code>print</code>, <code>tobinary</code> and <code>sum</code> (ones' complement long addition with the end-around carry). <code>main</code> is already written.",
        build: "gcc -Wall -o sumones sumones.c -lm", notes: ["Write and test <code>print</code> and <code>tobinary</code> first, then <code>sum</code>.", "Don't convert to decimal: the sum must use the long addition in the starter comments."] },
    ];
    const rows = files.map((x) => {
      const done = !!S.a4[x.f];
      return '<div class="card"><div class="row"><h3>' + x.f + '</h3><span class="chip">' + x.w + '</span><span class="spacer"></span>' +
        '<label class="toggle"><input type="checkbox" data-a4="' + x.f + '"' + (done ? " checked" : "") + "><span>All tests pass</span></label></div>" +
        '<div class="prose"><p>' + x.what + '</p><ul>' + x.notes.map((t) => "<li>" + t + "</li>").join("") + "</ul></div>" +
        codeBlock("$ cd ~/CISC220_A4\n$ nano " + x.f + "\n$ " + x.build + "\n$ cd ~/CISC220_current/c-app/drills && ./cdrill.sh a4 ~/CISC220_A4 " + x.f) +
        '<div class="row small"><a href="#day-' + x.day + '">Learn what you need: Day ' + x.day + "</a></div></div>";
    }).join("");
    return '<div class="col"><div class="head"><div class="eyebrow">Due Friday, November 6</div><h1>Assignment 4: Introductory C</h1>' +
      '<p class="lede">Days 3, 4 and 5 each teach what one file needs and end with a plan for writing it. The lessons never give you the assignment code: you write it, and the checker tells you whether it behaves like the assignment says.</p></div>' +
      '<div class="card"><h3>Set up once</h3><div class="prose"><p>Unzip the starter files into your home folder so they are in <code>~/CISC220_A4</code>:</p></div>' +
      codeBlock("$ cd ~\n$ unzip ~/Downloads/A4_files.zip     # use the folder where you saved the ZIP\n$ ls ~/CISC220_A4\nconcat2.c  sin.c  sumones.c") + "</div>" +
      rows +
      '<div class="card"><h3>Check everything and submit</h3>' + codeBlock("$ cd ~/CISC220_current/c-app/drills && ./cdrill.sh a4\n$ cd ~/CISC220_A4 && zip A4.zip concat2.c sin.c sumones.c") +
      '<div class="prose"><p>Submit <code>A4.zip</code> on onQ, then download it again from onQ and check that all three files are inside. The checker covers the assignment\'s examples and a few edge cases; the TAs may test more, so also try your own inputs.</p></div>' +
      '<div class="row"><label class="toggle"><input type="checkbox" data-a4="submitted"' + (S.a4.submitted ? " checked" : "") + "><span>Submitted on onQ</span></label></div></div></div>";
  }

  // ----- brain dump
  function viewDump(n) {
    const d = dayData[n];
    const saved = S.dumps[n] || "";
    let keys = "";
    if (d) {
      keys = d.topics.map((t) => {
        const kp = (t.blocks || []).filter((b) => b.type === "md" && /###\s*Key points/i.test(b.text)).map((b) => md(b.text.replace(/^[\s\S]*?###\s*Key points[^\n]*\n/i, ""))).join("");
        return "<h4>" + esc(t.title) + "</h4>" + (kp || "<p class=\"muted\">Re-skim the lesson headings.</p>");
      }).join("");
    }
    const revealed = !!(session && session.type === "dump" && session.day === n);
    return '<div class="col"><div class="head"><div class="eyebrow">' + (n <= LAST_DAY ? '<a href="#day-' + n + '">Day ' + n + "</a>" : "") + "</div><h1>Brain dump</h1>" +
      '<p class="lede">Close everything else. For 10 minutes, write down every command, rule and gotcha you remember from today, with tiny examples. Pulling it out of memory is the practice, so don\'t peek.</p></div>' +
      '<textarea class="ans tall prose-ans" id="dumpText" data-dump="' + n + '" placeholder="e.g. chmod 750 = rwxr-x--- … quotes stop word splitting … ">' + esc(saved) + "</textarea>" +
      '<div class="row"><button class="btn primary" data-act="dump-save" data-day="' + n + '">Save and compare with the key points</button></div>' +
      (revealed && keys ? '<div class="card"><h3>Key points: what did you miss?</h3><div class="prose">' + keys + '</div><p class="small muted">Anything you missed goes first in tomorrow\'s warm-up. Write it down now.</p></div>' : "") +
      "</div>";
  }

  // ----- mocks
  function viewMock(id) {
    const m = mocks[id];
    if (!m) return '<div class="col"><div class="card empty"><h3>Mock exam not available yet</h3></div></div>';
    const r = S.mocks[id] || {};
    const total = mockTotal(id);
    if (!r.started) {
      return '<div class="col"><div class="head"><div class="eyebrow">Exam practice</div><h1>' + esc(m.title) + '</h1><p class="lede">' + total + " marks · " + m.minutes + " minutes · no aids.</p></div>" +
        '<div class="card"><div class="prose">' + md(m.instructions || "") +
        "<ul><li>Use paper and a pen, like the real exam. Put your phone in another room.</li><li>When the timer ends, stop writing, even mid-line.</li><li>Then mark yourself strictly with the rubric. Missing quotes cost marks on the real exam too.</li></ul></div>" +
        '<div class="row"><button class="btn primary" data-act="mock-start" data-id="' + esc(id) + '">Start the ' + m.minutes + "-minute timer</button>" +
        (r.score != null ? '<span class="muted">Previous score: ' + r.score + "/" + total + "</span>" : "") + "</div></div></div>";
    }
    const marking = !!r.marking;
    const qs = m.questions.map((q) => {
      const qm = q.parts.reduce((a, p) => a + (p.marks || 0), 0);
      return '<div class="card"><div class="row"><h3>' + esc(q.title) + '</h3><span class="marks">' + qm + " marks</span></div>" +
        (q.prompt ? '<div class="prose">' + md(q.prompt) + "</div>" : "") +
        q.parts.map((p) => '<div class="q-part">' + (q.parts.length > 1 ? '<div class="row"><b>' + esc(p.label || "") + ')</b><span class="marks">' + p.marks + " mark" + (p.marks === 1 ? "" : "s") + "</span></div>" : "") +
          '<div class="prose">' + md(p.prompt) + "</div>" +
          (marking ? '<div class="callout check"><div class="lab">Model answer</div><div class="prose">' + md(p.solution) + "</div></div>" +
            '<div class="rubric" data-mock="' + esc(id) + '" data-part="' + esc(p.id) + '">' + (p.rubric || []).map((x, j) =>
              '<label><input type="checkbox" data-j="' + j + '" ' + (r.ticks && r.ticks[p.id] && r.ticks[p.id][j] ? "checked" : "") + "><span>" + inline(x.item) + '</span><span class="m">' + x.marks + "</span></label>").join("") + "</div>" : "") +
          "</div>").join("") + "</div>";
    }).join("");
    let bar;
    if (!marking) {
      bar = '<div class="sticky-bar row"><span class="timer" id="mockTimer">--:--</span><span class="muted small">Write on paper.</span><span class="spacer"></span>' +
        '<button class="btn primary" data-act="mock-mark" data-id="' + esc(id) + '">Stop and mark</button></div>';
    } else {
      const sc = mockScore(id);
      bar = '<div class="sticky-bar row"><b>Score: <span id="mockScore">' + sc + "</span> / " + total + '</b><span class="spacer"></span>' +
        '<button class="btn primary" data-act="mock-save" data-id="' + esc(id) + '">Save score</button><button class="btn ghost" data-act="mock-reset" data-id="' + esc(id) + '">Reset</button></div>' +
        (r.score != null ? mockBreakdown(id) : "");
    }
    return '<div class="col"><div class="head"><div class="eyebrow">Exam practice</div><h1>' + esc(m.title) + "</h1></div>" + bar + qs + "</div>";
  }
  function mockScore(id) {
    const m = mocks[id]; const r = S.mocks[id] || {}; let sc = 0;
    m.questions.forEach((q) => q.parts.forEach((p) => (p.rubric || []).forEach((x, j) => { if (r.ticks && r.ticks[p.id] && r.ticks[p.id][j]) sc += x.marks; })));
    return sc;
  }
  function mockTagLoss(id) {
    const m = mocks[id]; const r = S.mocks[id] || {}; const loss = {};
    m.questions.forEach((q) => q.parts.forEach((p) => {
      let got = 0;
      (p.rubric || []).forEach((x, j) => { if (r.ticks && r.ticks[p.id] && r.ticks[p.id][j]) got += x.marks; });
      const lost = (p.marks || 0) - got;
      if (lost > 0) (p.topics || []).forEach((t) => { loss[t] = (loss[t] || 0) + lost / (p.topics.length || 1); });
    }));
    return loss;
  }
  function mockBreakdown(id) {
    const loss = mockTagLoss(id);
    const rows = Object.entries(loss).sort((a, b) => b[1] - a[1]);
    if (!rows.length) return '<div class="callout exam"><div class="lab">Breakdown</div><p>Full marks. Nothing to fix.</p></div>';
    return '<div class="callout exam"><div class="lab">Where you lost marks</div><div class="prose"><ul>' + rows.map(([t, v]) => {
      const tp = topicForTag(t);
      return "<li>" + (tp ? '<a href="#topic-' + esc(tp.id) + '">' + esc(tp.title) + "</a>" : esc(t)) + ": " + (Math.round(v * 10) / 10) + " marks</li>";
    }).join("") + "</ul></div></div>";
  }

  // ----- weak spots
  function viewWeak() {
    const rows = Object.entries(S.topicStats).filter(([t]) => topics[t]).map(([t, v]) => ({ t: t, right: v.right, wrong: v.wrong, acc: v.right / Math.max(1, v.right + v.wrong) }))
      .filter((x) => x.right + x.wrong >= 3).sort((a, b) => a.acc - b.acc);
    const lowWrites = Object.entries(S.write).filter(([id, r]) => writes[id] && r.score / Math.max(1, r.max) < 0.7);
    const lapsed = Object.keys(S.srs).filter((id) => items[id] && S.srs[id].lapses >= 2).sort((a, b) => S.srs[b].lapses - S.srs[a].lapses).slice(0, 15);
    const mockLoss = {};
    Object.keys(mocks).forEach((m) => { if (S.mocks[m] && S.mocks[m].score != null) Object.entries(mockTagLoss(m)).forEach(([t, v]) => { mockLoss[t] = (mockLoss[t] || 0) + v; }); });
    const ml = Object.entries(mockLoss).sort((a, b) => b[1] - a[1]);
    const empty = !rows.length && !lowWrites.length && !lapsed.length && !ml.length;
    return '<div class="col"><div class="head"><div class="eyebrow">Exam practice</div><h1>Weak spots</h1><p class="lede">Built from your quiz answers, flashcard ratings, writing scores and mock exams. Spend extra time where accuracy is lowest; topics you already know well need less.</p></div>' +
      (empty ? '<div class="card empty"><p>Not enough data yet. This fills in as you do quizzes and flashcards.</p></div>' : "") +
      (ml.length ? '<div class="card"><h3>Marks lost on mock exams, by topic</h3><div class="prose"><ul>' + ml.map(([t, v]) => {
        const tp = topicForTag(t); return "<li>" + (tp ? '<a href="#topic-' + esc(tp.id) + '">' + esc(tp.title) + "</a>" : esc(t)) + ": " + (Math.round(v * 10) / 10) + "</li>";
      }).join("") + "</ul></div></div>" : "") +
      (rows.length ? '<div class="card"><h3>Accuracy by topic (lowest first)</h3><div class="tablewrap"><table class="plan"><thead><tr><th>Topic</th><th>Day</th><th>Accuracy</th><th>Answers</th></tr></thead><tbody>' +
        rows.map((x) => '<tr><td><a href="#topic-' + esc(x.t) + '">' + esc(topicTitle(x.t)) + "</a></td><td>" + topics[x.t].day + "</td><td>" + Math.round(x.acc * 100) + "%</td><td>" + (x.right + x.wrong) + "</td></tr>").join("") +
        "</tbody></table></div></div>" : "") +
      (lowWrites.length ? '<div class="card"><h3>Scripts to rewrite from scratch</h3><ul>' + lowWrites.map(([id, r]) => '<li><a href="#write-' + writes[id].day + '">' + esc(firstLine(writes[id].prompt)) + "</a>: " + r.score + "/" + r.max + "</li>").join("") + "</ul></div>" : "") +
      (lapsed.length ? '<div class="card"><h3>Items you keep missing</h3><div class="prose"><ul>' + lapsed.map((id) => "<li>" + inline(stripMd(items[id].front || items[id].q).slice(0, 120)) + ' <span class="muted small">(missed ' + S.srs[id].lapses + "×)</span></li>").join("") + "</ul></div>" +
        '<div class="row"><a class="btn" href="#review-missed">Drill every missed item</a></div></div>' : "") +
      "</div>";
  }

  // ----- plan overview + method
  function viewPlan() {
    const cur = currentDay();
    const rows = [];
    for (let n = 1; n <= LAST_DAY; n++) {
      const d = dayData[n];
      const what = d ? d.topics.map((t) => esc(t.title)).join(", ") : esc(dayGoal(n));
      rows.push('<tr class="' + (n === cur ? "now" : "") + '"><td class="d">Day ' + n + "<br>" + esc(fmtDate(dateOfDay(n))) + '</td><td><a href="#day-' + n + '"><b>' + esc(dayTitle(n)) + "</b></a><br>" + what +
        '</td><td class="d">~' + Math.round(stepsFor(n).reduce((a, s) => a + s.mins, 0) / 5) * 5 + " min</td><td>" + Math.round(dayProgress(n) * 100) + "%</td></tr>");
    }
    return '<div class="col"><div class="head"><div class="eyebrow">Nov 1 – Dec 10</div><h1>The plan</h1>' +
      '<p class="lede">About an hour a day. Days 1 to 5 teach exactly what Assignment 4 needs before it is due on November 6. Then one short module a day through the rest of the course notebooks in course order, with a review day every week, and the last ten days on past final-exam questions.</p></div>' +
      '<div class="card"><div class="tablewrap"><table class="plan"><thead><tr><th>When</th><th>What</th><th>Time</th><th>Done</th></tr></thead><tbody>' + rows.join("") + "</tbody></table></div></div>" +
      '<div class="card"><h2>Why the days are built this way</h2><div class="prose">' + md(METHOD_MD) + "</div></div></div>";
  }
  const METHOD_MD = [
    "Every part of a day is there because research on learning supports it. Re-reading notes and highlighting feel productive but are among the least effective techniques.",
    "",
    "| Technique | Where it shows up | Evidence |",
    "|---|---|---|",
    "| **Practice testing** (retrieval practice) | Check boxes in lessons, flashcards, quizzes, brain dumps, mocks | Rated *high utility* in Dunlosky et al.'s 2013 review of 10 techniques. Roediger & Karpicke (2006): after a week, students who had tested themselves recalled about 61% of a passage, against 40% for students who re-read it. |",
    "| **Spaced (distributed) practice** | The spaced review queue: items return after 1, 2, 4 and 7 days, and sooner when missed | The other *high utility* technique in Dunlosky et al. Cepeda et al. (2008): the best gap between reviews grows with how long you need to remember; for a test about a week away it is roughly 1 to 2 days. |",
    "| **Interleaving** | From Day 3, quizzes mix in earlier days' questions, avoiding two in a row from one topic | Rated *moderate utility*. Mixing problem types trains you to recognise *which* tool a question needs, which is exactly the exam situation (Rohrer & Taylor 2007; Rohrer et al. 2014). |",
    "| **Elaborative interrogation and self-explanation** | The *Why?* boxes, and \"explain it to yourself, then compare\" | Rated *moderate utility*. Asking *why* links new facts to what you already know. |",
    "| **Worked examples that fade** | Write it by hand: full worked example, then blanks, then a blank page | Studying worked examples, then gradually removing the support, helps beginners learn problem solving (Renkl & Atkinson's fading research). |",
    "| **Honest self-assessment** | Rate cards Again/Hard/Good/Easy; mark scripts against TA-style rubrics | Re-reading makes material feel familiar. Testing shows what you actually know, so time goes where it's needed. |",
    "| **Sleep** | Short evenings, and no all-nighter before the exam | Memory consolidation happens during sleep. The plan keeps each day to about 2.5 hours so it fits around your other courses. |",
    "",
    "Sources: [Dunlosky et al. 2013, *Improving Students' Learning With Effective Learning Techniques*](https://www.psychologicalscience.org/news/releases/which-study-strategies-make-the-grade.html) · [Roediger & Karpicke 2006](https://psychology.ecu.edu/wp-content/pv-uploads/sites/216/2019/03/Roediger-Karpicke-2006.pdf) · [Cepeda et al. 2008](https://pubmed.ncbi.nlm.nih.gov/19076480/) · [Rohrer, Dedrick & Burgess 2014](https://www.gwern.net/doc/psychology/spaced-repetition/2014-rohrer.pdf)",
  ].join("\n");

  function viewSheet() {
    const secs = (DATA.sheet && DATA.sheet.sections) || [];
    const revealed = !!(session && session.type === "sheet");
    return '<div class="col"><div class="head"><div class="eyebrow">Day 4</div><h1>Summary sheet</h1>' +
      '<p class="lede">Make your own first. On one sheet of paper, write every piece of syntax you can remember, grouped by topic, from memory. Only then open the reference and add what you missed in a different colour. The page you write is what you skim on exam morning.</p></div>' +
      (revealed || (S.steps["4:sheet"] || S.steps["5:sheet"]) ? secs.map((s) => '<div class="card"><h2>' + esc(s.title) + '</h2><div class="prose">' + md(s.md) + "</div></div>").join("")
        : '<div class="card empty"><p>Written your page from memory?</p><div class="row" style="justify-content:center"><button class="btn primary" data-act="sheet-show">Yes, show the reference sheet</button></div></div>') +
      "</div>";
  }

  function viewLibrary() {
    let h = "";
    for (let n = 1; n <= 6; n++) {
      const d = dayData[n]; if (!d) continue;
      h += '<div class="card"><h3>Day ' + n + ": " + esc(d.title) + '</h3><div class="topiclist">' + d.topics.map((t) =>
        '<a href="#topic-' + esc(t.id) + '" class="' + (S.topicsDone[t.id] ? "done" : "") + '"><span>' + esc(t.title) + "</span>" + prioChip(t.priority) + "</a>").join("") +
        '</div><div class="row small"><a href="#cards-' + n + '">Flashcards</a><a href="#quiz-' + n + '">Quiz</a><a href="#write-' + n + '">Writing</a><a href="#drills-' + n + '">Drills</a></div></div>';
    }
    return '<div class="col"><div class="head"><h1>All lessons</h1><p class="lede">Every topic from the course notebooks, in course order.</p></div>' + (h || '<div class="card empty">No lessons loaded.</div>') + "</div>";
  }

  function viewData() {
    const n = Object.keys(S.srs).length;
    const opts = ['<option value="">Follow the calendar (Day ' + (calendarDay() === 0 ? 1 : Math.min(LAST_DAY, calendarDay())) + " today)</option>"];
    for (let i = 1; i <= LAST_DAY; i++) opts.push('<option value="' + i + '"' + (S.dayOverride === i ? " selected" : "") + ">Treat today as Day " + i + "</option>");
    return '<div class="col"><div class="head"><h1>Progress &amp; backup</h1><p class="lede">Your progress is saved in this browser on this laptop. Copy a backup here if you switch browsers or clear site data.</p></div>' +
      '<div class="stats">' + stat(n, "items in your review deck") + stat(Object.keys(S.topicsDone).length, "lessons learned") + stat(Object.keys(S.write).length, "scripts marked") + "</div>" +
      '<div class="card"><h3>Behind or ahead?</h3><p class="small muted" style="margin:0">If you lose a day, shift the plan so <i>Today</i> shows the day you are actually on.</p><div class="row"><select id="dayOverride" class="btn">' + opts.join("") + "</select></div></div>" +
      '<div class="card"><h3>Theme</h3><div class="row"><button class="btn" data-act="theme" data-v="">Match system</button><button class="btn" data-act="theme" data-v="light">Light</button><button class="btn" data-act="theme" data-v="dark">Dark</button></div></div>' +
      '<div class="card"><h3>Back up or restore</h3><div class="row"><button class="btn" data-act="export">Show backup text</button><button class="btn" data-act="copy-export">Copy backup</button><button class="btn" data-act="import">Restore from pasted text</button></div>' +
      '<textarea class="ans" id="backup" spellcheck="false" placeholder="Your backup appears here. To restore, paste a backup here and press Restore."></textarea></div>' +
      '<div class="card"><h3>Start over</h3><p class="small muted" style="margin:0">Deletes all progress in this browser.</p><div class="row"><button class="btn bad" data-act="reset-ask">Reset all progress</button><span id="resetConfirm"></span></div></div></div>';
  }

  function notFound() { return '<div class="col"><div class="card empty"><h3>Page not found</h3><a class="btn" href="#today">Go to Today</a></div></div>'; }

  // ---------------------------------------------------------------- past-paper practice
  // C questions from past finals plus a close variant of each, one at a time.
  // Claude marks each answer (the `sample` capability); where that is unavailable, the student marks it.
  const PRACTICE = (DATA.practice && DATA.practice.questions) || [];
  const PAPERS = (DATA.practice && DATA.practice.papers) || [];
  const pq = {};
  PRACTICE.forEach((q) => { pq[q.id] = q; });
  let samplePromise = null;
  let selfMarking = false; // true once Claude marking is refused or unavailable in this view
  function getSample() {
    if (!samplePromise) {
      samplePromise = window.claude && typeof window.claude.use === "function"
        ? window.claude.use("sample").catch(() => null) : Promise.resolve(null);
    }
    return samplePromise;
  }
  const pStatus = (id) => S.practice.status[id];
  const mastered = (id) => !!(pStatus(id) && pStatus(id).correct);
  const paperLabel = (q) => q.source + (q.variantOf ? "" : "");

  // The round keeps new questions (`fresh`) and missed ones (`retry`, each due again 4 answers later)
  // apart, so missed questions return on schedule while new ones keep coming.
  const practiceLeft = (s) => s.fresh.length + s.retry.length + (s.cur ? 1 : 0);
  function practicePick(s) {
    // At most every other question is a retry while new questions remain.
    let k = s.lastWasRetry && s.fresh.length ? -1 : s.retry.findIndex((r) => r.due <= s.n);
    if (k < 0 && !s.fresh.length && s.retry.length) k = 0;
    s.lastWasRetry = k >= 0;
    s.cur = k >= 0 ? s.retry.splice(k, 1)[0].id : (s.fresh.shift() || null);
  }
  // An original and its variant form a pair; "unique" mode asks one question per pair you haven't touched yet.
  const pairOf = (q) => q.variantOf || q.id;
  function uniqueQueue(papers) {
    const groups = {};
    PRACTICE.filter((q) => papers.indexOf(q.sourceId) >= 0).forEach((q) => { (groups[pairOf(q)] = groups[pairOf(q)] || []).push(q); });
    const out = [];
    Object.values(groups).forEach((g) => {
      if (g.some((q) => pStatus(q.id))) return;
      out.push((g.find((q) => !q.variantOf) || g[0]).id);
    });
    return shuffle(out);
  }
  function practiceQueue(mode, papers) {
    if (mode === "unique") return uniqueQueue(papers);
    const pool = PRACTICE.filter((q) => papers.indexOf(q.sourceId) >= 0).filter((q) => {
      if (mode === "missed") return pStatus(q.id) && !pStatus(q.id).correct;
      if (mode === "all") return true;
      return !mastered(q.id);
    });
    const originals = shuffle(pool.filter((q) => !q.variantOf).map((q) => q.id));
    const out = originals.slice();
    shuffle(pool.filter((q) => q.variantOf).map((q) => q.id)).forEach((id) => {
      // A variant comes a few questions after its original, so it tests recall rather than copying.
      const at = out.indexOf(pq[id].variantOf);
      const pos = at < 0 ? Math.floor(Math.random() * (out.length + 1)) : Math.min(out.length, at + 3 + Math.floor(Math.random() * 6));
      out.splice(pos, 0, id);
    });
    return out;
  }

  function recycleToggle() {
    return '<label class="toggle"><input type="checkbox" id="pRecycle"' + (S.practice.recycle ? " checked" : "") + "><span>Bring back questions I get wrong</span></label>";
  }
  function viewPractice() {
    if (!PRACTICE.length) return '<div class="col"><div class="card empty"><h3>The practice bank isn\'t loaded yet</h3></div></div>';
    if (session && session.type === "practice") return practiceQuestionView();
    const total = PRACTICE.length;
    const done = PRACTICE.filter((q) => mastered(q.id)).length;
    const missed = PRACTICE.filter((q) => pStatus(q.id) && !pStatus(q.id).correct).length;
    const chosen = S.practice.papers || PAPERS.map((p) => p.sourceId);
    const paperRows = PAPERS.map((p) => {
      const qs = PRACTICE.filter((q) => q.sourceId === p.sourceId);
      const m = qs.filter((q) => mastered(q.id)).length;
      return '<label><input type="checkbox" data-paper="' + esc(p.sourceId) + '"' + (chosen.indexOf(p.sourceId) >= 0 ? " checked" : "") + "><span><b>" + esc(p.source) + "</b>" +
        (p.note ? ' <span class="muted small">' + esc(p.note) + "</span>" : "") + '</span><span class="m">' + m + "/" + qs.length + "</span></label>";
    }).join("");
    return '<div class="col"><div class="head"><div class="eyebrow">Exam practice</div><h1>Past-paper practice</h1>' +
      '<p class="lede">C questions from past finals on your professor\'s list, worded as on the paper, plus one close variant of each. One question at a time: write your answer, and Claude marks it. Any correct solution counts, not just the model answer. Each question is asked once; switch on the option below to have the ones you get wrong come back a few questions later.</p></div>' +
      '<div class="stats">' + stat(done + " / " + total, "questions answered correctly") + stat(missed, "got wrong, waiting for another try") + stat(total - done - missed, "not tried yet") + "</div>" +
      '<div class="card"><h3>Which papers?</h3><div class="rubric" id="paperPick">' + paperRows + "</div>" +
      '<p class="small muted" style="margin:0">The most recent finals are closest to your exam.</p></div>' +
      '<div class="row">' + recycleToggle() + (S.practice.recycle ? '<span class="small muted">Switch this off if you don\'t want repeats.</span>' : "") + "</div>" +
      '<p class="small muted" style="margin:0"><b>New questions only</b> asks one question from each original-and-variant pair, and skips every pair you\'ve already answered either half of, so nothing repeats.</p>' +
      '<div class="row"><button class="btn primary" data-act="p-start" data-mode="unique">New questions only (' + uniqueQueue(chosen).length + ")</button>" +
      '<button class="btn" data-act="p-start" data-mode="todo">Everything not yet correct, variants included</button>' +
      (missed ? '<button class="btn" data-act="p-start" data-mode="missed">Only the ones I got wrong (' + missed + ")</button>" : "") +
      '<button class="btn ghost" data-act="p-start" data-mode="all">All questions, including correct ones</button></div>' +
      '<div class="callout why"><div class="lab">How marking works</div><div class="prose"><p>In the web version, the first time you submit, Claude asks your permission to mark answers. Each answer uses a little of your Claude usage and takes a few seconds to mark. In the local <code>index.html</code> file, or if you decline, you mark yourself against the model answer and rubric instead.</p></div></div></div>';
  }

  function practiceQuestionView() {
    const s = session;
    if (!s.cur) {
      const right = s.log.filter((x) => x.correct).length;
      return '<div class="col"><div class="card empty"><h2>Round complete</h2><p>' + s.log.length + " answers marked, " + right + " correct." + (s.log.length > right ? " Use \"Only the ones I got wrong\" to retry the rest." : "") + "</p>" +
        '<div class="row" style="justify-content:center"><button class="btn primary" data-act="p-exit">Back to practice</button></div></div></div>';
    }
    const q = pq[s.cur];
    const st = pStatus(q.id);
    const long = q.kind === "long";
    let body = '<div class="row"><span class="chip accent">' + esc(q.source) + '</span><span class="chip">' + (long ? "Long answer" : "Short answer") + '</span><span class="marks">' + q.marks + " mark" + (q.marks === 1 ? "" : "s") + "</span>" +
      (st && st.tries && (s.phase === "answer" ? !st.correct : st.tries > 1) ? '<span class="chip high">try ' + (s.phase === "answer" ? st.tries + 1 : st.tries) + "</span>" : "") + "</div>" +
      '<div class="prose">' + md(q.prompt) + "</div>";
    const locked = s.phase !== "answer";
    body += '<textarea class="ans' + (long ? " tall" : "") + '" id="pans" spellcheck="false" placeholder="' + (long ? "Write your full answer, as you would on the exam paper." : "Your answer") + '"' + (locked ? " readonly" : "") + ">" + esc(s.draft || "") + "</textarea>";
    if (s.phase === "answer") {
      body += '<div class="row"><button class="btn primary" data-act="p-submit">' + (selfMarking ? "Check my answer" : "Submit for marking") + ' <kbd>Ctrl+Enter</kbd></button>' +
        '<button class="btn ghost" data-act="p-dontknow">I don\'t know: show me</button><span class="spacer"></span><button class="btn ghost" data-act="p-skip">Skip for now</button></div>';
    } else if (s.phase === "grading") {
      body += '<div class="row"><span class="verdict">Claude is marking your answer…</span><span class="spacer"></span><button class="btn ghost" data-act="p-stop">Stop</button></div>';
    } else if (s.phase === "error") {
      body += '<div class="callout pitfall"><div class="lab">Couldn\'t mark it</div><div class="prose"><p>' + esc(s.error) + '</p></div></div>' +
        '<div class="row"><button class="btn primary" data-act="p-submit">Try again</button><button class="btn" data-act="p-self">Mark it myself</button></div>';
    } else if (s.phase === "self") {
      body += practiceAnswerKey(q) +
        '<div class="row"><span>Compare carefully. Would your answer get full marks?</span><button class="btn bad" data-act="p-selfmark" data-ok="0">No</button><button class="btn good" data-act="p-selfmark" data-ok="1">Yes</button></div>';
    } else if (s.phase === "result") {
      const r = s.result;
      body += '<div class="callout ' + (r.correct ? "try" : "pitfall") + '"><div class="lab">' + (r.correct ? "Correct" : r.gaveUp ? "Here's the answer" : "Not yet") +
        (r.score != null ? " · " + r.score + " / " + q.marks : "") + "</div>" +
        (r.feedback ? '<div class="prose">' + md(r.feedback) + "</div>" : "") +
        (r.correct ? "" : '<p class="small" style="margin:0">' + (S.practice.recycle ? "This question comes back in a few questions. Study the model answer, then write it from memory next time." : "Study the model answer below. It stays on your \"got wrong\" list, so you can retry it later with \"Only the ones I got wrong\".") + "</p>") + "</div>" +
        (r.correct ? '<details><summary class="small">Show the model answer</summary>' + practiceAnswerKey(q) + "</details>" : practiceAnswerKey(q)) +
        '<div class="row">' + (!r.correct && !r.gaveUp ? '<button class="btn ghost" data-act="p-override">The marking is wrong: count mine as correct</button>' : "") +
        '<span class="spacer"></span><button class="btn primary" data-act="p-next">Next question <kbd>Enter</kbd></button></div>';
    }
    const total = PRACTICE.length, done = PRACTICE.filter((x) => mastered(x.id)).length;
    return '<div class="col"><div class="head"><div class="eyebrow"><a href="#practice" data-act="p-exit">Past-paper practice</a> · ' + practiceLeft(s) + " left in this round · " + done + "/" + total + " correct overall</div>" +
      '<div class="progress"><i style="width:' + Math.round((done / total) * 100) + '%"></i></div><div class="row">' + recycleToggle() + '</div></div><div class="card">' + body + "</div></div>";
  }
  function practiceAnswerKey(q) {
    return '<div class="callout check"><div class="lab">Model answer</div><div class="prose">' + md(q.answer) + "</div></div>" +
      (q.rubric && q.rubric.length ? '<div class="prose small"><b>Marking scheme</b><ul>' + q.rubric.map((x) => "<li>" + inline(x.item) + " (" + x.marks + ")</li>").join("") + "</ul></div>" : "") +
      (q.grading ? '<div class="prose small"><b>Grading notes:</b> ' + md(q.grading) + "</div>" : "");
  }

  function practiceRecord(id, correct, score) {
    const st = S.practice.status[id] || { tries: 0, correct: false };
    st.tries++; st.correct = correct; st.last = today();
    if (score != null) st.best = Math.max(st.best || 0, score);
    S.practice.status[id] = st;
    save();
  }
  function practiceFinish(result) {
    const s = session; const id = s.cur;
    s.result = result; s.phase = "result"; s.n++;
    s.log.push({ id: id, correct: result.correct });
    practiceRecord(id, result.correct, result.score);
  }
  async function practiceGrade() {
    const s = session; const q = pq[s.cur];
    const answer = (s.draft || "").trim();
    if (!answer) { toast("Write an answer first, or choose \"I don't know\"."); return; }
    if (selfMarking) { s.phase = "self"; rerender(true); return; }
    s.phase = "grading"; s.ctl = new AbortController(); rerender(true);
    const sample = await getSample();
    if (session !== s) return;
    if (!sample) { selfMarking = true; s.phase = "self"; rerender(true); return; }
    const prompt = [
      "You are a careful, fair teaching assistant marking one answer on a CISC220 (Queen's University) final exam about C programming (C17, gcc on Linux). The exam is handwritten, closed book.",
      "",
      "Mark the student's answer out of " + q.marks + ". ANY correct answer earns full marks, even if it is written differently from the model answer: check whether the student's code would compile and actually do what the question asks (trace it on the question's examples and on the edge cases it mentions).",
      "Deduct marks for real errors: wrong output, code that would not compile, undefined behaviour (out-of-bounds access, a missing '\\0', using freed or uninitialised memory), memory leaks where the question cares about them, and wrong types or format specifiers. Follow the grading notes and the marking scheme. Ignore handwriting-style slips that don't change meaning (a missing #include the question didn't ask for, curly quotes, spacing), and don't require comments.",
      "",
      "QUESTION (" + q.source + ", " + q.marks + " marks):",
      q.prompt,
      "",
      "MODEL ANSWER:",
      q.answer,
      "",
      "GRADING NOTES:",
      q.grading || "(none)",
      "",
      "MARKING SCHEME:",
      (q.rubric || []).map((x) => "- (" + x.marks + ") " + x.item).join("\n") || "(none)",
      "",
      "STUDENT'S ANSWER (between the lines):",
      "-----",
      answer,
      "-----",
      "",
      'Reply with only a JSON object: {"score": <number from 0 to ' + q.marks + '>, "feedback": "<1 to 4 short sentences for the student: say what is right, and exactly what is wrong and how to fix it. Use backticks for code. If it is fully correct, say so in one sentence.>"}',
    ].join("\n");
    try {
      const r = await sample.json(prompt, { signal: s.ctl.signal, modelTier: "default" });
      if (session !== s) return;
      let score = Number(r && r.score);
      if (!isFinite(score)) score = 0;
      score = Math.max(0, Math.min(q.marks, Math.round(score * 2) / 2));
      const correct = score >= q.marks || (q.marks >= 4 && score >= q.marks - 1);
      practiceFinish({ score: score, correct: correct, feedback: String((r && r.feedback) || "") });
    } catch (e) {
      if (session !== s) return;
      const code = e && e.code;
      if (code === "cancelled") { s.phase = "answer"; }
      else if (["not_granted", "sampling_disabled", "not_declared", "capability_disabled", "capability_removed"].indexOf(code) >= 0) {
        selfMarking = true; s.phase = "self";
        toast("Claude marking isn't available here, so mark this one yourself.");
      } else {
        s.phase = "error";
        s.error = code === "rate_limited" ? "Claude is busy, or you've reached a usage limit. Wait a minute and try again, or mark this one yourself."
          : code === "session_expired" ? "You've been signed out of Claude. Sign in again, then try again."
          : "The marking didn't come back properly. Try again, or mark this one yourself.";
      }
    }
    if (session === s) rerender(true);
  }
  function practiceNext() {
    const s = session;
    if (s.result && !s.result.correct && S.practice.recycle) s.retry.push({ id: s.cur, due: s.n + 4 });
    practicePick(s);
    s.phase = "answer"; s.result = null; s.draft = ""; s.error = null;
    rerender(); window.scrollTo(0, 0);
  }
  function practiceAction(act, el) {
    const s = session;
    switch (act) {
      case "p-start": {
        const papers = $$("#paperPick input").filter((i) => i.checked).map((i) => i.dataset.paper);
        if (!papers.length) { toast("Pick at least one paper."); return; }
        S.practice.papers = papers; save();
        const queue = practiceQueue(el.dataset.mode, papers);
        if (!queue.length) { toast(el.dataset.mode === "missed" ? "Nothing to retry: you've got them all right." : el.dataset.mode === "unique" ? "You've answered at least one question from every pair. Try \"Everything not yet correct\"." : "Everything in those papers is already correct. Choose \"All questions\" to go again."); return; }
        session = { type: "practice", route: "practice", fresh: queue, retry: [], n: 0, cur: null, phase: "answer", draft: "", log: [] };
        practicePick(session);
        rerender(); window.scrollTo(0, 0); break;
      }
      case "p-exit": session = null; rerender(); break;
      case "p-submit": practiceGrade(); break;
      case "p-stop": if (s && s.ctl) s.ctl.abort(); break;
      case "p-self": s.phase = "self"; rerender(true); break;
      case "p-selfmark": practiceFinish({ score: null, correct: el.dataset.ok === "1", feedback: "" }); rerender(true); break;
      case "p-dontknow": practiceFinish({ score: 0, correct: false, gaveUp: true, feedback: "" }); rerender(true); break;
      case "p-skip": { s.fresh.push(s.cur); practicePick(s); s.draft = ""; rerender(); break; }
      case "p-override": {
        const id = s.cur; s.result.correct = true; s.log[s.log.length - 1].correct = true;
        S.practice.status[id].correct = true; save(); rerender(true); break;
      }
      case "p-next": practiceNext(); break;
      default: break;
    }
  }

  // ---------------------------------------------------------------- router
  function route() {
    const h = location.hash.replace(/^#/, "") || "today";
    if (session && session.route && session.route !== h) session = null;
    clearInterval(timerHandle);
    let html;
    let m;
    if (h === "today") html = viewToday();
    else if (h === "plan") html = viewPlan();
    else if (h === "review") html = session && session.route === h ? sessionView() : viewReview();
    else if (h === "review-missed") html = session && session.route === h ? sessionView() : viewReview("missed");
    else if ((m = h.match(/^day-(\d+)$/))) html = viewDay(+m[1]);
    else if ((m = h.match(/^topic-(.+)$/))) html = viewTopic(m[1]);
    else if ((m = h.match(/^cards-(\d+)$/))) html = session && session.route === h && session.type === "cards" ? cardSessionView() : (session = null, viewCards(+m[1]));
    else if ((m = h.match(/^quiz-(\d+)$/))) html = viewQuiz(+m[1]);
    else if ((m = h.match(/^write-(\d+)$/))) html = viewWrite(+m[1]);
    else if ((m = h.match(/^(?:drills|lab)-(\d+)$/))) html = viewDrills(+m[1]);
    else if (h === "a4") html = viewA4();
    else if ((m = h.match(/^dump-(\d+)$/))) html = viewDump(+m[1]);
    else if ((m = h.match(/^mock-(.+)$/))) html = viewMock(m[1]);
    else if (h === "weak") html = viewWeak();
    else if (h === "practice") html = viewPractice();
    else if (h === "sheet") html = viewSheet();
    else if (h === "library") html = viewLibrary();
    else if (h === "data") html = viewData();
    else html = notFound();
    if (session && !session.route) session.route = h;
    main().innerHTML = html;
    renderRail();
    if ((m = h.match(/^mock-(.+)$/)) && S.mocks[m[1]] && S.mocks[m[1]].started && !S.mocks[m[1]].marking) startTimer(m[1]);
    const ta = $("#qans"); if (ta && !ta.readOnly) ta.focus();
  }
  function sessionView() { return session.type === "cards" ? cardSessionView() : quizSessionView(); }
  function rerender(keepScroll) {
    const y = window.scrollY;
    route();
    if (keepScroll) window.scrollTo(0, y);
  }

  function startTimer(id) {
    const m = mocks[id]; const r = S.mocks[id];
    const end = r.started + m.minutes * 60000;
    const tick = () => {
      const el = $("#mockTimer"); if (!el) return clearInterval(timerHandle);
      const left = Math.max(0, end - Date.now());
      const mm = Math.floor(left / 60000), ss = Math.floor((left % 60000) / 1000);
      el.textContent = String(mm).padStart(2, "0") + ":" + String(ss).padStart(2, "0");
      el.classList.toggle("low", left < 5 * 60000);
      if (left <= 0) { clearInterval(timerHandle); el.textContent = "Time's up: pens down"; }
    };
    tick();
    timerHandle = setInterval(tick, 1000);
  }

  // ---------------------------------------------------------------- actions
  function answerQuiz(ok, extra) {
    const s = session; const id = s.queue[s.i];
    s.answered = true;
    s.results.push(Object.assign({ id: id, ok: ok }, extra || {}));
    if (ok != null) rate(id, ok ? 2 : 0);
    rerender(true);
  }
  document.addEventListener("click", (e) => {
    const el = e.target.closest("[data-act]");
    if (!el) return;
    const act = el.dataset.act;
    const s = session;
    if (act.indexOf("p-") === 0) { if (act === "p-exit") e.preventDefault(); practiceAction(act, el); return; }
    switch (act) {
      case "toggle-step": {
        const k = el.dataset.day + ":" + el.dataset.key;
        S.steps[k] = !stepDone(+el.dataset.day, el.dataset.key);
        save(); rerender(true); break;
      }
      case "reveal": { const t = document.getElementById(el.dataset.target); if (t) { t.hidden = false; el.remove(); } break; }
      case "topic-done": {
        const id = el.dataset.id;
        if (S.topicsDone[id]) delete S.topicsDone[id]; else S.topicsDone[id] = today();
        save(); rerender(true);
        if (S.topicsDone[id]) toast("Lesson marked as learned");
        break;
      }
      case "show-back": if (s) { s.shown = true; rerender(true); } break;
      case "rate": {
        if (!s) break;
        const g = +el.dataset.g; const id = s.queue.shift();
        rate(id, g);
        if (g === 0) { s.queue.splice(Math.min(3, s.queue.length), 0, id); s.again++; } else s.done++;
        s.shown = false;
        if (!s.queue.length && s.review) { S.reviewDone[today()] = true; save(); }
        rerender(); break;
      }
      case "cards-all": {
        const n = +el.dataset.day;
        startCards(shuffle(dayData[n].flashcards.map((c) => c.id)), "Day " + n + " all cards", "#day-" + n);
        session.key = "cards-" + n; session.route = "cards-" + n; rerender(); break;
      }
      case "quiz-start": { session = buildQuiz(+el.dataset.day); session.route = "quiz-" + el.dataset.day; rerender(); break; }
      case "mcq": { const q = items[s.queue[s.i]]; const k = +el.dataset.k; answerQuiz(k === q.answer, { pick: k }); break; }
      case "quiz-submit": {
        const q = items[s.queue[s.i]]; const text = ($("#qans") || {}).value || "";
        if (q.type === "output") answerQuiz(normOut(text) === normOut(q.answer), { text: text });
        else answerQuiz(null, { text: text });
        break;
      }
      case "self": {
        const v = +el.dataset.ok; const r = s.results[s.results.length - 1];
        r.ok = v === 2; rate(r.id, v === 2 ? 2 : v === 1 ? 1 : 0);
        nextQuestion(); break;
      }
      case "override": { const r = s.results[s.results.length - 1]; r.ok = true; rate(r.id, 2); nextQuestion(); break; }
      case "quiz-next": nextQuestion(); break;
      case "review-cards": case "review-quiz": {
        const missed = el.dataset.mode === "missed";
        const route = missed ? "review-missed" : "review";
        if (act === "review-cards") {
          const ids = missed ? missedItems().filter((id) => items[id].kind === "card") : dueItems("card");
          startCards(interleave(ids), missed ? "Missed cards" : "Spaced review", "#" + route);
        } else {
          const ids = missed ? missedItems().filter((id) => items[id].kind === "quiz") : dueItems("quiz");
          session = { type: "quiz", queue: interleave(ids), i: 0, results: [], answered: false, back: "#" + route, label: missed ? "Missed questions" : "Mixed review" };
        }
        session.review = !missed; session.route = route; rerender(); break;
      }
      case "review-mark": S.reviewDone[today()] = true; save(); rerender(true); break;
      case "write-studied": { if (!session || session.type !== "write") session = { type: "write", open: {}, studied: {}, route: location.hash.slice(1) }; session.studied[el.dataset.id] = true; rerender(true); break; }
      case "write-check": {
        if (!session || session.type !== "write") session = { type: "write", open: {}, studied: {}, route: location.hash.slice(1) };
        session.open[el.dataset.id] = true; rerender(true); break;
      }
      case "write-save": {
        const id = el.dataset.id; const w = writes[id];
        const box = $('[data-rubric="' + id + '"]');
        const ticks = box ? $$("input", box).map((i) => i.checked) : [];
        const max = (w.rubric || []).reduce((a, x) => a + x.marks, 0);
        const score = (w.rubric || []).reduce((a, x, j) => a + (ticks[j] ? x.marks : 0), 0);
        const ok = score / Math.max(1, max) >= 0.7;
        S.write[id] = { score: score, max: max, ticks: ticks, at: today(), redo: ok ? null : addDays(today(), 1) };
        const ts = S.topicStats[w.topic] || { right: 0, wrong: 0 };
        if (ok) ts.right++; else ts.wrong++;
        S.topicStats[w.topic] = ts;
        save(); toast("Saved: " + score + "/" + max + (ok ? "" : ". On tomorrow's rewrite list")); rerender(true); break;
      }
      case "drill-save": { const v = ($("#drillScore") || {}).value || ""; if (v.trim()) { S.drills[el.dataset.day] = v.trim(); save(); toast("Drill score saved"); rerender(true); } break; }
      case "dump-save": {
        const n = +el.dataset.day; S.dumps[n] = ($("#dumpText") || {}).value || ""; save();
        session = { type: "dump", day: n, route: location.hash.slice(1) }; rerender(true); toast("Saved"); break;
      }
      case "mock-start": { S.mocks[el.dataset.id] = Object.assign(S.mocks[el.dataset.id] || {}, { started: Date.now(), marking: false, ticks: {} }); save(); rerender(); break; }
      case "mock-mark": { S.mocks[el.dataset.id].marking = true; save(); rerender(); window.scrollTo(0, 0); break; }
      case "mock-save": { const id = el.dataset.id; S.mocks[id].score = mockScore(id); S.mocks[id].at = today(); save(); toast("Score saved"); rerender(true); break; }
      case "mock-reset": { delete S.mocks[el.dataset.id]; save(); rerender(); break; }
      case "sheet-show": session = { type: "sheet", route: "sheet" }; rerender(); break;
      case "theme": {
        S.theme = el.dataset.v || null; save(); applyTheme(); break;
      }
      case "export": $("#backup").value = JSON.stringify(S); break;
      case "copy-export": {
        const txt = JSON.stringify(S); $("#backup").value = txt;
        if (navigator.clipboard) navigator.clipboard.writeText(txt).then(() => toast("Backup copied"), () => { $("#backup").select(); toast("Select the text and copy it"); });
        else { $("#backup").select(); toast("Select the text and copy it"); }
        break;
      }
      case "import": {
        try { const v = JSON.parse($("#backup").value); if (!v || typeof v !== "object" || !v.srs) throw new Error("bad"); S = Object.assign(blank(), v); save(); toast("Progress restored"); rerender(); }
        catch (err) { toast("That text isn't a valid backup. Paste the whole backup and try again."); }
        break;
      }
      case "reset-ask": $("#resetConfirm").innerHTML = '<button class="btn bad" data-act="reset">Yes, delete everything</button>'; break;
      case "reset": S = blank(); save(); session = null; toast("Progress reset"); rerender(); break;
      default: break;
    }
  });
  function nextQuestion() { session.i++; session.answered = false; rerender(); window.scrollTo(0, 0); }

  document.addEventListener("change", (e) => {
    const t = e.target;
    if (t.id === "dayOverride") { S.dayOverride = t.value ? +t.value : null; save(); rerender(true); }
    if (t.dataset && t.dataset.a4) { S.a4[t.dataset.a4] = t.checked; save(); renderRail(); }
    if (t.id === "pRecycle") { S.practice.recycle = t.checked; save(); toast(t.checked ? "Questions you get wrong will come back" : "Each question is asked once"); }
    const mk = t.closest("[data-mock]");
    if (mk && t.type === "checkbox") {
      const id = mk.dataset.mock, part = mk.dataset.part;
      const r = S.mocks[id]; r.ticks = r.ticks || {}; r.ticks[part] = $$("input", mk).map((i) => i.checked);
      save(); const sc = $("#mockScore"); if (sc) sc.textContent = mockScore(id);
    }
  });
  document.addEventListener("input", (e) => {
    const t = e.target;
    if (t.dataset && t.dataset.draft) { S.drafts[t.dataset.draft] = t.value; save(); }
    if (t.id === "pans" && session && session.type === "practice") session.draft = t.value;
  });
  document.addEventListener("keydown", (e) => {
    const t = e.target;
    if (t.tagName === "TEXTAREA" && e.key === "Tab" && !e.shiftKey && t.classList.contains("ans")) {
      e.preventDefault();
      const a = t.selectionStart, b = t.selectionEnd;
      t.value = t.value.slice(0, a) + "    " + t.value.slice(b);
      t.selectionStart = t.selectionEnd = a + 4;
      t.dispatchEvent(new Event("input", { bubbles: true }));
      return;
    }
    if (!session) return;
    if (session.type === "practice") {
      if (e.key === "Enter" && (e.ctrlKey || e.metaKey) && session.phase === "answer") { e.preventDefault(); practiceGrade(); return; }
      if (e.key === "Enter" && session.phase === "result" && t.tagName !== "TEXTAREA" && t.tagName !== "INPUT") { e.preventDefault(); practiceNext(); }
      return;
    }
    if (session.type === "quiz" && session.i < session.queue.length) {
      if (e.key === "Enter" && (e.ctrlKey || e.metaKey) && !session.answered) { e.preventDefault(); const b = $('[data-act="quiz-submit"]'); if (b) b.click(); return; }
      if (t.tagName === "TEXTAREA" || t.tagName === "INPUT") return;
      if (e.key === "Enter" && session.answered) { const b = $('[data-act="quiz-next"]'); if (b) { e.preventDefault(); b.click(); } return; }
      const q = items[session.queue[session.i]];
      if (q.type === "mcq" && !session.answered && /^[1-4a-dA-D]$/.test(e.key)) {
        const k = /\d/.test(e.key) ? +e.key - 1 : "abcd".indexOf(e.key.toLowerCase());
        const b = $('[data-act="mcq"][data-k="' + k + '"]'); if (b) b.click();
      }
    } else if (session.type === "cards" && session.queue.length) {
      if (t.tagName === "TEXTAREA" || t.tagName === "INPUT") return;
      if (!session.shown && (e.key === " " || e.key === "Enter")) { e.preventDefault(); const b = $('[data-act="show-back"]'); if (b) b.click(); }
      else if (session.shown && /^[1-4]$/.test(e.key)) { const b = $('[data-act="rate"][data-g="' + (+e.key - 1) + '"]'); if (b) b.click(); }
    }
  });
  document.addEventListener("click", (e) => {
    if (e.target.id === "menuBtn") {
      const r = $("#rail"); r.classList.toggle("open"); e.target.setAttribute("aria-expanded", r.classList.contains("open"));
    } else if (e.target.closest(".nav a")) { $("#rail").classList.remove("open"); }
  });

  function applyTheme() {
    if (S.theme) document.documentElement.setAttribute("data-theme", S.theme);
    else document.documentElement.removeAttribute("data-theme");
  }

  window.addEventListener("hashchange", () => { route(); window.scrollTo(0, 0); });
  applyTheme();
  route();
})();
