/*
 * t3d_write.js - write brushes and actors as a .t3d that UnrealEd imports with
 * MAP IMPORTADD FILE=... (tools/cnn_edcmd.ps1 sends it). A whole map built this
 * way: tools/t3d_example_bsp.js.
 *
 * The FIRST Brush of an imported .t3d replaces the red builder brush and takes
 * no part in the CSG, so start with builder(). A map or a patch made without it
 * silently loses its first brush.
 *
 * Brushes apply in list order: subtract the rooms, then add into them.
 *   box(name, op, centre, size, tex, opts)              size = [x, y, z], full sizes
 *   prism(name, op, centre, sides, radius, height, tex, opts)  a cylinder, up to 16 sides
 *   wedge(name, op, centre, size, tex, opts)            a ramp rising towards +Y
 *   stairs(prefix, op, base, steps, tex)                columns from base.z; see below
 *   sheet(name, centre, plane, w, h, tex, flags)        one polygon: 'XY' floor, 'XZ', 'YZ' wall
 *   ladder(name, x, y, z, height, face)                 climbable, with rungs, on a wall along Y
 *   zonePortal, waterSurface, mover                     sheets and movers with the usual flags
 *
 * tex is a name or {top, bottom, side}, a box also takes {px, nx, py, ny} per wall.
 * opts.flags goes on every polygon and the brush, opts.faceFlags = {top: PF.FakeBackdrop}
 * on some. Texture packages have to be loaded first (OBJ LOAD), or the surface
 * imports untextured. A polygon is wound from the brush's centre, so faces can be
 * listed in any order: the outward normal is cross(v1-v0, v2-v0).
 *
 * PathNode and PatrolPoint go 15 units above the floor (their CollisionHeight,
 * where the editor's A key puts them). At 30 and up PATHS DEFINE builds no
 * reachspecs: 0 links, the nodes only in VisNoReachPaths. A pawn then cannot
 * path, and a Patrolling pawn with pausetime=0 dies with "Runaway loop"
 * (ScriptedPawn state Patrolling loops with no latent call).
 */

const PF = {
    Invisible: 0x1, Masked: 0x2, Translucent: 0x4, NotSolid: 0x8, Semisolid: 0x20, FakeBackdrop: 0x80,
    TwoSided: 0x100, SmallWavy: 0x2000, Unlit: 0x400000, Portal: 0x4000000,
};

const num = (n) => (n < 0 ? '-' : '+') + Math.abs(n).toFixed(6).padStart(13, '0');
const vec = (v) => v.map(num).join(',');
const sub = (a, b) => [a[0] - b[0], a[1] - b[1], a[2] - b[2]];
const cross = (a, b) => [a[1] * b[2] - a[2] * b[1], a[2] * b[0] - a[0] * b[2], a[0] * b[1] - a[1] * b[0]];
const dot = (a, b) => a[0] * b[0] + a[1] * b[1] + a[2] * b[2];
const unit = (a) => { const l = Math.hypot(a[0], a[1], a[2]); return [a[0] / l, a[1] / l, a[2] / l]; };

// Floors tile along X and Y, walls along their length with V pointing down, as the editor sets them.
function texAxes(n) {
    if (Math.abs(n[2]) > 0.7) return [[1, 0, 0], unit(cross(n, [1, 0, 0]))];
    return [unit(cross([0, 0, 1], n)), [0, 0, -1]];
}

function poly(verts, normal, tex, flags, texScale = 1) {
    const head = 'Begin Polygon' + (tex ? ' Texture=' + tex : '') + (flags ? ' Flags=' + flags : '');
    const [u, v] = texAxes(normal).map((a) => a.map((x) => x * texScale));
    return `          ${head}
             Origin   ${vec(verts[0])}
             Normal   ${vec(normal)}
             TextureU ${vec(u)}
             TextureV ${vec(v)}
${verts.map((p) => '             Vertex   ' + vec(p)).join('\n')}
          End Polygon\n`;
}

