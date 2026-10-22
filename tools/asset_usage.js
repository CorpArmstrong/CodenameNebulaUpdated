#!/usr/bin/env node
/*
 * asset_usage.js - which shipped textures, sounds, meshes and music the game
 * really loads, per package and per map.
 *
 * Input: objects.tsv from tools/cnn_objdump.ps1 (what the engine had loaded
 * on each map) and the packages of a distribution folder. An export no map
 * loads is unused, unless code names it in a string (DynamicLoadObject) --
 * those are listed as "by name". Conversation audio is played by name too,
 * so the CNNAudio* packages are only summed up.
 *
 * Usage:
 *   node tools/asset_usage.js <objects.tsv> [distDir=CodenameNebula] [--list <pkg>]
 */
'use strict';
const fs = require('fs');
const path = require('path');
const { load } = require('./pkg_probe');

const [tsv, distArg, flag, listPkg] = process.argv.slice(2);
if (!tsv) { console.error(fs.readFileSync(__filename, 'utf8').split('*/')[0]); process.exit(1); }
const dist = distArg || 'CodenameNebula';
const repo = path.join(__dirname, '..');

const KIND = {
  Texture: 'tex', FireTexture: 'tex', WetTexture: 'tex', WaveTexture: 'tex', WaterTexture: 'tex',
  IceTexture: 'tex', FractalTexture: 'tex', ScriptedTexture: 'tex',
  Sound: 'snd', Mesh: 'mesh', LodMesh: 'mesh', Music: 'music', Class: 'class',
};

// loaded objects: full name -> set of maps
const loaded = new Map();
for (const line of fs.readFileSync(tsv, 'utf8').replace(/^﻿/, '').split(/\r?\n/)) {
  const [map, , obj] = line.split('\t');
  if (!obj) continue;
  const k = obj.toLowerCase();
  if (!loaded.has(k)) loaded.set(k, new Set());
  loaded.get(k).add(map);
}

// strings in the script source that name an object ("Pkg.Name" / "Pkg.Group.Name")
const named = new Set();
const classDir = path.join(repo, 'CNN', 'Classes');
for (const f of fs.readdirSync(classDir)) {
  if (!f.endsWith('.uc')) continue;
  const src = fs.readFileSync(path.join(classDir, f), 'latin1');
  for (const m of src.matchAll(/"([A-Za-z_]\w*(?:\.\w+)+)"/g)) named.add(m[1].toLowerCase());
}

const pkgFiles = [];
for (const [sub, re] of [['System', /\.u$/i], ['Textures', /\.utx$/i], ['Music', /\.umx$/i]]) {
  const d = path.join(dist, sub);
  if (!fs.existsSync(d)) continue;
  for (const f of fs.readdirSync(d)) if (re.test(f)) pkgFiles.push(path.join(d, f));
}

const mb = (n) => (n / 1048576).toFixed(1);
const rows = [];
for (const file of pkgFiles) {
  const pkg = path.basename(file).replace(/\.\w+$/, '');
  let P;
  try { P = load(file); } catch (e) { rows.push({ pkg, err: e.message }); continue; }
  const r = { pkg, file, bytes: fs.statSync(file).size, kinds: {}, unused: [], byName: [], maps: new Set() };
  P.exports.forEach((e, i) => {
    const cls = P.className(e);
    const kind = KIND[cls];
    if (!kind) return;
    const full = `${pkg}.${P.objPath(i + 1)}`;
    const k = r.kinds[kind] || (r.kinds[kind] = { n: 0, used: 0, size: 0, unusedSize: 0 });
    k.n++; k.size += e.size;
    const maps = loaded.get(full.toLowerCase());
    if (maps) { k.used++; maps.forEach((m) => r.maps.add(m)); return; }
    if (named.has(full.toLowerCase())) { r.byName.push(`${cls} ${full}`); k.used++; return; }
    k.unusedSize += e.size;
    r.unused.push({ cls, full, size: e.size });
  });
  rows.push(r);
}

if (flag === '--list') {
  const r = rows.find((x) => x.pkg.toLowerCase() === (listPkg || '').toLowerCase());
  if (!r) throw new Error('no package ' + listPkg);
  for (const u of r.unused.sort((a, b) => b.size - a.size)) console.log(`${u.cls}\t${u.full}\t${u.size}`);
  for (const b of r.byName) console.log(`(by name) ${b}`);
  process.exit(0);
}

const order = ['tex', 'snd', 'mesh', 'music', 'class'];
console.log('package\tfile MB\tunused MB\t' + order.map((k) => `${k} used/all`).join('\t') + '\tmaps');
for (const r of rows.sort((a, b) => a.pkg.localeCompare(b.pkg))) {
  if (r.err) { console.log(`${r.pkg}\tERROR ${r.err}`); continue; }
  const unusedBytes = order.filter((k) => k !== 'class').reduce((s, k) => s + (r.kinds[k] ? r.kinds[k].unusedSize : 0), 0);
  const cols = order.map((k) => (r.kinds[k] ? `${r.kinds[k].used}/${r.kinds[k].n}` : '-'));
  console.log(`${r.pkg}\t${mb(r.bytes)}\t${mb(unusedBytes)}\t${cols.join('\t')}\t${[...r.maps].sort().join(',')}`);
}
