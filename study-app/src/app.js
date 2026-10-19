/* CISC220 Bash Sprint: an 8-day study planner built on retrieval practice and spaced repetition.
   All course content is in window.STUDY_DATA (inlined at build time from study-app/content/*.json). */
(function () {
  "use strict";

  const DATA = window.STUDY_DATA || { days: [], mocks: { exams: [] }, sheet: { sections: [] } };
  const EXAM_DATE = "2026-10-27";
  const DAY1_DATE = "2026-10-19";
  const REPO = "https://github.com/FallingBrook/CISC220_current/blob/main/";
  const BRANCH = "claude/cisc220-bash-study-app-1w7tyo";
  const STORE_KEY = "cisc220-bash-sprint-v1";
  const INTERVALS = [0, 1, 2, 4, 7]; // days until next review, by box

  // ---------------------------------------------------------------- state
  const blank = () => ({
    v: 1, srs: {}, steps: {}, topicsDone: {}, quizRuns: {}, write: {}, drills: {}, dumps: {}, mocks: {},
    topicStats: {}, reviewDone: {}, drafts: {}, dayOverride: null, theme: null,
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
  // Which plan day is today (1..8); 0 = before the plan starts, 9 = exam day or later.
  function calendarDay() {
    const n = diffDays(DAY1_DATE, today()) + 1;
    if (n < 1) return 0;
    return Math.min(n, 9);
  }
  function currentDay() {
    if (S.dayOverride) return S.dayOverride;
    const c = calendarDay();
    return c === 0 ? 1 : Math.min(c, 8);
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

  const TAG_NOTEBOOK = {
    paths: "filesystem", commands: "commands", globs: "filename_expansion", quoting: "quoting", files: "files",
    permissions: "permissions", streams: "streams", expansions: "expansions", tr: "tr",
    scripts: "introduction_to_bash_scripting", variables: "variables", strings: "strings", arithmetic: "arithmetic",
    regex: "regex", conditionals: "conditional_statements", loops: "loops", arrays: "arrays", functions: "functions",
  };
  function topicForTag(tag) {
    const nb = TAG_NOTEBOOK[tag];
    return Object.values(topics).find((t) => (t.notebook || "").indexOf("/" + nb + ".ipynb") >= 0);
  }

  // ---------------------------------------------------------------- the plan
  const DAY_META = {
    1: { mins: 150 }, 2: { mins: 150 }, 3: { mins: 150 }, 4: { mins: 165 }, 5: { mins: 160 }, 6: { mins: 165 },
    7: { mins: 170, title: "Mock exam A and fixing weak spots", goal: "Sit a full 50-minute mock under exam conditions, mark it honestly, then repair the topics it exposed." },
    8: { mins: 150, title: "Mock exam B, summary sheet, early night", goal: "Sit the second mock, write your own one-page summary from memory, and go to bed on time." },
  };
  function dayTitle(n) { return (dayData[n] && dayData[n].title) || (DAY_META[n] && DAY_META[n].title) || "Day " + n; }
  function dayGoal(n) { return (dayData[n] && dayData[n].goal) || (DAY_META[n] && DAY_META[n].goal) || ""; }

  function stepsFor(n) {
    const steps = [];
    if (n === 1) steps.push({ key: "setup", title: "Set up your terminal drills", mins: 10, href: "drills-0",
      desc: "Get the drill tool onto your Ubuntu laptop and do the 4-task warm-up (Day 0). You'll use it every day." });
    if (n >= 2) steps.push({ key: "review", title: "Warm-up: spaced review", mins: 25, href: "review",
      desc: "Answer the cards and questions that are due from earlier days before learning anything new. Recalling before the new material arrives is what makes yesterday's work stick." });
    if (n <= 6) {
      const d = dayData[n];
      const nt = d ? d.topics.length : 0;
      steps.push({ key: "learn", title: "Learn: " + nt + " topic" + (nt === 1 ? "" : "s"), mins: n >= 4 ? 70 : 60, href: null, topics: true,
        desc: "Read each lesson actively. At every orange Check box, say or write your answer before you reveal it." });
      steps.push({ key: "cards", title: "Flashcards: lock in today's facts", mins: 15, href: "cards-" + n,
        desc: "Go through today's new cards once. Rate yourself honestly; cards you miss come back sooner." });
      steps.push({ key: "quiz", title: "Practice quiz" + (n >= 3 ? ", mixed with earlier days" : ""), mins: 20, href: "quiz-" + n,
        desc: n >= 3 ? "Today's questions shuffled together with due questions from earlier days, the way the exam mixes topics." : "Exam-style questions on today's topics with instant feedback." });
      steps.push({ key: "write", title: "Write it by hand", mins: n >= 4 ? 35 : 25, href: "write-" + n,
        desc: "Study the worked example, fill in the faded one, then write the last one from a blank page, ideally on paper first. Half the midterm is handwritten code." });
      steps.push({ key: "drills", title: "Terminal drills", mins: 25, href: "drills-" + n,
        desc: "Run your answers in a real shell. The checker compares them with the reference, so any correct command passes." });
      steps.push({ key: "dump", title: "Brain dump: everything you remember", mins: 10, href: "dump-" + n,
        desc: "No notes. Write down everything from today, then compare it with the key points. Gaps you find here go to the top of tomorrow." });
    } else if (n === 7) {
      steps.push({ key: "mock", title: "Mock exam A (50 min, timed, on paper)", mins: 60, href: "mock-mockA",
        desc: "Phone away, no notes. Write your answers on paper, then mark them against the rubric." });
      steps.push({ key: "drills", title: "Type in and test your mock scripts", mins: 25, href: "drills-7",
        desc: "Type your handwritten scripts exactly as written and run the checker. Every bug it finds is a bug you would have handed in." });
      steps.push({ key: "weak", title: "Fix your weak spots", mins: 45, href: "weak",
        desc: "Re-read the lessons for your lowest-scoring topics, then redo their write exercises from a blank page." });
      steps.push({ key: "dump", title: "Brain dump", mins: 10, href: "dump-7", desc: "Write what you would tell a friend who has the same exam tomorrow." });
    } else if (n === 8) {
      steps.push({ key: "mock", title: "Mock exam B (50 min, timed, on paper)", mins: 60, href: "mock-mockB",
        desc: "Same conditions as yesterday. Compare your topic scores with mock A." });
      steps.push({ key: "drills", title: "Type in and test your mock scripts", mins: 20, href: "drills-8", desc: "Same as yesterday, for mock B." });
      steps.push({ key: "sheet", title: "Write your one-page summary from memory", mins: 30, href: "sheet",
        desc: "Write a full page of syntax from memory first, then compare it with the reference sheet and fill the gaps in a different colour." });
      steps.push({ key: "missed", title: "Last pass: every card you ever missed", mins: 15, href: "review-missed",
        desc: "Only the cards you have got wrong at least once. Stop when you're done; don't start new material tonight." });
      steps.push({ key: "sleep", title: "Stop by 10 pm and sleep", mins: 0, href: null,
        desc: "Sleep consolidates what you've practised. An all-nighter costs more marks than it gains." });
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
      case "dump": return !!(S.dumps[n] && S.dumps[n].trim());
      case "mock": return !!(S.mocks[n === 7 ? "mockA" : "mockB"] && S.mocks[n === 7 ? "mockA" : "mockB"].score != null);
      case "setup": return !!S.drills[0];
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
    const st = stepsFor(n);
    const done = st.filter((s) => stepDone(n, s.key)).length;
    return st.length ? done / st.length : 0;
  }
  const dateOfDay = (n) => addDays(DAY1_DATE, n - 1);

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
  function prioChip(p) { return p ? '<span class="chip ' + esc(p) + '">' + esc(p) + " priority</span>" : ""; }

  function renderRail() {
    const cd = calendarDay();
    const daysLeft = diffDays(today(), EXAM_DATE);
    const cur = currentDay();
    const due = dueItems().length;
    const route = location.hash.replace(/^#/, "") || "today";
    const on = (r) => (route === r ? " on" : "");
    let cdText;
    if (daysLeft > 1) cdText = "<big>" + daysLeft + " days</big>until the midterm";
    else if (daysLeft === 1) cdText = "<big>Tomorrow</big>midterm day. Sleep well.";
    else if (daysLeft === 0) cdText = "<big>Today</big>is the midterm. You've got this.";
    else cdText = "<big>Done</big>the midterm is behind you.";
    let days = "";
    for (let n = 1; n <= 8; n++) {
      const p = Math.round(dayProgress(n) * 100);
      days += '<a href="#day-' + n + '" class="' + on("day-" + n).trim() + (n === cur ? " today-day" : "") + '"><span>Day ' + n +
        '<span class="sub">' + esc(fmtDate(dateOfDay(n))) + " · " + esc(shortTitle(n)) + '</span></span><span class="meter" title="' + p + '% done"><i style="width:' + p + '%"></i></span></a>';
    }
    $("#rail").innerHTML =
      '<div class="rail-top"><a class="brand" href="#today"><b>Bash Sprint</b><span>CISC220 midterm · ' + esc(fmtDate(EXAM_DATE, { weekday: "short", month: "short", day: "numeric" })) + '</span></a>' +
      '<button class="btn ghost menu-btn" id="menuBtn" aria-expanded="false">Menu</button></div>' +
      '<div class="countdown"><span class="pr">$</span> echo $((exam-today))<br>' + cdText + "</div>" +
      '<nav class="nav">' +
      '<a href="#today" class="' + on("today").trim() + '"><span>Today</span></a>' +
      '<a href="#review" class="' + on("review").trim() + '"><span>Spaced review</span><span class="badge' + (due ? "" : " zero") + '">' + due + "</span></a>" +
      '<a href="#plan" class="' + on("plan").trim() + '"><span>The 8-day plan</span></a>' +
      "<h6>Days</h6>" + days +
      "<h6>Exam practice</h6>" +
      '<a href="#mock-mockA" class="' + on("mock-mockA").trim() + '"><span>Mock exam A</span>' + mockBadge("mockA") + "</a>" +
      '<a href="#mock-mockB" class="' + on("mock-mockB").trim() + '"><span>Mock exam B</span>' + mockBadge("mockB") + "</a>" +
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
    if (cd === 0) intro = "The plan starts " + fmtDate(DAY1_DATE, { weekday: "long", month: "long", day: "numeric" }) + ".";
    else if (cd >= 9) intro = daysLeft === 0 ? "It's exam day. Skim your summary sheet and the cards you've missed, then stop. No new material." : "The plan is complete.";
    else intro = "Day " + n + " of 8 · " + fmtDate(today(), { weekday: "long", month: "long", day: "numeric" });
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
      stat(Math.max(0, daysLeft), "days until the midterm") +
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
    if (!(n >= 1 && n <= 8)) return notFound();
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
      (n < 8 ? '<a class="btn ghost" href="#day-' + (n + 1) + '">Day ' + (n + 1) + " →</a>" : "") + "</div>";
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
    const ids = n >= 3 ? interleave(own.concat(mixed)) : shuffle(own);
    return { type: "quiz", key: "quiz-" + n, day: n, queue: ids, i: 0, right: 0, results: [], answered: false, back: "#day-" + n, label: "Day " + n + " practice quiz" };
  }
  function viewQuiz(n) {
    const d = dayData[n];
    if (!d) return notFound();
    if (!session || session.key !== "quiz-" + n) {
      const last = S.quizRuns["d" + n];
      return '<div class="col"><div class="head"><div class="eyebrow"><a href="#day-' + n + '">Day ' + n + "</a></div><h1>Practice quiz</h1>" +
        '<p class="lede">' + d.quiz.length + " questions on today's topics" + (n >= 3 ? ", mixed with up to 8 due questions from earlier days" : "") +
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
      return '<div class="card" id="card-' + esc(w.id) + '"><div class="row"><span class="eyebrow">' + (k + 1) + ". " + esc(stageLab[w.stage] || w.stage) + "</span>" +
        '<span class="chip">' + esc(topicTitle(w.topic)) + "</span>" + (max ? '<span class="marks">' + max + " marks</span>" : "") + '<span class="spacer"></span>' + status + "</div>" + inner + "</div>";
    }).join("");
    return '<div class="col"><div class="head"><div class="eyebrow"><a href="#day-' + n + '">Day ' + n + "</a></div><h1>Write it by hand</h1>" +
      '<p class="lede">These go from a full worked example, to one with blanks, to a blank page, so you rely a little less on help each time. Use paper for the last ones: on the exam there is no autocomplete and no way to run your code.</p></div>' + list + dayNav(n) + "</div>";
  }

  // ----- drills
  function viewDrills(n) {
    const cloneCmd = "git clone -b " + BRANCH + " https://github.com/FallingBrook/CISC220_current.git ~/CISC220_current";
    const setup = n === 0
      ? '<div class="card"><h2>One-time setup (on your Ubuntu laptop)</h2><div class="prose"><p>Open a terminal (<kbd>Ctrl</kbd>+<kbd>Alt</kbd>+<kbd>T</kbd>) and copy these commands in one at a time. Don\'t worry about what they mean yet; you\'ll understand all of it by Day 4.</p></div>' +
        codeBlock("$ " + cloneCmd + "\n$ cd ~/CISC220_current/study-app/drills\n$ ./drill.sh start 0") +
        '<div class="prose"><p>If <code>git</code> is missing, install it first with <code>sudo apt install git</code>. If the repository is already on that laptop, run <code>git pull</code> inside it instead of cloning.</p>' +
        "<p>Then open the answers file it prints (for example with <code>gedit ~/cisc220_drills/answers/day0.txt</code>), write your answers under each <code>###</code> header, save, and run:</p></div>" +
        codeBlock("$ ./drill.sh check 0") + "</div>"
      : "";
    const r = S.drills[n];
    return '<div class="col"><div class="head"><div class="eyebrow">' + (n ? '<a href="#day-' + n + '">Day ' + n + "</a>" : "Before Day 1") + "</div><h1>Terminal drills" + (n === 0 ? ": warm-up" : "") + "</h1>" +
      '<p class="lede">Reading about Bash isn\'t enough to write it. These tasks run in a throwaway sandbox folder, so nothing you type can damage your real files.</p></div>' + setup +
      (n > 0 ? '<div class="card"><h3>Run today\'s drills</h3>' +
        codeBlock("$ cd ~/CISC220_current/study-app/drills\n$ git pull            # get any updates\n$ ./drill.sh start " + n + "    # shows the tasks, creates your answers file and a sandbox\n$ ./drill.sh check " + n + "    # grades everything; run it as often as you like") +
        '<div class="prose"><ul><li>One-line answers go in <code>~/cisc220_drills/answers/day' + n + ".txt</code>; scripts go in <code>~/cisc220_drills/scripts/day" + n + "/</code>.</li>" +
        "<li>Try commands in the sandbox first: <code>./drill.sh start " + n + "</code> prints an <code>export SB=…; cd \"$SB\"</code> line you can paste.</li>" +
        "<li>When a task fails, the checker shows the expected output next to yours. Work out <em>why</em> they differ before you fix it.</li>" +
        "<li>Stuck for more than 5 minutes on one task? Re-read the lesson, then move on and come back.</li></ul></div></div>" : "") +
      '<div class="card"><h3>Record your score</h3><div class="row"><label for="drillScore">Final <code>./drill.sh check ' + n + '</code> score</label>' +
      '<input id="drillScore" class="ans" style="width:110px;min-height:0" placeholder="e.g. 14/17" value="' + esc(r || "") + '">' +
      '<button class="btn primary" data-act="drill-save" data-day="' + n + '">Save</button></div></div>' +
      (n ? dayNav(n) : '<div class="row"><a class="btn" href="#day-1">← Back to Day 1</a></div>') + "</div>";
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
    return '<div class="col"><div class="head"><div class="eyebrow">' + (n <= 8 ? '<a href="#day-' + n + '">Day ' + n + "</a>" : "") + "</div><h1>Brain dump</h1>" +
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
    ["mockA", "mockB"].forEach((m) => { if (S.mocks[m] && S.mocks[m].score != null) Object.entries(mockTagLoss(m)).forEach(([t, v]) => { mockLoss[t] = (mockLoss[t] || 0) + v; }); });
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
    for (let n = 1; n <= 8; n++) {
      const d = dayData[n];
      const what = d ? d.topics.map((t) => esc(t.title)).join(", ") : esc(DAY_META[n].goal);
      rows.push('<tr class="' + (n === cur ? "now" : "") + '"><td class="d">Day ' + n + "<br>" + esc(fmtDate(dateOfDay(n))) + '</td><td><a href="#day-' + n + '"><b>' + esc(dayTitle(n)) + "</b></a><br>" + what +
        '</td><td class="d">~' + Math.round(stepsFor(n).reduce((a, s) => a + s.mins, 0) / 5) * 5 + " min</td><td>" + Math.round(dayProgress(n) * 100) + "%</td></tr>");
    }
    rows.push('<tr><td class="d">Day 9<br>' + esc(fmtDate(EXAM_DATE)) + "</td><td><b>Midterm (50 min)</b><br>Light skim of your summary sheet and missed cards only. Eat, arrive early.</td><td></td><td></td></tr>");
    return '<div class="col"><div class="head"><div class="eyebrow">Oct 19 – Oct 26</div><h1>The 8-day plan</h1>' +
      '<p class="lede">Six days of new material in course order, each starting with a review of earlier days, then two days of full mock exams and repair. Priorities come from the 2023 quizzes and your assignments: about half the marks are for scripts written by hand, so every day ends with writing code.</p></div>' +
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
    return '<div class="col"><div class="head"><div class="eyebrow">Day 8</div><h1>Summary sheet</h1>' +
      '<p class="lede">Make your own first. On one sheet of paper, write every piece of syntax you can remember, grouped by topic, from memory. Only then open the reference and add what you missed in a different colour. The page you write is what you skim on exam morning.</p></div>' +
      (revealed || S.steps["8:sheet"] ? secs.map((s) => '<div class="card"><h2>' + esc(s.title) + '</h2><div class="prose">' + md(s.md) + "</div></div>").join("")
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
    const opts = ['<option value="">Follow the calendar (Day ' + (calendarDay() === 0 ? 1 : Math.min(8, calendarDay())) + " today)</option>"];
    for (let i = 1; i <= 8; i++) opts.push('<option value="' + i + '"' + (S.dayOverride === i ? " selected" : "") + ">Treat today as Day " + i + "</option>");
    return '<div class="col"><div class="head"><h1>Progress &amp; backup</h1><p class="lede">Your progress is saved in this browser on this laptop. Copy a backup here if you switch browsers or clear site data.</p></div>' +
      '<div class="stats">' + stat(n, "items in your review deck") + stat(Object.keys(S.topicsDone).length, "lessons learned") + stat(Object.keys(S.write).length, "scripts marked") + "</div>" +
      '<div class="card"><h3>Behind or ahead?</h3><p class="small muted" style="margin:0">If you lose a day, shift the plan so <i>Today</i> shows the day you are actually on.</p><div class="row"><select id="dayOverride" class="btn">' + opts.join("") + "</select></div></div>" +
      '<div class="card"><h3>Theme</h3><div class="row"><button class="btn" data-act="theme" data-v="">Match system</button><button class="btn" data-act="theme" data-v="light">Light</button><button class="btn" data-act="theme" data-v="dark">Dark</button></div></div>' +
      '<div class="card"><h3>Back up or restore</h3><div class="row"><button class="btn" data-act="export">Show backup text</button><button class="btn" data-act="copy-export">Copy backup</button><button class="btn" data-act="import">Restore from pasted text</button></div>' +
      '<textarea class="ans" id="backup" spellcheck="false" placeholder="Your backup appears here. To restore, paste a backup here and press Restore."></textarea></div>' +
      '<div class="card"><h3>Start over</h3><p class="small muted" style="margin:0">Deletes all progress in this browser.</p><div class="row"><button class="btn bad" data-act="reset-ask">Reset all progress</button><span id="resetConfirm"></span></div></div></div>';
  }

  function notFound() { return '<div class="col"><div class="card empty"><h3>Page not found</h3><a class="btn" href="#today">Go to Today</a></div></div>'; }

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
    else if ((m = h.match(/^drills-(\d+)$/))) html = viewDrills(+m[1]);
    else if ((m = h.match(/^dump-(\d+)$/))) html = viewDump(+m[1]);
    else if ((m = h.match(/^mock-(.+)$/))) html = viewMock(m[1]);
    else if (h === "weak") html = viewWeak();
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