// A closed convex shape. faces = [{verts, key}], key picks the texture and flags.
function solidPolys(faces, tex, opts = {}) {
    const all = faces.flatMap((f) => f.verts);
    const mid = all.reduce((c, p) => [c[0] + p[0] / all.length, c[1] + p[1] / all.length, c[2] + p[2] / all.length], [0, 0, 0]);
    const t = (tex && typeof tex === 'object') ? tex : {top: tex, bottom: tex, side: tex};
    return faces.map((f) => {
        let verts = f.verts;
        let n = unit(cross(sub(verts[1], verts[0]), sub(verts[2], verts[0])));
        if (dot(n, sub(verts[0], mid)) < 0) { verts = verts.slice().reverse(); n = n.map((x) => -x); }
        const kind = (f.key === 'top' || f.key === 'bottom') ? f.key : 'side';
        const flags = (opts.flags || 0) | ((opts.faceFlags && (opts.faceFlags[f.key] || opts.faceFlags[kind])) || 0);
        return poly(verts, n, t[f.key] || t[kind], flags);
    }).join('');
}

function boxPolys(size, tex, opts) {
    const [x, y, z] = size.map((s) => s / 2);
    return solidPolys([
        {key: 'top', verts: [[-x, -y, z], [x, -y, z], [x, y, z], [-x, y, z]]},
        {key: 'bottom', verts: [[-x, y, -z], [x, y, -z], [x, -y, -z], [-x, -y, -z]]},
        {key: 'ny', verts: [[-x, -y, -z], [x, -y, -z], [x, -y, z], [-x, -y, z]]},
        {key: 'py', verts: [[-x, y, z], [x, y, z], [x, y, -z], [-x, y, -z]]},
        {key: 'nx', verts: [[-x, -y, z], [-x, y, z], [-x, y, -z], [-x, -y, -z]]},
        {key: 'px', verts: [[x, -y, -z], [x, y, -z], [x, y, z], [x, -y, z]]},
    ], tex, opts);
}

function brushActor(cls, name, loc, props, polys, after = '') {
    const lines = props ? props.split('\n').map((s) => '    ' + s).join('\n') + '\n' : '';
    return `Begin Actor Class=${cls} Name=${name}
${lines}    MainScale=(SheerAxis=SHEER_ZX)
    PostScale=(SheerAxis=SHEER_ZX)
    Location=(X=${loc[0]},Y=${loc[1]},Z=${loc[2]})
    Begin Brush Name=${name}Model
       Begin PolyList
${polys}       End PolyList
    End Brush
    Brush=Model'MyLevel.${name}Model'
${after}    Name=${name}
End Actor\n`;
}

const brushProps = (op, opts = {}) => 'CsgOper=' + op + (opts.flags ? '\nPolyFlags=' + opts.flags : '') + '\nTag=Brush';

const box = (name, op, loc, size, tex, opts) =>
    brushActor('Brush', name, loc, brushProps(op, opts), boxPolys(size, tex, opts));

const builder = () => box('Builder', 'CSG_Active', [0, 0, -30000], [64, 64, 64]);

const prism = (name, op, loc, sides, radius, height, tex, opts) => {
    if (sides > 16) throw new Error('UE1 polygons stop at 16 vertices: ' + name);
    const ring = (z) => Array.from({length: sides}, (_, i) => {
        const a = (i + 0.5) * 2 * Math.PI / sides;
        return [radius * Math.cos(a), radius * Math.sin(a), z];
    });
    const [lo, hi] = [ring(-height / 2), ring(height / 2)];
    const faces = [{key: 'top', verts: hi}, {key: 'bottom', verts: lo}];
    for (let i = 0; i < sides; i++) {
        const j = (i + 1) % sides;
        faces.push({key: 'side', verts: [lo[i], lo[j], hi[j], hi[i]]});
    }
    return brushActor('Brush', name, loc, brushProps(op, opts), solidPolys(faces, tex, opts));
};

const wedge = (name, op, loc, size, tex, opts) => {
    const [x, y, z] = size.map((s) => s / 2);
    const n = [[-x, -y, -z], [x, -y, -z]], f = [[x, y, -z], [-x, y, -z]], t = [[x, y, z], [-x, y, z]];
    return brushActor('Brush', name, loc, brushProps(op, opts), solidPolys([
        {key: 'bottom', verts: [...n, ...f]},
        {key: 'top', verts: [n[0], n[1], t[0], t[1]]},
        {key: 'side', verts: [f[0], f[1], t[1], t[0]]},
        {key: 'side', verts: [n[0], f[1], t[1]]},
        {key: 'side', verts: [n[1], f[0], t[0]]},
    ], tex, opts));
};

