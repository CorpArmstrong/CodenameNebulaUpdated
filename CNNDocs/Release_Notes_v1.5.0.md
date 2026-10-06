# Codename Nebula v1.5.0 — release notes (DRAFT)

*Draft, 2026-10-06. Changes since v1.4.4. To be finalised after the full playthrough and the
clean-install check.*

## Ophelia Ring 2 is finished

Level 2 now plays to an end. What you do on the station decides which of four endings you get:

- **Hijacking.** Once Magdalene proposes taking the station, MJ12 are on their way and the
  bridge opens — you have four minutes. Deal with Mephistopheles and Wong and take the ship's
  wheel while Magdalene is still alive.
- **Transcendence.** Put Magdalene in the Avatar Lab tube, start the upload and survive the
  countdown.
- **Conspiracy.** MJ12 dock before you have done either.
- **Mutiny.** Die on Ring 2, or give in to Mephistopheles.

Each ending has its own closing quote, followed by the credits.

## New: the Social Boss scene

Mephistopheles and Michael Wong hold the bridge, with Corporal Armstrong, Dr. Johnson and
Samantha Reed as hostages. The fully voiced confrontation plays out on the bridge: Wong
executes hostages as it goes on, Tantalus's Chinese lets him apologise to Wong or turn him
against Mephistopheles, and the scene ends in a fight — or in surrender.

## Fixes

- Saved games on Ring 2 now keep everything that matters: the MJ12 countdown, the state of the
  bridge scene and fight, the tube and the upload countdown. Ring 2 saves are named after the
  level.
- Saving during a conversation is no longer possible — such saves could not be loaded.
- Giving Magdalene a weapon in the "arm Magdalene" conversation now works.
- The tube glass now closes over Magdalene instead of beside her, and she catches up with you
  near the Avatar Lab instead of being left behind.
- The comm centre doors open even if the MJ12 sergeant dies before you talk to him (this was a
  dead end).
- The avatars now join the comm centre battle.
- Conversations from Ring 1 and from the docks no longer play on Ring 2 in place of Ring 2's own.
- The unfinished Bob Page / Samantha Reed side story is switched off instead of leaving goals
  that could not be completed.
- The hostages show their real names and leave their own bodies.
- Bodies set on fire burn once instead of forever.
- Crashes fixed: travelling after using a holocomm unit; travelling to an ending after the
  upload countdown; the save made on the way to an ending while an augmentation was active.
- Some invisible helper objects were drawn as sprites in the world.
- Magdalene no longer carries 99 coil guns.
- A console key is bound for players who never bound one.

## Known issues

- An invisible wall blocks part of a walkway on Ring 2 (map geometry; a fix needs the level
  editor).
- The in-game "Rendering Device" menu still lists the old 1999 "Direct3D support" renderer,
  which gives a black screen on Windows 10/11. Pick "Direct3D9 support" instead. If the game
  no longer starts, set `GameRenderDevice=D3D9Drv.D3D9RenderDevice` in
  `CodenameNebula\System\CNN.ini`.
- Steam play time comes with the "Play Codename Nebula Steam" shortcut; the Steam overlay works
  only with the OpenGL or Direct3D 7 renderer.

## Install

Run `CodenameNebula_v1.5.0.exe` and point it at your Deus Ex folder (Steam, GOG or CD,
patched to 1112fm). Play with the "Play Codename Nebula" desktop shortcut, or "Play Codename
Nebula Steam" to launch through Steam.
