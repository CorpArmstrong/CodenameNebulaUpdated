// uc_comments.js - list or replace the comment blocks of an UnrealScript file.
//
// A block is a run of consecutive lines that are comments only (// ...).
//   node tools/uc_comments.js list  file.uc [--min N]   print blocks of N+ lines (default 1)
//   node tools/uc_comments.js apply file.uc edits.json  replace blocks
//
// edits.json: [{ "line": <first line of the block, 1-based, as listed>,
//                "first": "<its first line, trimmed, as a check>",
//                "text": ["new comment lines, without indentation"] }]
// An empty "text" removes the block. Indentation of the block is kept.
const fs = require('fs');
const [cmd, file, arg] = process.argv.slice(2);
const raw = fs.readFileSync(file, 'latin1');
const crlf = raw.includes('\r\n');
const lines = raw.replace(/\r\n/g, '\n').split('\n');
const isComment = l => /^\s*\/\//.test(l);

function blocks() {
  const out = [];
  for (let i = 0; i < lines.length; i++) {
    if (!isComment(lines[i])) continue;
    const start = i;
    while (i + 1 < lines.length && isComment(lines[i + 1])) i++;
    out.push({ start, end: i });
  }
  return out;
}

if (cmd === 'list') {
  const min = process.argv.includes('--min') ? +process.argv[process.argv.indexOf('--min') + 1] : 1;
  for (const b of blocks()) {
    if (b.end - b.start + 1 < min) continue;
    console.log(`@${b.start + 1}`);
    for (let k = b.start; k <= b.end; k++) console.log('  ' + lines[k]);
    const next = lines.slice(b.end + 1).find(l => l.trim() !== '');
    console.log('  >> ' + (next || '').trim().slice(0, 100));
  }
} else if (cmd === 'apply') {
  const edits = JSON.parse(fs.readFileSync(arg, 'utf8'));
  const byStart = new Map(blocks().map(b => [b.start + 1, b]));
  const sorted = edits.slice().sort((a, b) => b.line - a.line);
  for (const e of sorted) {
    const b = byStart.get(e.line);
    if (!b) throw new Error(`no comment block starts at line ${e.line}`);
    if (!lines[b.start].trim().startsWith(e.first.trim())) throw new Error(`line ${e.line} is "${lines[b.start].trim()}", expected "${e.first}"`);
    const indent = lines[b.start].match(/^\s*/)[0];
    const repl = e.text.map(t => indent + t);
    lines.splice(b.start, b.end - b.start + 1, ...repl);
  }
  let s = lines.join('\n').replace(/\n{3,}(?=\S)/g, m => m);    // keep spacing as written
  fs.writeFileSync(file, crlf ? s.replace(/\n/g, '\r\n') : s);
  console.log(`applied ${edits.length} edits`);
} else {
  console.log('usage: list|apply file.uc [edits.json]');
}
