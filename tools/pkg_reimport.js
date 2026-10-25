#!/usr/bin/env node
/*
 * pkg_reimport.js - point a package's imports at other objects.
 *
 * A map that borrows a texture from a package we no longer ship can take a
 * texture from another package instead, without UnrealEd: every surface and
 * actor refers to the texture through one import entry, so changing that
 * entry's name and outer moves all of them at once.
 *
 * Where it fits, only fixed-size fields are touched (the outer is an INT, a
 * name a compact index of the same length) and nothing else in the file
 * moves. When a name's index needs more bytes than the old one had, or the
 * new path needs names or package/group imports the map does not have yet,
 * the name and/or import table is written again at the end of the file, new
 * entries appended, and the header pointed at it: names and imports are
 * referred to by number, never by file offset, and appending keeps every
 * existing number.
 *
 * Usage:
 *   node tools/pkg_reimport.js <pkg> <Old.Path>=<New.Path> ... [--write]
 *
 * Without --write it only prints what it would change. Every import the
 * package still has afterwards must resolve, so a package that is dropped
 * entirely is renamed too (TITAN=Rocket): a duplicate import is harmless.
 */
'use strict';
const fs = require('fs');
const { load, Reader } = require('./pkg_probe.js');

// FCompactIndex: sign + continue + 6 bits, then continue + 7 bits per byte.
// Padded to len with zero continuation bytes, which the engine reads the same.
function ciBytes(v, len = 0) {
  let a = Math.abs(v);
  const out = [(v < 0 ? 0x80 : 0) | (a & 0x3f)];
  a >>>= 6;
  while (a || out.length < len) { out[out.length - 1] |= out.length === 1 ? 0x40 : 0x80; out.push(a & 0x7f); a >>>= 7; }
  return out;
}

// Import table: raw indices, and the file offset of each field we may rewrite.
function importFields(P) {
  const r = new Reader(P.buf, P.buf.readUInt32LE(32));
  return P.imports.map(() => {
    const classPkg = r.ci(), className = r.ci();
    const pkgAt = r.p; const pkg = r.i32();
    const nameAt = r.p; const name = r.ci();
    return { classPkg, className, pkg, name, pkgAt, nameAt, nameLen: r.p - nameAt };
  });
}

function serializeImports(fields) {
  const bytes = [];
  for (const f of fields) {
    bytes.push(...ciBytes(f.classPkg), ...ciBytes(f.className));
    const b = Buffer.alloc(4); b.writeInt32LE(f.pkg); bytes.push(...b);
    bytes.push(...ciBytes(f.name));
  }
  return Buffer.from(bytes);
}

// Name entry as in v68 packages: length-prefixed zero-terminated string, flags.
function serializeName(s, flags) {
  const f = Buffer.alloc(4); f.writeUInt32LE(flags);
  return Buffer.concat([Buffer.from(ciBytes(s.length + 1)), Buffer.from(s + '\0', 'latin1'), f]);
}

// Byte range and flags of the name table as it is in the file.
function nameTable(P) {
  const r = new Reader(P.buf, P.buf.readUInt32LE(16));
  const start = r.p, flags = [];
  for (let i = 0; i < P.names.length; i++) { r.str(); flags.push(r.u32()); }
  return { start, end: r.p, flags };
}

