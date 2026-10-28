#!/usr/bin/env node
/*
 * pkg_setprop.js - set an actor's properties in a map without UnrealEd.
 *
 * An actor's properties are a tagged list in its export: a property left at
 * the class default is simply absent. Adding one makes the object longer, so
 * the object is written again at the end of the file and its export entry
 * pointed there; the export table, whose entries hold the size and offset as
 * compact indices, is written again at the end too. Objects are referred to
 * by number, never by file offset, so nothing else changes. The old copies
 * stay behind as dead bytes for tools/pkg_deadbytes.js.
 *
 * Usage:
 *   node tools/pkg_setprop.js <pkg> <Object> <Prop>=<value> ... [--write]
 * A value of true/false is a bool, a number a byte (Physics=0 is PHYS_None),
 * unless the object already has the property, whose type is then kept.
 * An empty value (Mesh=) removes the property: the object takes the class
 * default again.
 * A name the package does not have yet is added: the name table is written
 * again at the end with the new names after the old ones, which keep their
 * numbers.
 *
 * Without --write it only prints what it would change.
 */
'use strict';
const fs = require('fs');
const { load, Reader, readProps } = require('./pkg_probe.js');
const { ciBytes, serializeName, nameTable } = require('./pkg_reimport.js');

// Export table: raw fields of every entry, as in the file.
function exportFields(P) {
  const r = new Reader(P.buf, P.buf.readUInt32LE(24));
  return P.exports.map(() => {
    const f = { cls: r.ci(), sup: r.ci(), pkg: r.i32(), name: r.ci(), flags: r.u32(), size: r.ci() };
    f.off = f.size > 0 ? r.ci() : 0;
    return f;
  });
}

function serializeExports(fields) {
  const bytes = [];
  for (const f of fields) {
    bytes.push(...ciBytes(f.cls), ...ciBytes(f.sup));
    const b = Buffer.alloc(8); b.writeInt32LE(f.pkg, 0); b.writeUInt32LE(f.flags, 4);
    bytes.push(...b.subarray(0, 4), ...ciBytes(f.name), ...b.subarray(4), ...ciBytes(f.size));
    if (f.size > 0) bytes.push(...ciBytes(f.off));
  }
  return Buffer.from(bytes);
}

// One tagged property: name, info byte (type, size code, array bit), value.
function tagBytes(nameIndex, type, value) {
  if (type === 3) return Buffer.from([...ciBytes(nameIndex), 0x03 | (value ? 0x80 : 0)]);
  if (type === 1) return Buffer.from([...ciBytes(nameIndex), 0x01, value & 0xff]);
  if (type === 2) { const b = Buffer.alloc(4); b.writeInt32LE(value); return Buffer.from([...ciBytes(nameIndex), 0x22, ...b]); }
  throw new Error(`property type ${type} not supported`);
}

