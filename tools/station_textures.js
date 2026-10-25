#!/usr/bin/env node
/*
 * station_textures.js - the station's own textures, in place of Ophelia.utx.
 *
 * Part of Ophelia.utx may come from the Unity Asset Store, whose licence does
 * not allow shipping the files in a form players can extract (a .utx opens in
 * any UnrealEd). The plain walls and floors now use stock Deus Ex textures
 * (tools/pkg_reimport.js in the maps); the rest are rebuilt here, each at the
 * size of the texture it replaces so the surfaces keep their mapping:
 *   - from "Zortch World Textures" by mutantleg (CC0, opengameart.org/content/
 *     zortch-world-textures), copied, cropped, repeated 2x2 or brightened;
 *   - hazard markings, the plain floor plates and most screens drawn from
 *     scratch below;
 *   - the rec-room TV: "Close Image of Flying Saucer", Air Force Office of
 *     Special Investigations (US government work, public domain; Wikimedia
 *     Commons File:Flying_Saucer.webp, 960px PNG preview), cropped.
 * Output: 24-bit BMPs in CNN/Textures/Station, imported into CNN.u by
 * CNN/Classes/CNNTextures.uc as CNN.Station.<the name Ophelia used>. FloorTech03
 * was a copy of GravityFloor and now uses it.
 *
 * Usage: node tools/station_textures.js <zortchskin folder> <folder with Flying_Saucer.png>
 *
 * Written 2026-10-25 (CNNDocs/Third_Party_Textures.md).
 */
'use strict';
const fs = require('fs');
const path = require('path');
const { readPng } = require('./tex_lookalike.js');

const OUT = path.join(__dirname, '..', 'CNN', 'Textures', 'Station');

// name -> how to make it (w x h is Ophelia's size)
const TEXTURES = {
  Wall02c:      { w: 256, h: 256, zortch: 'tile150', gain: 1.6 },
  pod_door:     { w: 512, h: 512, zortch: 'tile327' },
  GravityFloor: { w: 256, h: 256, draw: 'panelFloor' },
  u_ceiling01:  { w: 512, h: 512, zortch: 'tile509' },
  mp_b_carb02:  { w: 512, h: 512, zortch: 'tile339' },
  rustmetal1:   { w: 512, h: 512, zortch: 'tile514' },
  guts:         { w: 1024, h: 1024, zortch: 'tile510', tile: true },
  panels_ext:   { w: 1024, h: 1024, zortch: 'tile232', tile: true },
  u_wall06:     { w: 256, h: 512, zortch: 'tile186', crop: [0, 0] },
  u_casing01:   { w: 512, h: 256, zortch: 'tile30', crop: [0, 128] },
  Wall01c:      { w: 256, h: 256, draw: 'stripeBands' },
  FloorTech01b: { w: 256, h: 256, draw: 'stripedDisc' },
  FloorTech01c: { w: 256, h: 256, draw: 'stripedRing' },
  FloorTech05b: { w: 256, h: 256, draw: 'redStripes' },
  // screens that lost their pictures (L1); sized to the surfaces' mapping
  ScreenRecRoom:  { w: 512, h: 512, photo: 'Flying_Saucer.png', crop: [170, 40, 680] },
  ScreenMedical:  { w: 512, h: 512, draw: 'heartMonitor' },
  ScreenSecurity: { w: 1024, h: 512, draw: 'cameraFeeds' },
  ScreenStation:  { w: 1024, h: 512, draw: 'stationMap' },
  ScreenConsole:  { w: 64, h: 64, draw: 'consoleGlow' },
};

// ---- from Zortch: copy, repeat 2x2, or cut a window out

function fromZortch(dir, t) {
  const src = readPng(path.join(dir, t.zortch + '.png'));
  if (!src) throw new Error(`${t.zortch}: unreadable`);
  const [ox, oy] = t.crop || [0, 0];
  const rgb = Buffer.alloc(t.w * t.h * 3);
  for (let y = 0; y < t.h; y++) for (let x = 0; x < t.w; x++) {
    const sx = (t.tile ? x : x + ox) % src.w, sy = (t.tile ? y : y + oy) % src.h;
    if (!t.tile && (x + ox >= src.w || y + oy >= src.h)) throw new Error(`${t.zortch}: crop outside the image`);
    src.rgb.copy(rgb, (y * t.w + x) * 3, (sy * src.w + sx) * 3, (sy * src.w + sx) * 3 + 3);
  }
  if (t.tile && (src.w * 2 !== t.w || src.h * 2 !== t.h)) throw new Error(`${t.zortch}: ${src.w}x${src.h} does not tile to ${t.w}x${t.h}`);
  if (t.gain) for (let i = 0; i < rgb.length; i++) rgb[i] = Math.min(255, rgb[i] * t.gain);
  return rgb;
}

