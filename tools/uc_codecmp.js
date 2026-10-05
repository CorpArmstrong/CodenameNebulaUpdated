// uc_codecmp.js - check that UnrealScript files changed only in comments.
//
// Compares each file with its version at a git revision after removing
// // and /* */ comments (outside string and name literals) and all
// whitespace. Prints "same" or the first point where the code differs.
//
// With --keep <rev>, also checks that every comment line the file had at
// <rev> is still there word for word (the original authors' comments stay).
//
// Usage: node tools/uc_codecmp.js [--rev HEAD] [--keep 1faa297] file.uc ...
const { execSync } = require('child_process');
const fs = require('fs');

const args = process.argv.slice(2);
let rev = 'HEAD', keep = null;
while (args[0] && args[0].startsWith('--')) {
  if (args[0] === '--rev') rev = args[1];
  if (args[0] === '--keep') keep = args[1];
  args.splice(0, 2);
}

function gitShow(r, f) {
  try { return execSync(`git show ${r}:${f.replace(/\\/g, '/')}`, { encoding: 'latin1', maxBuffer: 1 << 26, stdio: ['pipe', 'pipe', 'ignore'] }); }
  catch { return null; }
}

function commentLines(src) {
  return src.split(/\r?\n/).map(l => l.trim()).filter(l => l.startsWith('//') && l.replace(/[\/\-=\s]/g, '') !== '');
}

function strip(src) {
  let out = '', i = 0;
  while (i < src.length) {
    const c = src[i], n = src[i + 1];
    if (c === '"' || c === "'") {                       // string or name literal
      const q = c; out += c; i++;
      while (i < src.length && src[i] !== q && src[i] !== '\n') { out += src[i]; i++; }
      out += src[i] || ''; i++;
    } else if (c === '/' && n === '/') {
      while (i < src.length && src[i] !== '\n') i++;
    } else if (c === '/' && n === '*') {
      i += 2;
      while (i < src.length && !(src[i] === '*' && src[i + 1] === '/')) i++;
      i += 2;
    } else { out += c; i++; }
  }
  return out.replace(/\s+/g, '');
}

let bad = 0;
for (const f of args) {
  const old = gitShow(rev, f);
  if (old === null) { console.log(`${f}: not in ${rev}`); continue; }
  const now = fs.readFileSync(f, 'latin1');
  if (keep) {
    const orig = gitShow(keep, f);
    if (orig !== null) {
      const present = new Set(commentLines(now));
      const lost = commentLines(orig).filter(l => !present.has(l));
      if (lost.length) { bad++; console.log(`${f}: ORIGINAL COMMENTS LOST\n  ` + lost.join('\n  ')); }
    }
  }
  const a = strip(old), b = strip(now);
  if (a === b) { console.log(`${f}: same`); continue; }
  bad++;
  let k = 0; while (k < a.length && a[k] === b[k]) k++;
  console.log(`${f}: CODE DIFFERS at ${k}\n  was: ${a.slice(Math.max(0, k - 60), k + 60)}\n  now: ${b.slice(Math.max(0, k - 60), k + 60)}`);
}
process.exit(bad ? 1 : 0);