function main() {
  const args = process.argv.slice(2);
  const write = args.includes('--write');
  const [path, objName, ...sets] = args.filter((a) => a !== '--write');
  if (!path || !objName || !sets.length) { console.error(fs.readFileSync(__filename, 'utf8').split('*/')[0]); process.exit(1); }

  const P = load(path);
  const i = P.exports.findIndex((e) => e.name.toLowerCase() === objName.toLowerCase());
  if (i < 0) throw new Error(`${objName}: no such export`);
  const e = P.exports[i];

  // state frame (as in objProps), then the property list, then whatever the class serializes after it
  const r = new Reader(P.buf, e.off);
  if (e.flags & 0x02000000) { const node = r.ci(); r.ci(); r.p += 8; r.i32(); if (node) r.ci(); }
  const frame = P.buf.subarray(e.off, r.p);
  const { props, end } = readProps(P, r);
  const rest = P.buf.subarray(end, e.off + e.size);

  const names = [...P.names], newNames = [];
  const changes = sets.map((s) => {
    const [name, v] = s.split('=');
    const old = props.find((p) => p.name.toLowerCase() === name.toLowerCase());
    if (v === '') {
      if (!old) throw new Error(`${name}: ${e.name} does not set it`);
      console.log(`${P.className(e)} ${e.name}: ${old.name} ${JSON.stringify(old.value)} -> (default)`);
      return { name: old.name, bytes: Buffer.alloc(0) };
    }
    let ni = names.findIndex((n) => n.toLowerCase() === name.toLowerCase());
    if (ni < 0) { ni = names.length; names.push(name); newNames.push(name); }
    const type = old ? old.type : /^(true|false)$/i.test(v) ? 3 : 1;
    const value = type === 3 ? /^true$/i.test(v) : parseInt(v, 10);
    console.log(`${P.className(e)} ${e.name}: ${names[ni]} ${old ? JSON.stringify(old.value) : '(default)'} -> ${JSON.stringify(value)}`);
    return { name: names[ni], bytes: tagBytes(ni, type, value) };
  });

  // A name only the editor needed (no RF_LoadForClient/Server) loads as None in
  // the game and ends the property list there: "Serial size mismatch".
  const nr = new Reader(P.buf, P.buf.readUInt32LE(16));
  for (let k = 0; k < P.names.length; k++) {
    nr.str();
    const flagsAt = nr.p, flags = nr.u32();
    if ((flags & 0x30000) !== 0x30000 && changes.some((c) => c.bytes.length && c.name === P.names[k])) {
      P.buf.writeUInt32LE(flags | 0x30000, flagsAt);
      console.log(`name ${P.names[k]}: flags ${flags.toString(16)} -> ${(flags | 0x30000).toString(16)} (loaded by the game too)`);
    }
  }

  const kept = props.filter((p) => !changes.some((c) => c.name.toLowerCase() === p.name.toLowerCase()));
  const data = Buffer.concat([frame, ...kept.map((p) => P.buf.subarray(p.at, p.to)), ...changes.map((c) => c.bytes),
    Buffer.from(ciBytes(P.names.indexOf('None'))), rest]);

  const parts = [P.buf];
  let at = P.buf.length;
  const header = Buffer.from(P.buf.subarray(0, 64));
  if (newNames.length) {
    // the old table copied whole, the new names after it; flags as on the package names
    const t = nameTable(P), flags = t.flags[P.names.findIndex((n) => n === 'Core')] || 0x70010;
    const table = Buffer.concat([P.buf.subarray(t.start, t.end), ...newNames.map((s) => serializeName(s, flags))]);
    header.writeUInt32LE(names.length, 12); header.writeUInt32LE(at, 16);
    // the last generation records the name count too
    const gens = header.readUInt32LE(52);
    if (gens) header.writeUInt32LE(names.length, 56 + (gens - 1) * 8 + 4);
    parts.push(table); at += table.length;
    console.log(`name table moved to the end, added: ${newNames.join(' ')}`);
  }
  const fields = exportFields(P);
  fields[i].off = at;
  fields[i].size = data.length;
  parts.push(data); at += data.length;
  header.writeUInt32LE(at, 24);
  parts.push(serializeExports(fields));
  const buf = Buffer.concat(parts);
  header.copy(buf, 0);
  console.log(`object moved to the end (${e.size} -> ${data.length} bytes), export table after it (+${buf.length - P.buf.length} bytes)`);

  // read it back before anything is written
  const R = reload(buf);
  if (R.exports.length !== P.exports.length || R.names.length !== names.length) throw new Error('tables read back wrong');
  P.exports.forEach((o, k) => {
    const n = R.exports[k];
    if (n.name !== o.name || n.cls !== o.cls || n.pkg !== o.pkg) throw new Error(`export ${k + 1} reads back wrong`);
    if (k !== i && (n.off !== o.off || n.size !== o.size)) throw new Error(`export ${k + 1} moved`);
  });
  const rr = new Reader(R.buf, R.exports[i].off + frame.length);
  const got = readProps(R, rr);
  if (rr.p + rest.length !== R.exports[i].off + R.exports[i].size) throw new Error('property list reads back wrong');
  for (const p of got.props) console.log(`  ${p.name} = ${JSON.stringify(p.value)}`);

  if (write) { fs.writeFileSync(path, buf); console.log(`wrote ${path}`); }
  else console.log('dry run; add --write to apply');
}

// load() reads a path; parse a patched buffer through a temp copy of the same reader
function reload(buf) {
  const tmp = require('os').tmpdir() + `/pkg_setprop_${process.pid}.tmp`;
  fs.writeFileSync(tmp, buf);
  try { return load(tmp); } finally { fs.unlinkSync(tmp); }
}

if (require.main === module) main();