// ---- drawn: brushed metal plate with a bevelled edge, then the markings

const N = 256;
let seed = 7;
const rnd = () => { seed = (seed * 1103515245 + 12345) & 0x7fffffff; return seed / 0x7fffffff; };
const G = 32, grid = [...Array(G * G)].map(rnd);
function noise(x, y) {
  const gx = x / N * G, gy = y / N * G, x0 = Math.floor(gx), y0 = Math.floor(gy), fx = gx - x0, fy = gy - y0;
  const g = (i, j) => grid[((j % G + G) % G) * G + ((i % G + G) % G)];
  const a = g(x0, y0) + (g(x0 + 1, y0) - g(x0, y0)) * fx, b = g(x0, y0 + 1) + (g(x0 + 1, y0 + 1) - g(x0, y0 + 1)) * fx;
  return a + (b - a) * fy;
}

function plate(base) {
  const img = new Float32Array(N * N * 3);
  for (let y = 0; y < N; y++) for (let x = 0; x < N; x++) {
    const n = 0.85 + 0.15 * noise(x, y) + 0.04 * (rnd() - 0.5) + 0.03 * Math.sin(y * 0.9);
    const e = Math.min(x, y, N - 1 - x, N - 1 - y);
    let k = 1;
    if (e < 3) k = x < 3 || y < 3 ? 1.35 : 0.55;
    else if (e < 6) k = x < 6 || y < 6 ? 1.12 : 0.8;
    for (let c = 0; c < 3; c++) img[(y * N + x) * 3 + c] = base[c] * n * k;
  }
  return img;
}

function paint(img, test, col) {
  for (let y = 0; y < N; y++) for (let x = 0; x < N; x++) {
    if (!test(x, y)) continue;
    const n = 0.88 + 0.12 * noise(x + 97, y + 31);
    for (let c = 0; c < 3; c++) img[(y * N + x) * 3 + c] = col[c] * n;
  }
}

const stripe = (x, y, w) => Math.floor((x + y) / w) % 2 === 0;
const r = (x, y) => Math.hypot(x - 128, y - 128);
const YELLOW = [214, 176, 40], BLACK = [28, 28, 26], RED = [190, 40, 36], WHITE = [226, 226, 222], GREY = [150, 152, 155];

const DRAW = {
  // light floor plate in four quarters around a round centre, as the station's main floor was
  panelFloor() {
    const img = plate([176, 179, 184]);
    const seam = (v) => Math.abs(v - 128) < 2;
    paint(img, (x, y) => (seam(x) || seam(y)) && r(x, y) > 46, [92, 95, 100]);
    paint(img, (x, y) => Math.abs(r(x, y) - 46) < 2, [92, 95, 100]);
    paint(img, (x, y) => r(x, y) < 44, [160, 163, 168]);
    paint(img, (x, y) => [[24, 24], [232, 24], [24, 232], [232, 232], [104, 24], [152, 24], [24, 104], [24, 152], [232, 104], [232, 152], [104, 232], [152, 232]].some(([u, v]) => Math.hypot(x - u, y - v) < 3.5), [110, 112, 116]);
    return img;
  },
  stripeBands() {
    const img = plate(YELLOW);
    paint(img, (x, y) => ((y > 22 && y < 58) || (y > 198 && y < 234)) && x > 8 && x < 248 && stripe(x, y, 22), BLACK);
    return img;
  },
  stripedDisc() {
    const img = plate(GREY);
    paint(img, (x, y) => r(x, y) < 92, YELLOW);
    paint(img, (x, y) => r(x, y) < 92 && stripe(x, y, 26), BLACK);
    paint(img, (x, y) => r(x, y) >= 92 && r(x, y) < 97, [90, 92, 95]);
    return img;
  },
  stripedRing() {
    const img = plate(GREY);
    paint(img, (x, y) => r(x, y) > 52 && r(x, y) < 98, YELLOW);
    paint(img, (x, y) => r(x, y) > 52 && r(x, y) < 98 && stripe(x, y, 24), BLACK);
    const corner = (u, v) => u > 8 && v > 8 && u < 40 && v < 40 && u + v < 54;
    paint(img, (x, y) => corner(x, y) || corner(255 - x, y) || corner(x, 255 - y) || corner(255 - x, 255 - y), YELLOW);
    return img;
  },
  redStripes() {
    const img = plate(WHITE);
    paint(img, (x, y) => x > 8 && x < 248 && y > 8 && y < 248 && stripe(x, y, 30), RED);
    return img;
  },
};

