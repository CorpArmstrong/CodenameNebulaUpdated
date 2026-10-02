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
 *   node tools/con_dump.js <file.con> [--names] [--flagmap] [--records] [--strings] [--raw]
 *
 * --flagmap labels each reference SET / CHECK / PRECOND / REF. PRECOND is the
 * conversation's availability condition (ConEdit's "Conversation Properties"),
 * not an event -- it decides whether the conversation can start at all.
 * Polarity (wants true vs wants false) is NOT recoverable; treat PRECOND as
 * "gated on this flag". --records lists every conversation with its owner and
 * its classified flag references.
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
if (!file) { console.error('usage: node con_dump.js <file.con> [--names] [--flagmap] [--records] [--strings] [--raw]'); process.exit(2); }

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

// Ordered scan of every length-prefixed ASCII string in the file.
//
// Full event decoding would mean reverse-engineering the whole ConEdit event
// format. We don't need that to answer "which conversation touches which
// flag": conversation records appear in order, each starting with its name
// and owner, and flag names appear inline where the flag events sit. So a
// positional scan attributes flags to the conversation they fall inside.
function scanStrings(buf) {
    const out = [];
    for (let p = 0; p + 4 < buf.length; ) {
        const len = buf.readInt32LE(p);
        if (len >= 2 && len <= 512 && p + 4 + len <= buf.length) {
            const s = buf.toString('latin1', p + 4, p + 4 + len);
            if (/^[\x20-\x7e]+$/.test(s)) {
                out.push({ off: p, text: s });
                p += 4 + len;
                continue;
            }
        }
        p++;
    }
    return out;
}

