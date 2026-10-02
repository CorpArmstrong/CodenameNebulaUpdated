#!/usr/bin/env node
/*
 * map_probe.js - ask a map's .t3d export where the player can actually go.
 *
 * The .dx map is binary BSP, so "is this spot solid?", "how tall is that
 * gap?" and "can you walk from here to there?" have no answer in git. They
 * used to be answered by walking into things in-game and guessing, which
 * produced at least one confidently wrong diagnosis: L2's "invisible wall"
 * was blamed on a rotated pipe brush by a bounding-box query that ignored
 * brush rotation. It is really a 32.000-unit-tall slot.
 *
 * A UnrealEd "File > Export > Map (t3d)" carries every brush with its
 * polygons, transform and CSG operation, which is enough to re-run the CSG
 * offline:
 *
 *   the world starts solid; each brush in list order adds or subtracts;
 *   the LAST brush containing a point decides whether it is solid.
 *
 * Containment is a generalised winding number over the brush's triangles,
 * not a plane test, because UE1 lofted and 2D-shape brushes are not convex.
 *
 * Usage:
 *   node tools/map_probe.js <map.t3d> at    <x> <y> <z>
 *   node tools/map_probe.js <map.t3d> span  <x> <y> [zGuess]
 *   node tools/map_probe.js <map.t3d> clear <y0> <y1> [x0] [x1]
 *   node tools/map_probe.js <map.t3d> plan  <z> [x0 x1 y0 y1 step]
 *   node tools/map_probe.js <map.t3d> slice <x> [y0 y1 z0 z1 step]
 *   node tools/map_probe.js <map.t3d> reach <x> <y> <z> [tx ty tz]
 *   node tools/map_probe.js <map.t3d> membranes [maxT x0 x1 y0 y1 z,z,z]
 *
 *   at        - solid or open, and which brush decided it
 *   span      - exact floor and ceiling around a point, by binary search
 *   clear     - tallest vertical opening on each Y plane in a range; this is
 *               what finds a bottleneck between two areas
 *   plan      - top-down solid/open map at one height
 *   slice     - vertical section along one X
 *   reach     - player-sized (r=20, h=95) flood fill from a spot; reports the
 *               reachable extent and whether a target is inside it
 *   membranes - thin solid slabs with open space on both sides
 *
 * Sampling step matters. "clear" and "slice" step 8 and 16 units, and a
 * 3.9-unit membrane sits between samples: that is how 06_OpheliaL2's real
 * invisible wall was missed at first. When a spot is suspect, use
 * "membranes", or "at" on a fine hand-rolled sweep.
 *
 * "reach" is deliberately conservative: it samples on a 16-unit grid with a
 * 48x48 column, so doorways narrower than that read as blocked and ramps
 * are approximated. Treat a NEGATIVE reach result as a hint and confirm it
 * with "clear"; treat a POSITIVE result as reliable. Movers - doors, lifts -
 * are not modelled at all, being actors rather than BSP.
 */

const fs = require('fs');

// ---------------------------------------------------------------- parsing

function parseVec(s) {
    const m = {};
    for (const p of s.matchAll(/([A-Za-z]+)=(-?[\d.eE+]+)/g)) m[p[1]] = parseFloat(p[2]);
    return m;
}

// UE1 rotator (65536 = one turn) to the three body axes.
function rotAxes(pitch, yaw, roll) {
    const k = Math.PI * 2 / 65536;
    const P = pitch * k, Y = yaw * k, R = roll * k;
    const SP = Math.sin(P), CP = Math.cos(P);
    const SY = Math.sin(Y), CY = Math.cos(Y);
    const SR = Math.sin(R), CR = Math.cos(R);
    return {
        X: [CP * CY, CP * SY, SP],
        Y: [SR * SP * CY - CR * SY, SR * SP * SY + CR * CY, -SR * CP],
        Z: [-(CR * SP * CY + SR * SY), CY * SR - CR * SP * SY, CR * CP],
    };
}

