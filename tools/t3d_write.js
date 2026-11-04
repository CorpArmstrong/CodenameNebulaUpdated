/*
 * t3d_write.js - write brushes and actors as a .t3d that UnrealEd imports with
 * MAP IMPORTADD FILE=... (tools/cnn_edcmd.ps1 sends it).
 *
 * The FIRST Brush of an imported .t3d replaces the red builder brush and takes
 * no part in the CSG, so start with builder(). A map or a patch made without it
 * silently loses its first brush.
 *
 *   const {builder, box, mover, zonePortal, actor, map} = require('./t3d_write');
 *   fs.writeFileSync('Room.t3d', map([
 *     builder(),
 *     box('RoomA', 'CSG_Subtract', [0,0,128], [512,512,256], {top:'ClenGrayMetal_B', bottom:'DiamPlatSteel_A', side:'DrtyCastCemnt_A'}),
 *     actor('PlayerStart', 'PlayerStart0', [-150,0,48]),
 *     actor('Light', 'Light0', [0,0,220], 'LightBrightness=160\nLightRadius=32'),
 *   ]));
 *
 * Coordinates are centre + full size. Textures go by name; their package has
 * to be loaded first (OBJ LOAD), or the surface imports untextured.
 *
 * PathNode and PatrolPoint go 15 units above the floor (their CollisionHeight,
 * where the editor's A key puts them). At 30 and up PATHS DEFINE builds no
 * reachspecs: 0 links, the nodes only in VisNoReachPaths. A pawn then cannot
 * path, and a Patrolling pawn with pausetime=0 dies with "Runaway loop"
 * (ScriptedPawn state Patrolling loops with no latent call).
 */

const num = (n) => (n < 0 ? '-' : '+') + Math.abs(n).toFixed(6).padStart(13, '0');
const vec = (v) => v.map(num).join(',');

function poly(tex, normal, u, w, verts, flags) {
    const head = 'Begin Polygon' + (tex ? ' Texture=' + tex : '') + (flags ? ' Flags=' + flags : '');
    return `          ${head}
             Origin   ${vec(verts[0])}
             Normal   ${vec(normal)}
             TextureU ${vec(u)}
             TextureV ${vec(w)}
${verts.map((p) => '             Vertex   ' + vec(p)).join('\n')}
          End Polygon\n`;
}

function boxPolys(size, tex) {
    const [x, y, z] = size.map((s) => s / 2);
    const t = (tex && typeof tex === 'object') ? tex : {top: tex, bottom: tex, side: tex};
    return poly(t.top, [0, 0, 1], [1, 0, 0], [0, 1, 0], [[-x, -y, z], [x, -y, z], [x, y, z], [-x, y, z]])
        + poly(t.bottom, [0, 0, -1], [1, 0, 0], [0, -1, 0], [[-x, y, -z], [x, y, -z], [x, -y, -z], [-x, -y, -z]])
        + poly(t.side, [0, -1, 0], [1, 0, 0], [0, 0, 1], [[-x, -y, -z], [x, -y, -z], [x, -y, z], [-x, -y, z]])
        + poly(t.side, [0, 1, 0], [1, 0, 0], [0, 0, -1], [[-x, y, z], [x, y, z], [x, y, -z], [-x, y, -z]])
        + poly(t.side, [-1, 0, 0], [0, 1, 0], [0, 0, -1], [[-x, -y, z], [-x, y, z], [-x, y, -z], [-x, -y, -z]])
        + poly(t.side, [1, 0, 0], [0, 1, 0], [0, 0, 1], [[x, -y, -z], [x, y, -z], [x, y, z], [x, -y, z]]);
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

const builder = () => box('Builder', 'CSG_Active', [0, 0, -30000], [64, 64, 64]);

const box = (name, op, loc, size, tex) =>
    brushActor('Brush', name, loc, 'CsgOper=' + op + '\nTag=Brush', boxPolys(size, tex));

// A sheet across an opening along Y/Z; needs a ZoneInfo inside the zone it seals off.
const zonePortal = (name, loc, width, height) => {
    const [y, z] = [width / 2, height / 2];
    return brushActor('Brush', name, loc, 'CsgOper=CSG_Add\nPolyFlags=67108873\nTag=Brush',
        poly('', [-1, 0, 0], [0, -1, 0], [0, 0, 1], [[0, y, z], [0, y, -z], [0, -y, -z], [0, -y, z]], 67109133));
};

// loc is the pivot, prePivot its offset inside the brush: a door hinged on its edge.
const mover = (cls, name, loc, size, tex, prePivot, props) =>
    brushActor(cls, name, loc, `${props}\nBasePos=(X=${loc[0]},Y=${loc[1]},Z=${loc[2]})`, boxPolys(size, tex),
        `    PrePivot=(X=${prePivot[0]},Y=${prePivot[1]},Z=${prePivot[2]})\n`);

const actor = (cls, name, loc, props = '') =>
    `Begin Actor Class=${cls} Name=${name}\n    Location=(X=${loc[0]},Y=${loc[1]},Z=${loc[2]})\n`
    + (props ? props.split('\n').map((s) => '    ' + s).join('\n') + '\n' : '')
    + `    Name=${name}\nEnd Actor\n`;

const map = (parts) => 'Begin Map\n' + parts.join('') + 'End Map\n';

module.exports = {builder, box, zonePortal, mover, actor, map};
