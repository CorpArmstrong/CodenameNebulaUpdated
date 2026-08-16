#!/usr/bin/env node
/*
 * con_dump.js - inspect Deus Ex .con conversation files without ConEdit.
 *
 * ConEdit is the only first-party way to see what a conversation actually
 * DOES (which flags it sets, which choices branch where). That makes it
 * impossible to review conversation logic in git or answer "is this
 * conversation finished?" without opening a GUI. This reads the binary
 * directly.
 *
 * Format (reverse-engineered from CNN's own .con files):
 *   "Deus Ex Conversation File" 0x1A
 *   int32  version
 *   ...    author / summary / package strings, each [int32 len][bytes]
 *   int32  x5   header fields (last two look like record + name counts)
 *   name table: repeating [int32 index][int32 len][bytes]
 *
 * Usage:
 *   node tools/con_dump.js <file.con> [--names] [--raw]
 */

const fs = require('fs');

const MAGIC = 'Deus Ex Conversation File';

function readLenString(buf, off) {
    if (off + 4 > buf.length) return null;
    const len = buf.readInt32LE(off);
    if (len < 0 || len > 4096 || off + 4 + len > buf.length) return null;
    return { value: buf.toString('latin1', off + 4, off + 4 + len), next: off + 4 + len };
}

function parse(file) {
    const buf = fs.readFileSync(file);
    const magic = buf.toString('latin1', 0, MAGIC.length);
    if (magic !== MAGIC) throw new Error(`not a .con file (magic="${magic}")`);

    let off = MAGIC.length;
    if (buf[off] === 0x1a) off++;            // EOF-style terminator

    const version = buf.readInt32LE(off); off += 4;

    // Two 8-byte blobs bracket the author string (timestamps, most likely).
    off += 8;
    const author = readLenString(buf, off);
    off = author ? author.next : off;
    off += 8;
    const summary = readLenString(buf, off);
    off = summary ? summary.next : off;
    const pkg = readLenString(buf, off);
    off = pkg ? pkg.next : off;

    const header = [];
    for (let i = 0; i < 5; i++) { header.push(buf.readInt32LE(off)); off += 4; }

    // Tables are [int32 index][int32 len][bytes]. Indices ASCEND but are
    // sparse - they are slot ids, not positions, so a gap (0,1,5,6...) is
    // normal and must not terminate the read. The record count is declared
    // ahead of the table: header[4] for the first, an int32 for each later one.
    function readIndexTable(start, count) {
        const rows = [];
        let p = start, last = -1;
        for (let i = 0; i < count; i++) {
            if (p + 8 > buf.length) break;
            const idx = buf.readInt32LE(p);
            if (idx <= last || idx > 100000) break;
            const s = readLenString(buf, p + 4);
            if (!s || !/^[\x20-\x7e]*$/.test(s.value)) break;
            rows.push({ index: idx, name: s.value });
            last = idx;
            p = s.next;
        }
        return { rows, next: p };
    }

    const tables = [];
    let t = readIndexTable(off, header[4]);
    tables.push({ count: header[4], rows: t.rows });
    off = t.next;

    // Subsequent tables carry an explicit count first.
    while (off + 8 < buf.length) {
        const count = buf.readInt32LE(off);
        if (count <= 0 || count > 4096) break;
        t = readIndexTable(off + 4, count);
        if (t.rows.length === 0) break;
        tables.push({ count, rows: t.rows });
        off = t.next;
    }

    return { version, author: author && author.value, summary: summary && summary.value,
             pkg: pkg && pkg.value, header, names: tables[0] ? tables[0].rows : [],
             tables, tableEnd: off, size: buf.length, buf };
}

const args = process.argv.slice(2);
const file = args.find(a => !a.startsWith('--'));
if (!file) { console.error('usage: node con_dump.js <file.con> [--names] [--raw]'); process.exit(2); }

const r = parse(file);
console.log(`file        : ${file}`);
console.log(`size        : ${r.size} bytes`);
console.log(`version     : ${r.version}`);
console.log(`author      : ${r.author}`);
console.log(`summary     : ${r.summary}`);
console.log(`package     : ${r.pkg}`);
console.log(`header ints : ${r.header.join(', ')}`);
console.log(`names parsed: ${r.names.length}  (table ends at 0x${r.tableEnd.toString(16)}, ` +
            `${r.size - r.tableEnd} bytes remain)`);

const LABELS = ['speakers', 'flags', 'table3', 'table4', 'table5'];
r.tables.forEach((t, i) => {
    console.log(`  ${(LABELS[i] || 'table' + (i + 1)).padEnd(9)}: ${t.rows.length}` +
                (t.count !== t.rows.length ? ` (declared ${t.count})` : ''));
});

if (args.includes('--names')) {
    r.tables.forEach((t, i) => {
        console.log(`\n--- ${LABELS[i] || 'table' + (i + 1)} (${t.rows.length}) ---`);
        t.rows.forEach(n => console.log(String(n.index).padStart(4) + "  " + n.name));
    });
}

if (args.includes('--raw')) {
    const tail = r.buf.subarray(r.tableEnd, Math.min(r.tableEnd + 256, r.size));
    console.log('\n--- first 256 bytes after name table ---');
    for (let i = 0; i < tail.length; i += 16) {
        const chunk = tail.subarray(i, i + 16);
        const hex = [...chunk].map(b => b.toString(16).padStart(2, '0')).join(' ');
        const asc = [...chunk].map(b => (b >= 32 && b < 127) ? String.fromCharCode(b) : '.').join('');
        console.log((r.tableEnd + i).toString(16).padStart(8, '0') + '  ' + hex.padEnd(47) + '  ' + asc);
    }
}