function parseBrushes(file) {
    const lines = fs.readFileSync(file, 'utf8').split(/\r?\n/);
    const brushes = [];
    let b = null, poly = null;

    for (const line of lines) {
        const t = line.trim();
        let m;
        if ((m = t.match(/^Begin Actor Class=Brush Name=(\S+)/))) {
            b = { name: m[1], csg: 'CSG_Active', loc: [0, 0, 0], rot: [0, 0, 0],
                  prePivot: [0, 0, 0], mainScale: [1, 1, 1], postScale: [1, 1, 1],
                  polys: [] };
            continue;
        }
        if (!b) continue;
        if (t === 'End Actor') { brushes.push(b); b = null; continue; }

        if ((m = t.match(/^CsgOper=(\S+)/))) b.csg = m[1];
        else if ((m = t.match(/^Location=\((.*)\)/))) {
            const v = parseVec(m[1]);
            b.loc = [v.X || 0, v.Y || 0, v.Z || 0];
        } else if ((m = t.match(/^PrePivot=\((.*)\)/))) {
            const v = parseVec(m[1]);
            b.prePivot = [v.X || 0, v.Y || 0, v.Z || 0];
        } else if ((m = t.match(/^Rotation=\((.*)\)/))) {
            const v = parseVec(m[1]);
            b.rot = [v.Pitch || 0, v.Yaw || 0, v.Roll || 0];
        } else if ((m = t.match(/^MainScale=\((.*)\)/))) {
            const v = parseVec(m[1]);
            b.mainScale = [v.X === undefined ? 1 : v.X, v.Y === undefined ? 1 : v.Y,
                           v.Z === undefined ? 1 : v.Z];
        } else if ((m = t.match(/^PostScale=\((.*)\)/))) {
            const v = parseVec(m[1]);
            b.postScale = [v.X === undefined ? 1 : v.X, v.Y === undefined ? 1 : v.Y,
                           v.Z === undefined ? 1 : v.Z];
        } else if (t.startsWith('Begin Polygon')) {
            poly = { verts: [], normal: null };
            b.polys.push(poly);
        } else if (t === 'End Polygon') poly = null;
        else if (poly && (m = t.match(/^Vertex\s+(\S+),(\S+),(\S+)/)))
            poly.verts.push([parseFloat(m[1]), parseFloat(m[2]), parseFloat(m[3])]);
        else if (poly && (m = t.match(/^Normal\s+(\S+),(\S+),(\S+)/)))
            poly.normal = [parseFloat(m[1]), parseFloat(m[2]), parseFloat(m[3])];
    }
    return brushes;
}

// --------------------------------------------------------------- geometry

const sub = (a, b) => [a[0] - b[0], a[1] - b[1], a[2] - b[2]];
const dot = (a, b) => a[0] * b[0] + a[1] * b[1] + a[2] * b[2];
const cross = (a, b) => [a[1] * b[2] - a[2] * b[1],
                         a[2] * b[0] - a[0] * b[2],
                         a[0] * b[1] - a[1] * b[0]];
const len = a => Math.hypot(a[0], a[1], a[2]);

