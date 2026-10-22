#!/usr/bin/env node
/*
 * synth_sounds.js - generates two sounds that replaced third-party audio
 * (CNNDocs/Assets_License_Audit.md, 2026-10-22). Everything here is
 * synthesized from scratch, no samples, so the files are the team's own.
 *
 *   CNN/Sounds/XFilesTheme.wav    L1 rec room button ("Xfiles" event): an
 *                                 original eerie tune -- echoing pluck
 *                                 ostinato, pad, whistle lead. ~29 s, mono.
 *   CNN/Sounds/ChesterScream.wav  Moon random sounds: a distant distorted
 *                                 howl. 4 s, stereo.
 *
 * The names stay so the maps need no change. Deterministic (seeded noise).
 * Usage: node tools/synth_sounds.js [outDir=CNN/Sounds]
 */
'use strict';
const fs = require('fs');
const path = require('path');

const SR = 44100;
const outDir = process.argv[2] || path.join(__dirname, '..', 'CNN', 'Sounds');

// ---- helpers -------------------------------------------------------------
let seed = 12345;
const rnd = () => ((seed = (seed * 1103515245 + 12345) >>> 0) / 4294967296) * 2 - 1;
const midi = (n) => 440 * Math.pow(2, (n - 69) / 12);
const NOTE = { C: 0, D: 2, E: 4, F: 5, G: 7, A: 9, B: 11 };
const note = (s) => 12 * (parseInt(s.slice(-1), 10) + 1) + NOTE[s[0]] + (s[1] === '#' ? 1 : 0);

function writeWav(file, channels) {
  const n = channels[0].length, ch = channels.length;
  let peak = 0;
  for (const c of channels) for (const v of c) peak = Math.max(peak, Math.abs(v));
  const g = peak > 0 ? 0.89 / peak : 1;           // about -1 dBFS
  const buf = Buffer.alloc(44 + n * ch * 2);
  buf.write('RIFF', 0); buf.writeUInt32LE(36 + n * ch * 2, 4); buf.write('WAVE', 8);
  buf.write('fmt ', 12); buf.writeUInt32LE(16, 16); buf.writeUInt16LE(1, 20); buf.writeUInt16LE(ch, 22);
  buf.writeUInt32LE(SR, 24); buf.writeUInt32LE(SR * ch * 2, 28); buf.writeUInt16LE(ch * 2, 32); buf.writeUInt16LE(16, 34);
  buf.write('data', 36); buf.writeUInt32LE(n * ch * 2, 40);
  for (let i = 0; i < n; i++)
    for (let c = 0; c < ch; c++)
      buf.writeInt16LE(Math.round(Math.max(-1, Math.min(1, channels[c][i] * g)) * 32767), 44 + (i * ch + c) * 2);
  fs.writeFileSync(file, buf);
  console.log(`${file}: ${(n / SR).toFixed(1)} s, ${ch} ch, ${buf.length} bytes`);
}

// Schroeder reverb: parallel combs, then allpasses
function reverb(x, { room = 0.84, damp = 0.3, wet = 0.35, spread = 0 } = {}) {
  const combs = [1557, 1617, 1491, 1422, 1277, 1356].map((d) => d + spread);
  const aps = [225, 556, 441].map((d) => d + spread);
  const y = new Float64Array(x.length);
  for (const d of combs) {
    const buf = new Float64Array(d); let i = 0, lp = 0;
    for (let n = 0; n < x.length; n++) {
      const out = buf[i];
      lp = out * (1 - damp) + lp * damp;
      buf[i] = x[n] + lp * room;
      i = (i + 1) % d;
      y[n] += out / combs.length;
    }
  }
  for (const d of aps) {
    const buf = new Float64Array(d); let i = 0;
    for (let n = 0; n < y.length; n++) {
      const b = buf[i], v = y[n];
      buf[i] = v + b * 0.5;
      y[n] = b - v * 0.5;
      i = (i + 1) % d;
    }
  }
  return x.map((v, n) => v * (1 - wet) + y[n] * wet);
}

// RBJ band-pass (constant peak gain)
function bandpass(x, f, q) {
  const w = 2 * Math.PI * f / SR, a = Math.sin(w) / (2 * q), c = Math.cos(w);
  const b0 = a / (1 + a), b2 = -a / (1 + a), a1 = -2 * c / (1 + a), a2 = (1 - a) / (1 + a);
  const y = new Float64Array(x.length); let x1 = 0, x2 = 0, y1 = 0, y2 = 0;
  for (let n = 0; n < x.length; n++) {
    const v = b0 * x[n] + b2 * x2 - a1 * y1 - a2 * y2;
    x2 = x1; x1 = x[n]; y2 = y1; y1 = v; y[n] = v;
  }
  return y;
}

function lowpass1(x, f) {
  const k = 1 - Math.exp(-2 * Math.PI * f / SR); let s = 0;
  return x.map((v) => (s += (v - s) * k));
}