function main() {
  const args = process.argv.slice(2);
  const write = args.includes('--write');
  const [path, ...maps] = args.filter((a) => a !== '--write');
  if (!path || !maps.length) { console.error(fs.readFileSync(__filename, 'utf8').split('*/')[0]); process.exit(1); }

  const P = load(path);
  if (P.ver < 64) throw new Error('only packages of version 64 and later');
  const fields = importFields(P);
  const names = [...P.names], newNames = [];
  const paths = P.imports.map((im, i) => P.objPath(-(i + 1)));
  const lower = (s) => s.toLowerCase();

  const nameIndex = (s) => {
    let i = names.findIndex((n) => lower(n) === lower(s));
    if (i < 0) { i = names.length; names.push(s); newNames.push(s); }
    return i;
  };
  // the import of a package or group, added (with its outers) when missing
  const packageImport = (p) => {
    const i = paths.findIndex((x) => lower(x) === lower(p));
    if (i >= 0) return -(i + 1);
    const parts = p.split('.');
    const outer = parts.length > 1 ? packageImport(parts.slice(0, -1).join('.')) : 0;
    fields.push({ classPkg: nameIndex('Core'), className: nameIndex('Package'), pkg: outer, name: nameIndex(parts[parts.length - 1]) });
    paths.push(p);
    console.log(`+${-fields.length} Package ${p}`);
    return -fields.length;
  };

  const patches = [];
  for (const m of maps) {
    const [from, to] = m.split('=');
    const i = paths.findIndex((x) => lower(x) === lower(from));
    if (i < 0 || i >= P.imports.length) throw new Error(`${from}: no such import`);
    const parts = to.split('.');
    const outer = parts.length > 1 ? packageImport(parts.slice(0, -1).join('.')) : 0;
    patches.push({ i, from, to, outer, ni: nameIndex(parts[parts.length - 1]) });
  }

  let buf = P.buf;
  const added = fields.length > P.imports.length;
  const inPlace = !added && !newNames.length &&
    patches.every((p) => ciBytes(p.ni, fields[p.i].nameLen).length === fields[p.i].nameLen);
  for (const p of patches) {
    console.log(`${-(p.i + 1)} ${P.imports[p.i].className} ${p.from} -> ${p.to}`);
    fields[p.i].pkg = p.outer;
    fields[p.i].name = p.ni;
    if (inPlace) {
      buf.writeInt32LE(p.outer, fields[p.i].pkgAt);
      Buffer.from(ciBytes(p.ni, fields[p.i].nameLen)).copy(buf, fields[p.i].nameAt);
    }
  }
  if (!inPlace) {
    const parts = [buf];
    let at = buf.length;
    const header = Buffer.from(buf.subarray(0, 64));
    if (newNames.length) {
      // the old table copied whole, the new names after it; flags as on the package names
      const t = nameTable(P), flags = t.flags[P.names.findIndex((n) => n === 'Core')] || 0x70010;
      const table = Buffer.concat([buf.subarray(t.start, t.end), ...newNames.map((s) => serializeName(s, flags))]);
      header.writeUInt32LE(names.length, 12); header.writeUInt32LE(at, 16);
      // the last generation records the name count too
      const gens = header.readUInt32LE(52);
      if (gens) header.writeUInt32LE(names.length, 56 + (gens - 1) * 8 + 4);
      parts.push(table); at += table.length;
      console.log(`name table moved to the end, ${newNames.length} added: ${newNames.join(' ')}`);
    }
    const imports = serializeImports(fields);
    header.writeUInt32LE(fields.length, 28); header.writeUInt32LE(at, 32);
    parts.push(imports);
    buf = Buffer.concat(parts);
    header.copy(buf, 0);
    console.log(`import table moved to the end${added ? `, ${fields.length - P.imports.length} added` : ''} (+${buf.length - P.buf.length} bytes)`);
  }

  // read the patched tables back before anything is written
  const R = reload(buf);
  for (const p of patches) {
    const got = R.objPath(-(p.i + 1));
    if (lower(got) !== lower(p.to)) throw new Error(`${p.from}: reads back as ${got}, expected ${p.to}`);
  }
  P.imports.forEach((im, i) => {
    if (patches.some((p) => p.i === i)) return;
    const a = P.objPath(-(i + 1)), b = R.objPath(-(i + 1));
    if (a !== b && !patches.some((p) => a.startsWith(p.from + '.'))) throw new Error(`${a} changed to ${b}`);
  });
  if (R.exports.length !== P.exports.length || R.names.length !== names.length) throw new Error('tables read back wrong');
  if (write) { fs.writeFileSync(path, buf); console.log(`wrote ${path}`); }
  else console.log('dry run; add --write to apply');
}

// load() reads a path; parse a patched buffer through a temp copy of the same reader
function reload(buf) {
  const tmp = require('os').tmpdir() + `/pkg_reimport_${process.pid}.tmp`;
  fs.writeFileSync(tmp, buf);
  try { return load(tmp); } finally { fs.unlinkSync(tmp); }
}

if (require.main === module) main();