function build(file) {
    const out = [];
    for (const b of parseBrushes(file)) {
        if (b.csg !== 'CSG_Add' && b.csg !== 'CSG_Subtract') continue;  // builder brush

        // UE1 FPoly::Transform is  world = Location + Xform(vertex - PrePivot).
        // Skipping PrePivot silently misplaces every brush that has one - 981
        // of them in 06_OpheliaL2 - and that produced a wrong answer once
        // already, so it is not optional.
        const ax = rotAxes(b.rot[0], b.rot[1], b.rot[2]);
        const toWorld = v0 => {
            const v = [v0[0] - b.prePivot[0], v0[1] - b.prePivot[1], v0[2] - b.prePivot[2]];
            const s = [v[0] * b.mainScale[0], v[1] * b.mainScale[1], v[2] * b.mainScale[2]];
            return [
                (s[0] * ax.X[0] + s[1] * ax.Y[0] + s[2] * ax.Z[0]) * b.postScale[0] + b.loc[0],
                (s[0] * ax.X[1] + s[1] * ax.Y[1] + s[2] * ax.Z[1]) * b.postScale[1] + b.loc[1],
                (s[0] * ax.X[2] + s[1] * ax.Y[2] + s[2] * ax.Z[2]) * b.postScale[2] + b.loc[2],
            ];
        };
        const rotOnly = v => [
            v[0] * ax.X[0] + v[1] * ax.Y[0] + v[2] * ax.Z[0],
            v[0] * ax.X[1] + v[1] * ax.Y[1] + v[2] * ax.Z[1],
            v[0] * ax.X[2] + v[1] * ax.Y[2] + v[2] * ax.Z[2],
        ];

        const tris = [];
        let bb = null;
        for (const p of b.polys) {
            const w = p.verts.map(toWorld);
            if (w.length < 3) continue;
            const wn = p.normal ? rotOnly(p.normal) : null;
            const flip = wn && dot(cross(sub(w[1], w[0]), sub(w[2], w[0])), wn) < 0;
            for (let i = 1; i + 1 < w.length; i++)
                tris.push(flip ? [w[0], w[i + 1], w[i]] : [w[0], w[i], w[i + 1]]);
            for (const v of w) {
                if (!bb) bb = { min: v.slice(), max: v.slice() };
                for (let i = 0; i < 3; i++) {
                    if (v[i] < bb.min[i]) bb.min[i] = v[i];
                    if (v[i] > bb.max[i]) bb.max[i] = v[i];
                }
            }
        }
        // Fewer than four triangles cannot enclose a volume: sheets, zone
        // portals and special-lit polys land here and must not get a vote.
        if (tris.length < 4 || !bb) continue;
        out.push({ name: b.name, csg: b.csg, tris: tris, bbox: bb });
    }
    return out;
}

function inBBox(b, p) {
    for (let i = 0; i < 3; i++)
        if (p[i] < b.bbox.min[i] - 0.5 || p[i] > b.bbox.max[i] + 0.5) return false;
    return true;
}

// Generalised winding number: sum the signed solid angle of every triangle
// as seen from p. Half a turn or more means p is enclosed.
function contains(b, p) {
    let sum = 0;
    for (const t of b.tris) {
        const a = sub(t[0], p), c = sub(t[1], p), d = sub(t[2], p);
        const la = len(a), lc = len(c), ld = len(d);
        if (la < 1e-9 || lc < 1e-9 || ld < 1e-9) return true;   // on a vertex
        sum += 2 * Math.atan2(
            dot(a, cross(c, d)),
            la * lc * ld + dot(a, c) * ld + dot(c, d) * la + dot(d, a) * lc);
    }
    return Math.abs(sum) > Math.PI * 2;
}

// Coarse grid over brush bounding boxes. Without it every query walks all
// ~1200 brushes and the flood fill takes minutes.
function index(bs) {
    const CELL = 256, map = new Map();
    const key = (i, j, k) => i + ',' + j + ',' + k;
    bs.forEach((b, n) => {
        const lo = b.bbox.min.map(v => Math.floor(v / CELL));
        const hi = b.bbox.max.map(v => Math.floor(v / CELL));
        for (let i = lo[0]; i <= hi[0]; i++)
            for (let j = lo[1]; j <= hi[1]; j++)
                for (let k = lo[2]; k <= hi[2]; k++) {
                    const s = key(i, j, k);
                    if (!map.has(s)) map.set(s, []);
                    map.get(s).push(n);
                }
    });
    return p => {
        const l = map.get(key(Math.floor(p[0] / CELL), Math.floor(p[1] / CELL),
                              Math.floor(p[2] / CELL)));
        if (!l) return null;
        let last = -1;
        for (const n of l)
            if (n > last && inBBox(bs[n], p) && contains(bs[n], p)) last = n;
        return last < 0 ? null : bs[last];
    };
}

// ---------------------------------------------------------------- queries