// base = {x, y, z, width}: climbs towards +Y from y, each step a column standing on z.
// Deus Ex stairs: rise 16, run 16, 24 or 32 (Tack, General Guidelines).
const stairs = (prefix, op, base, steps, tex, rise = 16, run = 32) => {
    let out = '';
    for (let i = 0; i < steps; i++) {
        const h = (i + 1) * rise;
        out += box(prefix + i, op, [base.x, base.y + (i + 0.5) * run, base.z + h / 2], [base.width, run, h], tex);
    }
    return out;
};

const sheetVerts = {
    XY: (a, b) => [[-a, -b, 0], [a, -b, 0], [a, b, 0], [-a, b, 0]],
    XZ: (a, b) => [[-a, 0, b], [a, 0, b], [a, 0, -b], [-a, 0, -b]],
    YZ: (a, b) => [[0, a, b], [0, a, -b], [0, -a, -b], [0, -a, b]],
};

const sheet = (name, loc, plane, w, h, tex, flags, texScale) => {
    const verts = sheetVerts[plane](w / 2, h / 2);
    const n = unit(cross(sub(verts[1], verts[0]), sub(verts[2], verts[0])));
    return brushActor('Brush', name, loc, brushProps('CSG_Add', {flags}), poly(verts, n, tex, flags, texScale));
};

// A ladder as in the stock maps, along a YZ wall: an invisible solid of a Ladder-group texture is
// what the player climbs, a masked sheet in front of it is what the player sees. ladder_a is 128 wide with
// rails at both edges; texScale 2 fits one tile in 64 units. On a plain solid wall ladder_a has no
// mask (Masked needs a sheet) and its see-through part draws black; a sheet alone cannot be climbed.
const ladder = (name, x, y, z, height, face = -1) =>
    box(name + 'Block', 'CSG_Add', [x, y, z], [8, 64, height], 'LadrBrwnMetal', {flags: PF.Invisible | PF.Semisolid | PF.TwoSided})
    + sheet(name + 'Rungs', [x + face * 6, y, z], 'YZ', 64, height, 'ladder_a', PF.Masked | PF.NotSolid | PF.TwoSided, 2);

// Seals a zone across an opening. Needs a ZoneInfo inside the zone it closes.
const zonePortal = (name, loc, width, height, plane = 'YZ') =>
    sheet(name, loc, plane, width, height, '', PF.Portal | PF.TwoSided | PF.NotSolid | PF.Translucent | PF.Invisible);

// Add Special > Water: a portal you can see. Needs a WaterZone under it.
const waterSurface = (name, loc, w, h, tex) =>
    sheet(name, loc, 'XY', w, h, tex, PF.Portal | PF.TwoSided | PF.NotSolid | PF.Translucent);

// loc is the pivot, prePivot its offset inside the brush: a door hinged on its edge.
const mover = (cls, name, loc, size, tex, prePivot, props, opts) =>
    brushActor(cls, name, loc, `${props}\nBasePos=(X=${loc[0]},Y=${loc[1]},Z=${loc[2]})`, boxPolys(size, tex, opts),
        `    PrePivot=(X=${prePivot[0]},Y=${prePivot[1]},Z=${prePivot[2]})\n`);

const actor = (cls, name, loc, props = '') =>
    `Begin Actor Class=${cls} Name=${name}\n    Location=(X=${loc[0]},Y=${loc[1]},Z=${loc[2]})\n`
    + (props ? props.split('\n').map((s) => '    ' + s).join('\n') + '\n' : '')
    + `    Name=${name}\nEnd Actor\n`;

const map = (parts) => 'Begin Map\n' + parts.join('') + 'End Map\n';

module.exports = {PF, builder, box, prism, wedge, stairs, sheet, ladder, zonePortal, waterSurface, mover, actor, map};
