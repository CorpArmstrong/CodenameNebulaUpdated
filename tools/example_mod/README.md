# Example mod: LessonMod and the level 72_Interact

A mod built from nothing by scripts, with no ConEdit and no clicks in UnrealEd: its own package with
text and conversations, and a level with the devices of Steve Tack's tutorials. Nothing here touches
the package CNN. Everything below was run and played on 2026-11-04.

## Steps

1. `node tools/example_mod/build.js <out>` writes `<out>\LessonMod\` and `<out>\72_Interact.t3d`.
2. Make a junction `<DeusExRoot>\LessonMod` to `<out>\LessonMod`, and a copy of `System\DeusEx.ini` with
   `EditPackages=LessonMod` added at the end, say `System\LessonMake.ini`.
3. `tools\ucc_safeheap.ps1 -SystemDir <DeusExRoot>\System make INI=LessonMake.ini` writes `LessonMod.u`,
   `LessonModText.u` and `LessonModAudioMission72.u` to `System`. Move them to `<out>`, so the game's
   own folder stays clean.
4. `subst X: <out>` (UnrealEd cuts paths at 79 characters), then open the editor with the mod's paths:
   `tools\cnn_ued.ps1 -Map X:\<any map> -ExtraPaths 'X:\*.u','X:\*.dx'`
5. By `tools\cnn_edcmd.ps1`: `MAP NEW`, `OBJ LOAD` for each package printed by step 1,
   `MAP IMPORTADD FILE=X:\72_Interact.t3d`, `MAP REBUILD`, `LIGHT APPLY`, `PATHS DEFINE`,
   `MAP SAVE FILE=X:\72_Interact.dx`.
6. `tools\cnn_ued.ps1 -Play` plays it as the CNN player with the bridge alive; `-Close` when done.
   Remove the junction, the ini and the `subst` afterwards.

## Playing it as a player

The bridge's `FROB` calls the actor's function directly. What the player's buttons do goes through
console commands, after `LOOKAT` has put the thing under the crosshair:

| Button | Bridge command | Use |
|---|---|---|
| right mouse | `RAW ParseRightClick` | pick up, talk, open a door, read, press a switch |
| left mouse | `RAW ParseLeftClick` | a nano key ring or a lockpick on the door in view |
| 0-9 | `RAW ActivateBelt <n>` | take a belt item in hand; slot 0 is the key ring |

A melee hit needs a real mouse press: `WM_LBUTTONDOWN` posted to the viewport works, `RAW Fire` does
nothing. Window messages also reach the game's UI without focus: `WM_KEYDOWN`/`WM_CHAR` for the digits
of a keypad, a login (`NAME`, Tab, `PASSWORD`, Enter), Tab and Space for buttons. Esc with no UI open
brings up the main menu and pauses the game, and the bridge with it.

## What it shows

- **A key does not open a door by itself.** Use on a locked door only says it is locked: the key ring
  has to be in hand and used with the left button, and that only unlocks; Use then opens it.
- **`bBreakable`** is False on a plain `DeusExMover`: `doorStrength` means nothing without it.
- **Glass** is drawn by adding its colour, so a dark texture is nearly invisible and that is normal:
  `07WindOpacStrek` averages 10 of 255. Of 253 stock windows most use it, on two faces, with the edges
  `Invisible|Semisolid`. `FrosWhitGlass_A` and `SafeGrenGlass_A` show plainly.
- **A ladder** is an invisible solid of a Ladder-group texture plus a masked sheet of rungs
  (`t3d_write.js`, `ladder()`). `ladder_a` on a plain wall draws black between the rungs; a sheet alone
  cannot be climbed.
- **A `ComputerPersonal` falls** to the floor unless something stands under it. `ComputerPublic` and
  `ComputerSecurity` stay where they are put.
- **A player whose BindName is not `JCDenton`** cannot use `displayAsSpeech` on a choice: the engine says
  the line as `JCDenton`, the conversation then fails `CheckActors` and Use does not start it.
- **A bark with the player in it blocks Use** on its owner while it plays.