// Walk out in small steps to bracket the first surface, then bisect inside
// that bracket. Bisecting the whole column instead would converge on some
// other floor two decks up: solidity along Z is not monotonic.
function span(isSolid, x, y, zGuess) {
    if (isSolid([x, y, zGuess])) return null;

    function surface(dir) {
        const STEP = 2, LIMIT = 2048;
        let prev = zGuess;
        for (let d = STEP; d <= LIMIT; d += STEP) {
            const z = zGuess + dir * d;
            if (isSolid([x, y, z])) {
                let open = prev, solid = z;
                for (let i = 0; i < 30; i++) {
                    const m = (open + solid) / 2;
                    if (isSolid([x, y, m])) solid = m; else open = m;
                }
                return open;
            }
            prev = z;
        }
        return zGuess + dir * LIMIT;      // open all the way out
    }

    return [surface(-1), surface(1)];
}

// Thin solid slabs with open space on BOTH sides. UE1 often drops the
// renderable surfaces of a sliver that thin while the collision hull keeps
// it, which is exactly what an "invisible wall" is. Most hits are legitimate
// thin walls, panels and door frames - this narrows where to look, it does
// not decide anything on its own.
function membranes(isSolid, maxT, box, zs) {
    const raw = [];
    for (const z of zs)
        for (let x = box[0]; x <= box[1]; x += 16) {
            let run = null, seenOpen = false;
            for (let y = box[2]; y <= box[3]; y += 1) {
                const s = isSolid([x, y, z]);
                if (s && run === null) run = { a: y, after: seenOpen };
                else if (!s && run !== null) {
                    if (run.after && y - run.a <= maxT)
                        raw.push({ x: x, z: z, y: run.a, t: y - run.a });
                    run = null;
                }
                if (!s) seenOpen = true;
            }
        }
    const out = [];
    for (const h of raw) {
        const c = out.find(c => c.z === h.z && Math.abs(c.y - h.y) < 24 &&
                                h.x >= c.x0 - 48 && h.x <= c.x1 + 48);
        if (c) {
            c.x0 = Math.min(c.x0, h.x); c.x1 = Math.max(c.x1, h.x);
            c.tmin = Math.min(c.tmin, h.t); c.tmax = Math.max(c.tmax, h.t);
        } else out.push({ z: h.z, y: h.y, x0: h.x, x1: h.x, tmin: h.t, tmax: h.t });
    }
    return out.sort((a, b) => (b.x1 - b.x0) - (a.x1 - a.x0));
}

function reach(solidBrush, seed, target) {
    const S = 16, PAD = 1200;
    const X0 = seed[0] - PAD, Y0 = seed[1] - PAD, Z0 = seed[2] - 400;
    const NX = Math.floor(PAD * 2 / S) + 1, NY = NX, NZ = Math.floor(800 / S) + 1;
    const at = (i, j, k) => (i * NY + j) * NZ + k;

    const free = new Uint8Array(NX * NY * NZ);
    for (let i = 0; i < NX; i++)
        for (let j = 0; j < NY; j++)
            for (let k = 0; k < NZ; k++) {
                const b = solidBrush([X0 + i * S, Y0 + j * S, Z0 + k * S]);
                free[at(i, j, k)] = (b && b.csg === 'CSG_Subtract') ? 1 : 0;
            }

    // r=20 -> a 3x3 column of 16-unit cells; h=95 -> 6 cells upward.
    const fits = (i, j, k) => {
        for (let dk = 0; dk < 6; dk++) {
            const kk = k + dk;
            if (kk >= NZ) return false;
            for (let di = -1; di <= 1; di++)
                for (let dj = -1; dj <= 1; dj++) {
                    const ii = i + di, jj = j + dj;
                    if (ii < 0 || ii >= NX || jj < 0 || jj >= NY) return false;
                    if (!free[at(ii, jj, kk)]) return false;
                }
        }
        return true;
    };

    const g = p => [Math.round((p[0] - X0) / S), Math.round((p[1] - Y0) / S),
                    Math.round((p[2] - Z0) / S)];
    const s = g(seed);
    if (!fits(s[0], s[1], s[2]))
        return { note: 'the seed itself is not player-sized open space' };

    const seen = new Uint8Array(NX * NY * NZ);
    const q = [s];
    seen[at(s[0], s[1], s[2])] = 1;
    let n = 0, mn = [1e9, 1e9, 1e9], mx = [-1e9, -1e9, -1e9], onEdge = 0;
    while (q.length) {
        const cell = q.pop();
        const i = cell[0], j = cell[1], k = cell[2];
        n++;
        const p = [X0 + i * S, Y0 + j * S, Z0 + k * S];
        for (let t = 0; t < 3; t++) {
            if (p[t] < mn[t]) mn[t] = p[t];
            if (p[t] > mx[t]) mx[t] = p[t];
        }
        if (i <= 1 || i >= NX - 2 || j <= 1 || j >= NY - 2 || k <= 1 || k >= NZ - 2)
            onEdge++;
        const nb = [[1,0,0], [-1,0,0], [0,1,0], [0,-1,0], [0,0,1], [0,0,-1]];
        for (let d = 0; d < nb.length; d++) {
            const ii = i + nb[d][0], jj = j + nb[d][1], kk = k + nb[d][2];
            if (ii < 0 || ii >= NX || jj < 0 || jj >= NY || kk < 0 || kk >= NZ) continue;
            if (seen[at(ii, jj, kk)] || !fits(ii, jj, kk)) continue;
            seen[at(ii, jj, kk)] = 1;
            q.push([ii, jj, kk]);
        }
    }

    let hit = null;
    if (target) {
        const t = g(target);
        hit = (t[0] >= 0 && t[0] < NX && t[1] >= 0 && t[1] < NY && t[2] >= 0 && t[2] < NZ)
              ? !!seen[at(t[0], t[1], t[2])] : false;
    }
    return { n: n, min: mn, max: mx, onEdge: onEdge, target: hit };
}

