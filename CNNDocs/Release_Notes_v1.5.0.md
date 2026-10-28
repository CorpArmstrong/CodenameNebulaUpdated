# Codename Nebula v1.5.0 — release notes

*Changes since v1.4.4. Rewritten 2026-10-28; final once the playthrough is done.*

## Ophelia Ring 2 is finished

Level 2 now plays to an end. What you do on the station decides which of four endings you get:

- **Hijacking.** Once Magdalene proposes taking the station, MJ12 are on their way and the
  bridge opens — you have four minutes. Deal with Mephistopheles and Wong and take the ship's
  wheel while Magdalene is still alive.
- **Transcendence.** Put Magdalene in the Avatar Lab tube, start the upload and survive the
  countdown.
- **Conspiracy.** MJ12 dock before you have done either.
- **Mutiny.** Die on Ring 2, or give in to Mephistopheles.

Each ending has its own closing quote, followed by the credits and then the main menu.

## New: the Social Boss scene

Mephistopheles and Michael Wong hold the bridge, with Corporal Armstrong, Dr. Johnson and
Samantha Reed as hostages. Wong executes hostages as the confrontation goes on, Tantalus's
Chinese lets him apologise to Wong or turn him against Mephistopheles, and the scene ends in a
fight — or in surrender. Part of the scene is voiced; the rest plays as subtitles.

## Samantha Reed and Dr. Reed's stateroom

Bob Page and President Mead ask Tantalus to check on Page's daughter, Professor Samantha
Reed, in Hawking's gravity lab. He finds her arguing with a "scientist" who is not what he
says. Side with Samantha and she asks for help finding her mother, and gives the code to
their stateroom, up the gravity lab shaft. Dr. Reed's security computer there keeps archive
recordings of Michael Wong; having seen them lets Tantalus manipulate Wong on the bridge
without accusing him first (Chinese still needed).

## New launcher and installer

- **The installer finds the game by itself** (Steam, GOG or a CD copy patched to 1112fm),
  checks the folder, and warns if the game is not on 1112fm or another mod replaced
  `DeusEx.u`. It is about 80 MB: unused packages and music are no longer shipped.
- **One "Codename Nebula" shortcut.** The launcher starts the game the right way for your
  copy — through Steam for the Steam version, whose own `DeusEx.exe` will not start any other
  way. It replaces the old .bat shortcuts and the Fix Renderer tools.
- **Settings:** renderer, resolution, fullscreen or window. **Repair** restores the mod's
  settings when the game will not start.
- **The mod keeps to its own folder.** Music plays from `CodenameNebula`, nothing of another
  mod is overwritten, saves stay in `CodenameNebula\Save`, and the game's first-run wizard (which
  picks Software Rendering on current PCs) no longer appears.
- **Uninstalling** removes only the files the mod added, and only if they are unchanged.
- A new game on a never-configured copy of Deus Ex no longer starts on a renderer or colour
  depth that Windows 10/11 cannot set.

## The station looks different

- New station textures: our own, CC0 and stock Deus Ex ones in place of a texture pack we
  could not clear for distribution. The wall screens on Ring 1 show pictures again.
- The station's entry doors are proper models: Ring 2 runs at several times the frame rate it
  did, and doors no longer show a black leaf or leave an invisible hull behind.
- Infolink portraits for the new characters.
- A few sounds we had no permission to ship were replaced with our own.

## Fixes

- Saved games on Ring 2 now keep everything that matters: the MJ12 countdown, the state of the
  bridge scene and fight, the tube and the upload countdown. Ring 2 saves are named after the
  level.
- Saving during a conversation is no longer possible — such saves could not be loaded.
- Datacubes, books, bulletins and the credits had lost their text; it is back.
- Giving Magdalene a weapon in the "arm Magdalene" conversation now works on every map.
- The medical bot next to Magdalene on the docks works: a stray EMP grenade no longer goes off
  beside it when the level loads (it now lies there defused, for you to pick up).
- Arriving on the docks, the EMP grenade by the landing spot goes off as you step out and
  drains your bioenergy, as designed, instead of waiting as an ordinary trap.
- Grenades placed in the levels flash the screen when they go off, like thrown ones.
- Skipping a cutscene no longer drags you along the camera's path.
- The Ring 1 inspection-room conversation plays on leaving the elevator.
- The tube glass now closes over Magdalene instead of beside her, and she catches up with you
  near the Avatar Lab instead of being left behind.
- The comm centre doors open even if the MJ12 sergeant dies before you talk to him (this was a
  dead end).
- The avatars now join the comm centre battle.
- Conversations from Ring 1 and from the docks no longer play on Ring 2 in place of Ring 2's own.
- The goals from Bob Page's infolink and President Mead's holocomm message ("check up on his
  daughter in the Gravity lab") can now be completed.
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
- The in-game "Rendering Device..." list still offers the old 1999 "Direct3D support" renderer,
  which gives a black screen on Windows 10/11. If you picked it, open the launcher's Settings
  and choose Direct3D 9. If the game runs but the monitor stays black, turn Fullscreen off
  there.
- The Steam overlay works only with the OpenGL or Direct3D 7 renderer.

## Install

Run `CodenameNebula_v1.5.0.exe`; it finds your Deus Ex (Steam, GOG, or a CD copy patched to
1112fm). Play with the "Codename Nebula" shortcut. Windows 10 or 11 is required.