// ---- drawn screens: any size, a TV look (scanlines, darker edges) on top

function canvas(w, h, fill) {
  const img = new Float32Array(w * h * 3);
  const px = (x, y, col, a = 1) => {
    x = Math.round(x); y = Math.round(y);
    if (x < 0 || y < 0 || x >= w || y >= h) return;
    for (let c = 0; c < 3; c++) { const i = (y * w + x) * 3 + c; img[i] = img[i] * (1 - a) + col[c] * a; }
  };
  for (let y = 0; y < h; y++) for (let x = 0; x < w; x++) px(x, y, fill(x, y));
  const rect = (x0, y0, x1, y1, col, a) => { for (let y = y0; y < y1; y++) for (let x = x0; x < x1; x++) px(x, y, col, a); };
  const line = (x0, y0, x1, y1, col, t = 2) => {
    const n = Math.ceil(Math.hypot(x1 - x0, y1 - y0));
    for (let i = 0; i <= n; i++) rect(Math.round(x0 + (x1 - x0) * i / n - t / 2), Math.round(y0 + (y1 - y0) * i / n - t / 2),
      Math.round(x0 + (x1 - x0) * i / n + t / 2), Math.round(y0 + (y1 - y0) * i / n + t / 2), col, 1);
  };
  const tv = () => {
    for (let y = 0; y < h; y++) for (let x = 0; x < w; x++) {
      const e = Math.hypot((x - w / 2) / (w / 2), (y - h / 2) / (h / 2));
      const k = (y % 3 === 0 ? 0.8 : 1) * Math.max(0.35, 1 - 0.45 * e * e);
      for (let c = 0; c < 3; c++) img[(y * w + x) * 3 + c] *= k;
    }
  };
  return { img, px, rect, line, tv };
}

// 5x7 capitals and digits for screen labels
const FONT = {
  A: '01110100011000111111100011000110001', C: '01110100011000010000100001000101110',
  M: '10001110111010110001100011000110001', R: '11110100011000111110101001001010001',
  E: '11111100001000011110100001000011111', H: '10001100011000111111100011000110001',
  S: '01111100001000001110000010000111110', P: '11110100011000111110100001000010000',
  O: '01110100011000110001100011000101110', B: '11110100011000111110100011000111110',
  '0': '01110100011001110101110011000101110', '1': '00100011000010000100001000010001110',
  '2': '01110100010000100010001000100011111', '3': '11110000010000101110000010000111110',
  '4': '00010001100101010010111110001000010', '7': '11111000010001000100010000100001000',
  '8': '01110100011000101110100011000101110', '9': '01110100011000101111000010001001110',
  L: '10000100001000010000100001000011111', I: '01110001000010000100001000010001110',
  T: '11111001000010000100001000010000100', N: '10001110011010110011100011000110001',
  G: '01110100011000010111100011000101111', V: '10001100011000110001100010101000100',
  D: '11110100011000110001100011000111110', K: '10001100101010011000101001001010001',
  U: '10001100011000110001100011000101110', Y: '10001100010101000100001000010000100',
  W: '10001100011000110101101011010101010',
  '5': '11111100001111000001000011000101110', '6': '00110010001000011110100011000101110',
  '%': '11001110100001000100010000101110011', ':': '00000011000110000000011000110000000',
  ' ': '00000000000000000000000000000000000',
};
function text(cv, s, x, y, scale, col) {
  [...s].forEach((ch, i) => {
    const g = FONT[ch] || FONT[' '];
    for (let r = 0; r < 7; r++) for (let c = 0; c < 5; c++) if (g[r * 5 + c] === '1')
      cv.rect(x + (i * 6 + c) * scale, y + r * scale, x + (i * 6 + c + 1) * scale, y + (r + 1) * scale, col, 1);
  });
}