if (args.includes('--strings') || args.includes('--flagmap') || args.includes('--records')) {
    const strs = scanStrings(r.buf).filter(s => s.off >= r.tableEnd);
    const flagSet = new Set((r.tables[1] ? r.tables[1].rows : []).map(x => x.name));
    const speakerSet = new Set(r.names.map(x => x.name));

    if (args.includes('--strings')) {
        console.log('\n--- strings after tables (file order) ---');
        for (const s of strs) {
            let kind = '';
            if (flagSet.has(s.text)) kind = ' [FLAG]';
            else if (speakerSet.has(s.text)) kind = ' [speaker]';
            console.log('0x' + s.off.toString(16).padStart(6, '0') + '  ' +
                        JSON.stringify(s.text).slice(0, 90) + kind);
        }
    }

    // ----------------------------------------------------------------------
    // Record boundaries.
    //
    // A conversation record opens with four strings in fixed order:
    //     [name] [per-record author] [per-record summary] [owner speaker]
    // e.g. MagdaleneHijackTheStation / CorpArmstrong / ArtemD / Magdalene
    //
    // An earlier version split records on the FILE-level summary string
    // instead. That breaks whenever a record's own author equals the file
    // summary -- in OpheliaL2.con both are "ArtemD" for several records, and
    // the MikeWongExposed SET (inside ContinueOn) was reported against
    // MeetSamanthaReed as a result. Matching the four-string shape positionally
    // has no such failure mode, so flags are attributed by offset.
    // ----------------------------------------------------------------------
    function kindOf(s) {
        if (flagSet.has(s.text)) return 'FLAG';
        if (speakerSet.has(s.text)) return 'SPK';
        return 'OTHER';
    }

    // Two header shapes occur. The common one is [name][author][summary][owner].
    // The first record in a file can instead read [name][speaker][author][owner]
    // -- OpheliaL2.con opens with SocialBoss / Tantalus / ArtemD /
    // DrMephistopheles -- so that variant is accepted too. Both require the
    // 4th string to be a speaker, which is what keeps dialogue labels (their
    // names look identical to record names) from being picked up: relaxing the
    // middle two to "anything" took OpheliaL2.con from 24 records to 79.
    const records = [];
    for (let i = 0; i + 3 < strs.length; i++) {
        const k = [0, 1, 2, 3].map(d => kindOf(strs[i + d]));
        const shapeA = k[0] === 'OTHER' && k[1] === 'OTHER' && k[2] === 'OTHER' && k[3] === 'SPK';
        const shapeB = k[0] === 'OTHER' && k[1] === 'SPK'   && k[2] === 'OTHER' && k[3] === 'SPK';
        if ((shapeA || shapeB) && /^[A-Za-z][A-Za-z0-9_]{2,40}$/.test(strs[i].text)) {
            records.push({ name: strs[i].text, owner: strs[i + 3].text,
                           off: strs[i].off, hdrEnd: strs[i + 3].off, flags: [] });
        }
    }

    // ----------------------------------------------------------------------
    // Flag reference direction.
    //
    // Every flag reference ends with the same three ints before the name:
    //     [1][flagIndex][nameLen] "FlagName"
    // The 1 is the marker that makes a reference findable at all. What sits
    // in FRONT of that marker is what distinguishes the kinds, and only these
    // shapes have been confirmed against real files:
    //
    //   SET     [type=2][0][1][idx]     ConPlayBase.EEventType ET_SetFlag
    //   CHECK   [type=3][0][1][idx]     ET_CheckFlag
    //   PRECOND [-1][-1][0]...[1][idx]  the availability condition ConEdit
    //                                   shows in "Conversation Properties" --
    //                                   NOT an event, and it decides whether
    //                                   the conversation can start at all
    //   REF     marker present, none of the above. Seen where a flag rides
    //           along with a choice or a label (the bytes in front are the
    //           preceding string, e.g. an .mp3 path or "EndOfConvo").
    //           Reported honestly as unclassified rather than guessed at.
    //
    // Polarity is NOT recoverable here: whether a PRECOND wants the flag true
    // or false is not encoded in any int this scan can identify. Treat a
    // PRECOND as "this conversation is gated on this flag", nothing more.
    // ----------------------------------------------------------------------
    function directionAt(off) {
        if (off - 28 < 0) return '?';
        const i = d => r.buf.readInt32LE(off + d);
        if (i(-8) !== 1) return '?';                 // no flag-reference marker
        const idx = i(-4);
        if (idx < 0 || idx > 4096) return '?';
        if (i(-28) === -1 && i(-24) === -1 && i(-20) === 0) return 'PRECOND';
        if (i(-16) === 2 && i(-12) === 0) return 'SET';
        if (i(-16) === 3 && i(-12) === 0) return 'CHECK';
        return 'REF';
    }

    // Flags can also appear ahead of the first record - the tail of the file
    // header. They are still real references, so they get their own bucket
    // rather than being silently dropped.
    const preRecord = { name: '(file header, before first conversation)',
                        owner: '-', off: 0, hdrEnd: 0, flags: [] };

    for (const s of strs) {
        if (kindOf(s) !== 'FLAG') continue;
        let rec = null;
        for (const c of records) { if (c.off < s.off) rec = c; else break; }
        if (!rec) rec = preRecord;
        const dir = directionAt(s.off);
        // A reference sitting between the owner line and the first dialogue
        // is in the header region, which corroborates a PRECOND reading.
        const inHeader = s.off - rec.hdrEnd < 256;
        rec.flags.push({ name: s.text, off: s.off, dir, inHeader });
    }
    if (preRecord.flags.length) records.unshift(preRecord);

    if (args.includes('--records')) {
        console.log('\n--- conversation records (file order) ---');
        for (const rec of records) {
            console.log(`\n${rec.name}  [owner: ${rec.owner}]  @0x${rec.off.toString(16).padStart(6, '0')}`);
            if (rec.flags.length === 0) { console.log('    (no flag references)'); continue; }
            for (const f of rec.flags)
                console.log(`    ${f.dir.padEnd(8)} ${f.name.padEnd(26)} @0x${f.off.toString(16).padStart(6, '0')}` +
                            (f.inHeader && f.dir !== 'PRECOND' ? '  (header region)' : ''));
        }
    }

    if (args.includes('--flagmap')) {
        const map = {};
        for (const rec of records)
            for (const f of rec.flags) {
                const entry = rec.name + (f.dir === '?' ? '' : ' [' + f.dir + ']');
                if (!map[f.name]) map[f.name] = [];
                if (map[f.name].indexOf(entry) === -1) map[f.name].push(entry);
            }

        console.log('\n--- flag -> conversations referencing it ---');
        const names = Object.keys(map).sort();
        if (names.length === 0) console.log('  (none)');
        for (const f of names)
            console.log('  ' + f.padEnd(34) + map[f].join(', '));

        const unused = [...flagSet].filter(f => !map[f]).sort();
        if (unused.length)
            console.log('\n  declared but never referenced: ' + unused.join(', '));

        // A flag no conversation SETs must come from script, a map actor, or
        // an earlier level -- exactly the case that silently breaks a level
        // when you enter it directly. Worth calling out on its own.
        const setSomewhere = new Set();
        for (const rec of records)
            for (const f of rec.flags) if (f.dir === 'SET') setSomewhere.add(f.name);
        const neverSet = Object.keys(map).filter(f => !setSomewhere.has(f)).sort();
        if (neverSet.length)
            console.log('\n  referenced but never SET in this file: ' + neverSet.join(', '));
    }
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