// -------------------------------------------------------------------- CLI

// Also usable as a module, so one-off comparisons between maps do not have to
// re-implement the transform: require('./map_probe.js').build(file).
module.exports = { parseBrushes: parseBrushes, build: build, index: index,
                   span: span, reach: reach, contains: contains };
if (require.main !== module) return;

const argv = process.argv.slice(2);
const file = argv[0];
const cmd = (argv[1] || '').toLowerCase();
const num = i => parseFloat(argv[i]);

if (!file || !cmd) {
    console.error('usage: node tools/map_probe.js <map.t3d> ' +
                  '<at|span|clear|plan|slice|reach> ...   (see file header)');
    process.exit(2);
}

const bs = build(file);
const solidBrush = index(bs);
const isSolid = p => {
    const b = solidBrush(p);
    return !b || b.csg === 'CSG_Add';
};

if (cmd === 'at') {
    const p = [num(2), num(3), num(4)];
    const b = solidBrush(p);
    console.log('(' + p.join(', ') + ') ' + (isSolid(p) ? 'SOLID' : 'open ') + '  <- ' +
                (b ? b.name + ' ' + b.csg.replace('CSG_', '')
                   : 'world (never subtracted)'));

} else if (cmd === 'span') {
    const x = num(2), y = num(3);
    const z = argv[4] === undefined ? 0 : num(4);
    const s = span(isSolid, x, y, z);
    if (!s) console.log('(' + x + ', ' + y + ', ' + z + ') is solid');
    else console.log('X=' + x + ' Y=' + y +
                     '   floor ' + s[0].toFixed(3) +
                     '   ceiling ' + s[1].toFixed(3) +
                     '   clearance ' + (s[1] - s[0]).toFixed(3));

} else if (cmd === 'clear') {
    const y0 = num(2), y1 = num(3);
    const x0 = argv[4] === undefined ? -4096 : num(4);
    const x1 = argv[5] === undefined ? 4096 : num(5);
    console.log('Tallest vertical opening on each Y plane, X ' + x0 + '..' + x1);
    for (let y = y0; y <= y1; y += 8) {
        let best = 0, bx = 0, bz = 0;
        for (let x = x0; x <= x1; x += 8) {
            let run = 0, start = 0;
            for (let z = -512; z <= 512; z += 2) {
                if (!isSolid([x, y, z])) {
                    if (run === 0) start = z;
                    run += 2;
                } else {
                    if (run > best) { best = run; bx = x; bz = start; }
                    run = 0;
                }
            }
            if (run > best) { best = run; bx = x; bz = start; }
        }
        console.log('Y=' + String(y).padStart(7) + '  ' + String(best).padStart(5) +
                    ' units  at X=' + String(bx).padStart(6) +
                    ' Z=' + String(bz).padStart(6));
    }

} else if (cmd === 'plan' || cmd === 'slice') {
    const fixed = num(2);
    const isPlan = (cmd === 'plan');
    const a0 = argv[3] === undefined ? (isPlan ? -2048 : -8192) : num(3);
    const a1 = argv[4] === undefined ? (isPlan ? 2048 : 2048) : num(4);
    const b0 = argv[5] === undefined ? (isPlan ? -8192 : -256) : num(5);
    const b1 = argv[6] === undefined ? (isPlan ? 2048 : 256) : num(6);
    const step = argv[7] === undefined ? 32 : num(7);
    console.log(isPlan
        ? 'Plan at Z=' + fixed + ': X ' + a0 + '..' + a1 + ' across, Y ' + b0 + '..' + b1 + ' down'
        : 'Section at X=' + fixed + ': Y ' + a0 + '..' + a1 + ' across, Z ' + b1 + '..' + b0 + ' down');
    if (isPlan) {
        for (let y = b0; y <= b1; y += step) {
            let line = String(y).padStart(7) + ' ';
            for (let x = a0; x <= a1; x += step) line += isSolid([x, y, fixed]) ? '#' : '.';
            console.log(line);
        }
    } else {
        for (let z = b1; z >= b0; z -= step) {
            let line = String(z).padStart(7) + ' ';
            for (let y = a0; y <= a1; y += step) line += isSolid([fixed, y, z]) ? '#' : '.';
            console.log(line);
        }
    }

} else if (cmd === 'membranes') {
    const maxT = argv[2] === undefined ? 8 : num(2);
    const box = [argv[3] === undefined ? -2048 : num(3), argv[4] === undefined ? 2400 : num(4),
                 argv[5] === undefined ? -7200 : num(5), argv[6] === undefined ? -1200 : num(6)];
    const zs = argv[7] === undefined ? [0, 15, 60] : argv[7].split(',').map(Number);
    const found = membranes(isSolid, maxT, box, zs);
    console.log('Solid slabs at most ' + maxT + ' units thick with open space on both ' +
                'sides,\nscanned along Y at Z = ' + zs.join(', ') +
                ', X ' + box[0] + '..' + box[1] + ' step 16');
    if (!found.length) console.log('   none');
    for (const c of found.slice(0, 25))
        console.log('   Y=' + String(c.y).padStart(7) + '  Z=' + String(c.z).padStart(5) +
                    '   X ' + String(c.x0).padStart(6) + '..' + String(c.x1).padEnd(6) +
                    '   thickness ' + c.tmin + (c.tmax !== c.tmin ? '..' + c.tmax : ''));

} else if (cmd === 'reach') {
    const seed = [num(2), num(3), num(4)];
    const target = argv[5] === undefined ? null : [num(5), num(6), num(7)];
    const r = reach(solidBrush, seed, target);
    if (r.note) {
        console.log(r.note);
    } else {
        console.log('player-sized space reachable from (' + seed.join(', ') + '): ' +
                    r.n + ' cells');
        console.log('  extent  X ' + r.min[0] + '..' + r.max[0] +
                    '   Y ' + r.min[1] + '..' + r.max[1] +
                    '   Z ' + r.min[2] + '..' + r.max[2]);
        console.log(r.onEdge
            ? '  ' + r.onEdge + ' cells reached the edge of the sampled box - it goes further'
            : '  fully contained in the sampled box: this is the whole component');
        if (target !== null)
            console.log('  target (' + target.join(', ') + '): ' +
                        (r.target ? 'REACHABLE' : 'not reachable'));
    }

} else {
    console.error('unknown command: ' + cmd);
    process.exit(2);
}