const SCREENS = {
  // the entrance info screen: a plan of the station with its systems
  stationMap(w, h) {
    const BLUE = [90, 170, 255], CYAN = [120, 230, 240], DIM = [40, 80, 130];
    const cv = canvas(w, h, (x, y) => (x % 32 === 0 || y % 32 === 0 ? [14, 30, 52] : [6, 14, 28]));
    const cx = 330, cy = 270;
    for (let a = 0; a < 720; a++) {                        // habitat ring, hub, spokes
      const t = a / 720 * Math.PI * 2;
      for (const [rr, col] of [[190, BLUE], [178, DIM], [46, CYAN]]) cv.rect(cx + rr * Math.cos(t) - 2, cy + rr * Math.sin(t) - 2, cx + rr * Math.cos(t) + 2, cy + rr * Math.sin(t) + 2, col, 1);
    }
    for (let k = 0; k < 6; k++) {
      const t = k / 6 * Math.PI * 2 + 0.3;
      cv.line(cx + 46 * Math.cos(t), cy + 46 * Math.sin(t), cx + 178 * Math.cos(t), cy + 178 * Math.sin(t), DIM, 4);
      const mx = cx + 184 * Math.cos(t), my = cy + 184 * Math.sin(t);   // a module on the ring
      cv.rect(mx - 18, my - 12, mx + 18, my + 12, [10, 24, 44], 1);
      for (const [x0, y0, x1, y1] of [[-18, -12, 18, -10], [-18, 10, 18, 12], [-18, -12, -16, 12], [16, -12, 18, 12]]) cv.rect(mx + x0, my + y0, mx + x1, my + y1, CYAN, 1);
    }
    cv.line(cx + 46, cy, cx + 120, cy - 120, BLUE, 3);     // docking arm
    cv.rect(cx + 112, cy - 150, cx + 160, cy - 120, [10, 24, 44], 1);
    text(cv, 'OPHELIA STATION', 40, 30, 4, CYAN);
    text(cv, 'DOCK', cx + 170, cy - 150, 3, BLUE);
    const bars = [['POWER', 0.86], ['O2', 0.97], ['GRAVITY', 1.0], ['HULL', 0.74], ['COMMS', 0.31]];
    bars.forEach(([label, v], i) => {
      const y = 110 + i * 70;
      text(cv, label, 620, y, 3, BLUE);
      cv.rect(620, y + 30, 980, y + 44, [16, 34, 60], 1);
      cv.rect(620, y + 30, 620 + 360 * v, y + 44, v < 0.5 ? [230, 120, 60] : CYAN, 1);
      text(cv, Math.round(v * 100) + '%', 990 - 24 * 4, y, 3, CYAN);
    });
    cv.tv();
    return cv.img;
  },
  // a small console screen on a translucent (additive) surface: light, so it reads as lit glass
  consoleGlow(w, h) {
    const cv = canvas(w, h, () => [120, 175, 200]);
    for (let y = 8; y < h - 6; y += 7) cv.rect(6, y, 6 + 14 + ((y * 37) % 34), y + 3, [40, 70, 110], 1);
    cv.rect(0, 0, w, 3, [170, 220, 240], 1);
    return cv.img;
  },
  // medical bay: heart and oxygen traces with readouts
  heartMonitor(w, h) {
    const cv = canvas(w, h, (x, y) => (x % 32 === 0 || y % 32 === 0 ? [10, 46, 30] : [4, 20, 12]));
    const trace = (y0, amp, col, beat) => {
      let px = 0, py = y0;
      for (let x = 0; x < w; x++) {
        const t = (x % 128) / 128;
        const y = y0 - amp * beat(t);
        cv.line(px, py, x, y, col, 3); px = x; py = y;
      }
    };
    trace(h * 0.36, 90, [80, 255, 120], (t) => (t > 0.30 && t < 0.33 ? -0.25 : t >= 0.33 && t < 0.36 ? 1 : t >= 0.36 && t < 0.39 ? -0.45 : t > 0.55 && t < 0.68 ? 0.18 * Math.sin((t - 0.55) / 0.13 * Math.PI) : 0));
    trace(h * 0.66, 34, [90, 170, 255], (t) => Math.max(0, Math.sin(t * Math.PI * 2)) ** 1.6);
    text(cv, 'HR 72', 24, 24, 5, [80, 255, 120]);
    text(cv, 'SPO2 98', 24, h - 64, 5, [90, 170, 255]);
    cv.tv();
    return cv.img;
  },
  // security office: four camera feeds of empty corridors
  cameraFeeds(w, h) {
    const cv = canvas(w, h, () => [18, 20, 22]);
    const fw = w / 2, fh = h / 2;
    [[0, 0], [1, 0], [0, 1], [1, 1]].forEach(([i, j], k) => {
      const x0 = i * fw + 6, y0 = j * fh + 6, x1 = (i + 1) * fw - 6, y1 = (j + 1) * fh - 6;
      const vx = (x0 + x1) / 2 + (k - 1.5) * 30, vy = (y0 + y1) / 2 - 10;
      cv.rect(x0, y0, x1, y1, [40, 46, 44], 1);
      for (let y = y0; y < y1; y++) for (let x = x0; x < x1; x++) {     // corridor: darker towards the far end
        const d = Math.max(Math.abs(x - vx) / (x1 - x0), Math.abs(y - vy) / (y1 - y0));
        const g = 25 + 70 * d + 18 * (rnd() - 0.5);
        cv.px(x, y, [g, g + 6, g + 2]);
      }
      [[x0, y0], [x1, y0], [x0, y1], [x1, y1]].forEach(([cx, cy]) => cv.line(cx, cy, vx, vy, [120, 130, 125], 2));
      cv.rect(vx - 30, vy - 20, vx + 30, vy + 20, [12, 14, 13], 1);
      text(cv, 'CAM ' + (k + 1), x0 + 12, y0 + 12, 3, [220, 230, 220]);
      cv.rect(x1 - 70, y0 + 14, x1 - 58, y0 + 26, [230, 40, 40], 1);
      text(cv, 'REC', x1 - 52, y0 + 12, 3, [230, 230, 230]);
    });
    cv.tv();
    return cv.img;
  },
};

