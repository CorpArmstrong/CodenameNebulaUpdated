#!/usr/bin/env node
/*
 * pkg_reimport.js - point a package's imports at other objects, in place.
 *
 * A map that borrows a texture from a package we no longer ship can take the
 * same texture from a stock package instead, without UnrealEd: every surface
 * and actor refers to the texture through one import entry, so changing that
 * entry's name and outer moves all of them at once. Where it fits, only
 * fixed-size fields are touched (the outer is an INT, a name a compact index
 * of the same length) and nothing else in the file moves. When a new name's
 * index needs more bytes than the old one had, the whole import table is
 * written again at the end of the file and the header pointed at it: imports
 * are referred to by number, never by file offset. The new outer must already
 * be imported, and the new name must already be in the name table.
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

// The table serialized again, appended to the file; the header's ImportOffset moves to it.
function relocateImports(buf, fields) {
  const bytes = [];
  for (const f of fields) {
    bytes.push(...ciBytes(f.classPkg), ...ciBytes(f.className));
    const b = Buffer.alloc(4); b.writeInt32LE(f.pkg); bytes.push(...b);
    bytes.push(...ciBytes(f.name));
  }
  const out = Buffer.concat([buf, Buffer.from(bytes)]);
  out.writeUInt32LE(buf.length, 32);
  return out;
}

function main() {
  const args = process.argv.slice(2);
  const write = args.includes('--write');
  const [path, ...maps] = args.filter((a) => a !== '--write');
  if (!path || !maps.length) { console.error(fs.readFileSync(__filename, 'utf8').split('*/')[0]); process.exit(1); }

  const P = load(path);
  const fields = importFields(P);
  const paths = P.imports.map((im, i) => P.objPath(-(i + 1)));
  const byPath = (p) => paths.findIndex((x) => x.toLowerCase() === p.toLowerCase());
  const patches = [];

  for (const m of maps) {
    const [from, to] = m.split('=');
    const i = byPath(from);
    if (i < 0) throw new Error(`${from}: no such import`);
    const parts = to.split('.');
    const name = parts.pop();
    let outer = 0;
    if (parts.length) {
      const o = byPath(parts.join('.'));
      if (o < 0) throw new Error(`${to}: ${parts.join('.')} is not imported`);
      outer = -(o + 1);
    }
    const ni = P.names.findIndex((n) => n.toLowerCase() === name.toLowerCase());
    if (ni < 0) throw new Error(`${to}: name ${name} is not in the name table`);
    patches.push({ i, from, to, outer, ni });
  }

  let buf = P.buf;
  const inPlace = patches.every((p) => ciBytes(p.ni, fields[p.i].nameLen).length === fields[p.i].nameLen);
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
    buf = relocateImports(buf, fields);
    console.log(`import table moved to the end of the file (+${buf.length - P.buf.length} bytes)`);
  }

  // read the patched table back before anything is written
  const R = reload(buf);
  for (const p of patches) {
    const got = R.objPath(-(p.i + 1));
    if (got.toLowerCase() !== p.to.toLowerCase()) throw new Error(`${p.from}: reads back as ${got}, expected ${p.to}`);
  }
  if (R.imports.length !== P.imports.length || R.exports.length !== P.exports.length) throw new Error('tables read back wrong');
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
