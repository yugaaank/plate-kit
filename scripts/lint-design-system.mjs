#!/usr/bin/env node
// lint-design-system.mjs
//
// A verification layer over the design system for anything that edits this tree —
// human or agent. The design system's source of truth is the token layer itself
// (modules/common/Appearance.qml + Plate.qml); this script does not restate it, it only
// enforces the parts that are machine-checkable. The instance of each rule is
// wherever the system's own constants are spelled out below; the rationale lives in the
// referenced token file, not here.
//
// Usage:
//   node scripts/lint-design-system.mjs                # lint modules/ (default)
//   node scripts/lint-design-system.mjs path/...       # lint the given files/dirs
//   node scripts/lint-design-system.mjs --json         # machine-readable output
//   node scripts/lint-design-system.mjs --strict       # warnings also fail (exit 1)
//   node scripts/lint-design-system.mjs --show-canon   # print the de facto
//                                                      # literal-value canon
//                                                      # (DS4/DS5)
//   node scripts/lint-design-system.mjs --list-rules
//
// Exit code: 1 if any error (use --strict to include warnings).
//
// Curation: DS4/DS5 build the de facto canon of literal durations and radii from the
// current tree, so *existing* values pass and a NEW literal value is the finding. If a
// new value is genuinely right and it must survive review, carve it into CANON_EXTRA
// below with the ticket/PR reference, or suppress the line with
// `// design-system: allow DS4` style inline allowance (see allowedRules()).

import { readFileSync, readdirSync, statSync } from "node:fs";
import { join, relative, extname } from "node:path";
import { fileURLToPath } from "node:url";

const REPO = join(fileURLToPath(new URL(".", import.meta.url)), "..");

// ---------------------------------------------------------------------------
// Constants of the system this layer guards (single place to curate exceptions)
// ---------------------------------------------------------------------------

// Files that legitimately carry colour literals: the token source itself, the
// drawing/fallback exceptions the widget library already keeps, code previews, and
// two explicitly documented deviations:
//  - CrosshairContent: the hexes are user-facing crosshair *setting* defaults
//    (property string colorCode …), not paint decisions.
//  - setup/Look.qml: its own header documents the ink spec it follows on the
//    black-sky ground (APCA Lc 85/75 on #050505), deliberately further apart than
//    the apps' ladders (owner, 2026-10-17).
const HEX_EXCEPTION_FILES = [
  "modules/common/Appearance.qml",
  "modules/common/widgets/MaterialSymbol.qml",
  "modules/common/widgets/CustomColorSelectionArray.qml", // material hue spectrum stops
  "modules/common/widgets/SineCookie.qml",
  "modules/common/widgets/DockedRect.qml",
  "modules/common/widgets/ShapeCanvas.qml",
  "modules/common/widgets/RoundCorner.qml",
  "modules/common/widgets/LightDarkPreferenceButton.qml", // theme previews, mock colours
  "modules/common/widgets/ColorSelectionArray.qml",
  "modules/common/widgets/shapes/ShapeCanvas.qml", // material shape drawing canvas
  "modules/common/widgets/PlayerControlsLyrics.qml", // compares track-art colours, `#000000` etc. are data, not paint
  "modules/ii/overlay/crosshair/CrosshairContent.qml", // crosshair setting defaults
  "modules/setup/Look.qml", // deviating ink spec, document in its header
];

// Files that may name typefaces literally: the token definition and the
// symbol plumbing that resolves it. FACES_ALLOWED_LITERAL covers faces that are not
// configurable under appearance.fonts, so naming them is the only option.
const FONT_EXCEPTION_FILES = [
  "modules/common/Appearance.qml",
  "modules/common/widgets/MaterialSymbol.qml",
  "modules/ii/background/clock/AndroidClock.qml",
];
const FACES_ALLOWED_LITERAL = ["Noto Color Emoji"]; // renders emoji glyphs; not in appearance.fonts

// Files that may name the icon font literally instead of routing through
// MaterialSymbol/Fonts.
const ICON_FONT_EXCEPTION_FILES = [
  "modules/common/Appearance.qml",
  "modules/common/widgets/MaterialSymbol.qml",
  "services/Fonts.qml",
];

// Directories whose QML may be loaded by a login lock's tree, which must stay
// service-free. The kit ships no lock screen, so nothing is listed yet — add a
// dir here if you build one.
const LOCK_PURE_DIRS = [];