// ---- 24-bit BMP, bottom-up rows padded to 4 bytes; ucc palettizes on import

function bmp(w, h, rgb) {
  const row = (w * 3 + 3) & ~3, b = Buffer.alloc(54 + row * h);
  b.write('BM'); b.writeUInt32LE(b.length, 2); b.writeUInt32LE(54, 10);
  b.writeUInt32LE(40, 14); b.writeInt32LE(w, 18); b.writeInt32LE(h, 22);
  b.writeUInt16LE(1, 26); b.writeUInt16LE(24, 28); b.writeUInt32LE(row * h, 34);
  for (let y = 0; y < h; y++) for (let x = 0; x < w; x++) {
    const s = (y * w + x) * 3, d = 54 + (h - 1 - y) * row + x * 3;
    b[d] = rgb[s + 2]; b[d + 1] = rgb[s + 1]; b[d + 2] = rgb[s];
  }
  return b;
}

// a photo cut to a square, scaled down (box filter) and shown as a TV picture
function fromPhoto(dir, t) {
  const src = readPng(path.join(dir, t.photo));
  if (!src) throw new Error(`${t.photo}: unreadable`);
  const [ox, oy, size] = t.crop;
  const cv = canvas(t.w, t.h, (x, y) => {
    const s = size / t.w, acc = [0, 0, 0];
    let n = 0;
    for (let yy = Math.floor(y * s); yy < Math.floor((y + 1) * s); yy++) for (let xx = Math.floor(x * s); xx < Math.floor((x + 1) * s); xx++) {
      const i = ((oy + yy) * src.w + ox + xx) * 3; acc[0] += src.rgb[i]; acc[1] += src.rgb[i + 1]; acc[2] += src.rgb[i + 2]; n++;
    }
    const g = (acc[0] + acc[1] + acc[2]) / (3 * n);
    return [g * 0.92, g * 0.97, g * 1.05];    // black and white with a cold cast, as on an old TV
  });
  cv.tv();
  return Buffer.from(cv.img.map((v) => Math.max(0, Math.min(255, v))));
}

function main() {
  const [dir, photos] = process.argv.slice(2);
  if (!dir || !photos) { console.error(fs.readFileSync(__filename, 'utf8').split('*/')[0]); process.exit(1); }
  fs.mkdirSync(OUT, { recursive: true });
  for (const [name, t] of Object.entries(TEXTURES)) {
    let rgb;
    if (t.draw) rgb = Buffer.from((SCREENS[t.draw] || DRAW[t.draw])(t.w, t.h).map((v) => Math.max(0, Math.min(255, v))));
    else if (t.photo) rgb = fromPhoto(photos, t);
    else rgb = fromZortch(dir, t);
    fs.writeFileSync(path.join(OUT, name + '.bmp'), bmp(t.w, t.h, rgb));
    console.log(`${name} ${t.w}x${t.h} <- ${t.draw ? 'drawn' : t.photo || t.zortch}`);
  }
}

if (require.main === module) main();