// ---- XFilesTheme: original eerie tune ----------------------------------------
function tune() {
  const len = 29 * SR, mix = new Float64Array(len);
  const add = (buf, at, gain) => { for (let i = 0; i < buf.length && at + i < len; i++) mix[at + i] += buf[i] * gain; };

  // plucked ostinato (Karplus-Strong) with a ping-pong-ish echo
  const pluck = (f, dur) => {
    const p = Math.round(SR / f), ring = new Float64Array(p), out = new Float64Array(Math.round(dur * SR));
    for (let i = 0; i < p; i++) ring[i] = rnd();
    let i = 0, prev = 0;
    for (let n = 0; n < out.length; n++) {
      const v = ring[i]; const nv = 0.996 * 0.5 * (v + prev); prev = v; ring[i] = nv; i = (i + 1) % p;
      out[n] = v * Math.min(1, n / 40);
    }
    return lowpass1(out, 2600);
  };
  const ost = ['A3', 'E4', 'C5', 'E4', 'B4', 'E4', 'C5', 'G4'];
  const step = 0.32;
  const echo = new Float64Array(len);
  for (let t = 0, k = 0; t < 26; t += step, k++) {
    const nn = note(ost[k % ost.length]) + ((Math.floor(k / 16) % 4) === 2 ? -4 : 0);   // F-chord colour every 4th bar
    const b = pluck(midi(nn), 1.6), at = Math.round(t * SR);
    for (let i = 0; i < b.length && at + i < len; i++) echo[at + i] += b[i] * 0.35 * (t < 1 ? t : 1);
  }
  const d = Math.round(0.48 * SR);
  for (let n = d; n < len; n++) echo[n] += echo[n - d] * 0.42;
  add(echo, 0, 1);

  // pad: Am - F - Dm - E, slow swell, detuned triangles
  const chords = [['A2', 'E3', 'C4', 'E4'], ['F2', 'C3', 'A3', 'C4'], ['D2', 'A2', 'F3', 'A3'], ['E2', 'B2', 'G#3', 'B3']];
  for (let bar = 0; bar < 7; bar++) {
    const t0 = 2 + bar * 3.84, dur = 4.4, chord = chords[bar % 4], n = Math.round(dur * SR), buf = new Float64Array(n);
    for (const s of chord) for (const det of [-0.08, 0.08]) {
      const f = midi(note(s) + det); let ph = (rnd() + 1) / 2;
      for (let i = 0; i < n; i++) { ph += f / SR; ph -= Math.floor(ph); buf[i] += (4 * Math.abs(ph - 0.5) - 1) * 0.06; }
    }
    for (let i = 0; i < n; i++) buf[i] *= Math.sin(Math.PI * i / n) ** 1.5;
    add(lowpass1(buf, 1200), Math.round(t0 * SR), 1);
  }

  // whistle lead: sine with vibrato and glides; an original melody
  const mel = [['C5', 1], ['E5', 1], ['B4', 1.5], ['A4', 0.5], ['C5', 2], ['E5', 2],
               ['F5', 1.5], ['E5', 0.5], ['D5', 1], ['A4', 1], ['B4', 2], ['E5', 2],
               ['A5', 1], ['G5', 1], ['E5', 2], ['F5', 1], ['D5', 1], ['E5', 3]];
  let t = 5.5, ph = 0, f = midi(note(mel[0][0]));
  const lead = new Float64Array(len);
  for (const [s, dur] of mel) {
    const target = midi(note(s)), n0 = Math.round(t * SR), n = Math.round(dur * SR);
    for (let i = 0; i < n && n0 + i < len; i++) {
      f += (target - f) * 0.0012;                                     // glide
      const vib = 1 + 0.012 * Math.sin(2 * Math.PI * 5.3 * (n0 + i) / SR) * Math.min(1, i / (0.4 * SR));
      ph += f * vib / SR;
      const env = Math.min(1, i / 2200) * Math.min(1, (n - i) / 1800);
      lead[n0 + i] += (Math.sin(2 * Math.PI * ph) + 0.08 * rnd() * 0.3) * env * 0.32;
    }
    t += dur;
  }
  add(lead, 0, 1);

  // low drone and an overall fade in/out
  for (let n = 0; n < len; n++) {
    mix[n] += Math.sin(2 * Math.PI * midi(note('A1')) * n / SR) * 0.05 * Math.min(1, n / (3 * SR));
    mix[n] *= Math.min(1, n / (0.5 * SR)) * Math.min(1, (len - n) / (3 * SR));
  }
  return reverb(mix, { room: 0.86, wet: 0.4 });
}

// ---- ChesterScream: distant distorted howl -------------------------------------
function howl() {
  const len = 4 * SR, src = new Float64Array(len);
  let ph = 0;
  for (let n = 0; n < len; n++) {
    const t = n / SR;
    // rise, crack, long fall
    const f = t < 0.7 ? 230 + 330 * (t / 0.7) ** 0.7 : 560 * Math.exp(-(t - 0.7) * 0.42) + 20 * Math.sin(t * 9);
    const jitter = 1 + 0.03 * Math.sin(2 * Math.PI * 6.7 * t) + 0.015 * rnd();
    ph += f * jitter / SR; ph -= Math.floor(ph);
    const saw = 2 * ph - 1;
    const env = Math.min(1, t / 0.12) * Math.min(1, (3.2 - t) / 1.4 > 0 ? (3.2 - t) / 1.4 : 0);
    src[n] = (saw + 0.35 * rnd()) * env;
  }
  // vowel "ah" -> "oh" formants, then a little grit
  let v = new Float64Array(len);
  for (const [fq, q, g] of [[780, 6, 1], [1150, 8, 0.6], [2700, 10, 0.25]]) {
    const b = bandpass(src, fq, q);
    for (let n = 0; n < len; n++) v[n] += b[n] * g;
  }
  v = v.map((x) => Math.tanh(x * 3.5));
  v = lowpass1(v, 3800);
  // distance: band-limit and wet stereo reverb
  return [reverb(v, { room: 0.9, wet: 0.6, spread: 0 }), reverb(v, { room: 0.9, wet: 0.6, spread: 23 })];
}

writeWav(path.join(outDir, 'XFilesTheme.wav'), [tune()]);
writeWav(path.join(outDir, 'ChesterScream.wav'), howl());