// Extra literal values curated into the canon by hand, with a reason each.
const CANON_EXTRA = {
  durations: [],
  radii: [],
};

// ---------------------------------------------------------------------------
// Scanning
// ---------------------------------------------------------------------------

const RE_DURATION_LIT = /\bduration:\s*([0-9]+(?:\.[0-9]+)?)\b/g;
const RE_RADIUS_LIT = /\bradius:\s*(-?[0-9]+(?:\.[0-9]+)?)\b|radius:\s*(-?[0-9]+(?:\.[0-9]+)?)\s*\*/g;
const RE_FONT_LIT = /\bfont\.family\s*:\s*\"([^"]+)\"/g;
const RE_ICON_FONT = /\"Material Symbols Rounded\"/g;
const RE_BLAME_COPY = /\b(Translation\.tr|qsTr)\(\s*"(?:(?!\1).)*Failed to /g;
const RE_TEXT_ELEMENT = /(^|\s)(StyledText|SqueezedAnnotationStyledText|MaterialSymbol|OptionalMaterialSymbol|VLabel|VT\b|VText\b|Text|Label)\s*\{/;
const RE_MOTION_CONTEXT = /Behavior|SequentialAnimation|ParallelAnimation|NumberAnimation|ColorAnimation|SpringAnimation|SmoothedAnimation|Anim\s*\{|animation\./;

function listQmlFiles(path, out = []) {
  const abs = join(REPO, path);
  let s;
  try {
    s = statSync(abs);
  } catch {
    return out;
  }
  if (s.isFile()) {
    if (extname(path) === ".qml") out.push(path);
    return out;
  }
  for (const e of readdirSync(abs).sort()) {
    if (e.startsWith(".")) continue;
    listQmlFiles(join(path, e), out);
  }
  return out;
}

// Returns the code part of a line with // and /* */ comments stripped, plus the
// comment text (so inline `design-system: allow DSx` suppressions inside block
// comments still register).
function stripComments(line, state) {
  if (state.inBlock) {
    const end = line.indexOf("*/");
    if (end === -1) return { code: "", comment: line };
    state.inBlock = false;
    const r = stripComments(line.slice(end + 2), state);
    return { code: r.code, comment: line };
  }
  const cut = line.indexOf("//");
  const openB = line.indexOf("/*");
  if (cut !== -1 && (openB === -1 || cut < openB)) {
    return { code: line.slice(0, cut), comment: line.slice(cut) };
  }
  if (openB !== -1) {
    const head = line.slice(0, openB);
    const innerStart = openB + 2;
    const end = line.indexOf("*/", innerStart);
    if (end === -1) {
      state.inBlock = true;
      return { code: head, comment: line };
    }
    const inner = line.slice(innerStart, end);
    const r = stripComments(line.slice(end + 2), state);
    return { code: head + r.code, comment: inner + r.comment };
  }
  return { code: line, comment: "" };
}

// ---------------------------------------------------------------------------
// Rules
// ---------------------------------------------------------------------------

function allowedRules(commentText) {
  const rules = [];
  const re = /design-system:\s*allow\s+(DS\d+[a-zA-Z]?)/g;
  let m;
  while ((m = re.exec(commentText))) rules.push(m[1]);
  return rules;
}

function scanFile(path, canon, ctx) {
  const rel = relative(REPO, path).split("\\").join("/");
  let raw;
  try {
    raw = readFileSync(join(REPO, path), "utf8");
  } catch (e) {
    console.error(`cannot read ${path}: ${e.message}`);
    return;
  }
  const lines = raw.split("\n");
  const state = { inBlock: false };
  const fileHasException =
    HEX_EXCEPTION_FILES.includes(rel) ||
    FONT_EXCEPTION_FILES.includes(rel) ||
    ICON_FONT_EXCEPTION_FILES.includes(rel);

  for (let i = 0; i < lines.length; i++) {
    const full = lines[i];
    const { code, comment } = stripComments(full, state);
    const lineNo = i + 1;
    const allow = allowedRules(comment);
    const contextWin = lines.slice(Math.max(0, i - 5), i).join("\n");
    const report = (id, message, hint) => {
      if (allow.includes(id)) return;
      ctx.findings.push({ rule: id, file: rel, line: lineNo, message, hint, excerpt: full.trim().slice(0, 120) });
    };

    // DS1 — colour literals violate the token contract; the kit's designed-in
    // fallback idiom (`Appearance?.x ?? "#123456"`) is the one accepted form.
    if (!fileHasException || !HEX_EXCEPTION_FILES.includes(rel)) {
      const reHex = /(['"])#[0-9a-fA-F]{3,8}\1/g;
      let m;
      while ((m = reHex.exec(code))) {
        const before = code.slice(Math.max(0, m.index - 4), m.index);
        if (before.includes("??")) continue; // fallback idiom
        report("DS1", `hex colour literal; use an Appearance/Plate token or the \`?? "#…"\` fallback idiom`, "see Appearance.qml colours block / Plate.qml inks");
        break;
      }
    }

    // DS2 — typefaces are chosen once, in Config/appearance; components must take
    // them from the Appearance.font.family.* tree.
    if (!FONT_EXCEPTION_FILES.includes(rel)) {
      RE_FONT_LIT.lastIndex = 0;
      let m;
      while ((m = RE_FONT_LIT.exec(code))) {
        if (FACES_ALLOWED_LITERAL.includes(m[1])) continue;
        report("DS2", `literal font family "${m[1]}"; use Appearance.font.family.*`, "fonts are configurable under appearance.fonts");
        break;
      }
    }

    // DS3 — the icon font is hardcoded by design and routed through MaterialSymbol.
    if (!ICON_FONT_EXCEPTION_FILES.includes(rel) && RE_ICON_FONT.test(code)) {
      report("DS3", `"Material Symbols Rounded" named directly; route through MaterialSymbol.qml / Fonts.symbolFamily`);
    }

    // DS4 — motion durations come from named Appearance.animation presets; the
    // literal values already in the tree are the frozen de facto canon.
    RE_DURATION_LIT.lastIndex = 0;
    let md;
    while ((md = RE_DURATION_LIT.exec(code))) {
      const v = Number(md[1]);
      if (!canon.durations.has(v)) {
        report("DS4", `duration ${md[1]} is off the observedCanon (existing tree values + CANON_EXTRA); use Appearance.animation.* presets`, durationsHint(canon));
        break;
      }
    }

    // DS5 — radii come from Appearance.rounding.* / Plate.radius.*
    reRadiusExec(code, report, canon);

    // DS6 — text is ink at solved contrast, never dimmed by opacity
    // (Appearance.qml ink levels). Motion targets (breaths, fades) in animation
    // context are exempt.
    const opMatch = findOpacityLiteral(code);
    if (opMatch && RE_TEXT_ELEMENT.test(contextWin.slice(-400))) {
      if (!RE_MOTION_CONTEXT.test(contextWin)) {
        report("DS6", `static opacity ${opMatch} on text; use the ink ladder (Plate.inkMain/Sec/Meta/Faint) instead of opacity`, "opacity-on-text also breaks tone on translucent ground");
      }
    }

    // DS7 — the lock tree must stay service-free
    for (const dir of LOCK_PURE_DIRS) {
      if (rel.startsWith(dir + "/")) {
        if (/import\s+qs\.services/.test(code)) {
          report("DS7", `${rel} imports qs.services; the login lock's tree may load these files and must stay service-free`);
        }
      }
    }

    // DS8 — unblaming copy
    RE_BLAME_COPY.lastIndex = 0;
    if (RE_BLAME_COPY.test(code)) {
      report("DS8", `"Failed to …" is blame-flavoured UI copy; say what did not happen (compare "Wi-Fi did not turn on")`, "");
    }
  }
}

function reRadiusExec(code, report, canon) {
  const re = /\bradius:\s*((?:-?)(?:[0-9]+(?:\.[0-9]+)?))\b\s*$/gm;
  let m;
  while ((m = re.exec(code))) {
    const v = Number(m[1]);
    if (!canon.radii.has(v)) {
      report("DS5", `radius ${m[1]} is off the observedCanon; use Appearance.rounding.* / Plate.radius.*`, radiiHint(canon));
      break;
    }
  }
}

function findOpacityLiteral(code) {
  const m = /\bopacity:\s*(0\.[0-9]+)\b/.exec(code);
  return m ? m[1] : null;
}

function durationsHint(canon) {
  void canon;
  return "prefixed durations (150/200/350/400/500/650) map to animationCurves tokens";
}
function radiiHint(_canon) {
  return "ladder: 2 6 8 10 12 14 17 18 21 23 24 30 full";
}

// ---------------------------------------------------------------------------
// Driver
// ---------------------------------------------------------------------------

function buildCanon(paths) {
  const canon = { durations: new Set(CANON_EXTRA.durations), radii: new Set(CANON_EXTRA.radii) };
  for (const p of paths) {
    for (const f of listQmlFiles(p)) {
      let raw;
      try {
        raw = readFileSync(join(REPO, f), "utf8");
      } catch {
        continue;
      }
      const state = { inBlock: false };
      for (const line of raw.split("\n")) {
        const { code } = stripComments(line, state);
        let m;
        RE_DURATION_LIT.lastIndex = 0;
        while ((m = RE_DURATION_LIT.exec(code))) canon.durations.add(Number(m[1]));
        const re = /\bradius:\s*(-?[0-9]+(?:\.[0-9]+)?)\b/g;
        while ((m = re.exec(code))) canon.radii.add(Number(m[1]));
      }
    }
  }
  return canon;
}

function scan(paths, canon) {
  const findings = [];
  const ctx = { findings };
  for (const p of paths) for (const f of listQmlFiles(p)) scanFile(f, canon, ctx);
  return findings;
}

function main() {
  const args = process.argv.slice(2);
  const json = args.includes("--json");
  const strict = args.includes("--strict");
  const showCanon = args.includes("--show-canon");
  const listRules = args.includes("--list-rules");
  const paths = args.filter(a => !a.startsWith("--"));

  const RULES = [
    ["DS1", "error", "colour literals outside tokens (the `?? \"#…\"` fallback idiom is accepted)"],
    ["DS2", "error", "literal typeface name in font.family"],
    ["DS3", "error", `"Material Symbols Rounded" named outside its plumbing`],
    ["DS4", "warn", "motion duration literal not in the frozen de facto canon → prefer Appearance.animation presets"],
    ["DS5", "warn", "radius literal not in the frozen de facto canon → prefer Appearance.rounding / Plate.radius"],
    ["DS6", "warn", "static opacity on text instead of the ink ladder"],
    ["DS7", "error", "services import inside a lock-loadable tree (LOCK_PURE_DIRS)"],
    ["DS8", "warn", "blame-flavoured user copy (\"Failed to …\")"],
  ];

  if (listRules) {
    for (const [id, sev, desc] of RULES) console.log(`${id}  ${sev.padEnd(5)}  ${desc}`);
    return;
  }

  const canonScanPaths = ["modules"];
  const canon = buildCanon(canonScanPaths);
  if (showCanon) {
    console.log("duration canon:", [...canon.durations].sort((a, b) => a - b).join(" "));
    console.log("radius canon:", [...canon.radii].sort((a, b) => a - b).join(" "));
    return;
  }

  const targets = paths.length ? paths : ["modules"];
  const findings = scan(targets, canon);

  if (json) {
    const errors = findings.filter(f => sevOf(f.rule) === "error").length;
    console.log(JSON.stringify({ ok: errors === 0, counts: tallies(findings), findings }, null, 2));
  } else {
    let lastFile = null;
    for (const f of findings.sort((a, b) => a.file.localeCompare(b.file) || a.line - b.line)) {
      if (f.file !== lastFile) {
        console.log(`\n${f.file}`);
        lastFile = f.file;
      }
      console.log(`  ${f.line}: [${f.rule}] ${f.message}`);
    }
    const t = tallies(findings);
    console.log(
      `\n${findings.length} findings — ` +
      `errors ${t.error.count} (${Object.entries(t.error.byRule).map(([k, v]) => `${k}:${v}`).join(" ") || "—"}), ` +
      `warnings ${t.warn.count} (${Object.entries(t.warn.byRule).map(([k, v]) => `${k}:${v}`).join(" ") || "—"})`
    );
  }

  const errors = findings.some(f => sevOf(f.rule) === "error");
  const warns = findings.some(f => sevOf(f.rule) === "warn");
  process.exitCode = errors || (strict && warns) ? 1 : 0;

  function sevOf(rule) {
    const r = RULES.find(r => r[0] === rule);
    return r ? r[1] : "error";
  }
  function tallies(list) {
    const out = { error: { count: 0, byRule: {} }, warn: { count: 0, byRule: {} } };
    for (const f of list) {
      const s = sevOf(f.rule);
      out[s].count++;
      out[s].byRule[f.rule] = (out[s].byRule[f.rule] || 0) + 1;
    }
    return out;
  }
}

main();
