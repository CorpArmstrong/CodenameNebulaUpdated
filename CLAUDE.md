# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Codename Nebula is a **total conversion mod for Deus Ex (GOTY edition)** built on Unreal Engine 1. The mod features a complete story campaign with multiple chapters, branching dialogue, weapon/augmentation/skill systems, and multi-faction gameplay.

## Languages & Tech Stack

- **UnrealScript (.uc)** — Primary language, ~272 source files in `CNN/Classes/`
- **C++ (.cpp/.h)** — Model converter utility (`Converter/obj2de/`) and conversation animation plugin (`ConAnimSys/`)
- **C# (.cs)** — Installer utility (`CNNInstallUtil/`, Visual Studio solution)

## Build System

UnrealScript is compiled by the Unreal Engine 1 `ucc.exe` compiler into `.u` packages. There is no in-repo build command for the UnrealScript — it relies on the Deus Ex SDK toolchain being installed.

- **CNNInstallUtil** — Build via Visual Studio: `CNNInstallUtil/CNNInstallUtil.sln`
- **Converter (obj2de)** — Legacy Visual C++ project: `Converter/obj2de/Source/obj2de.vcproj`
- **Packaging** — `CodenameNebula/package.bat` copies compiled assets into a distribution directory (references Jenkins CI paths at `C:\Jenkins\workspace\CNN-Jenkins\`)
- **Game launch** — `System/CNNStart.bat`

## Development Environment Setup

Complete step-by-step guide to set up the Codename Nebula development environment from scratch.

### Step 1: Install Deus Ex GOTY (Steam)

Install Deus Ex: Game of the Year Edition from Steam. The Steam version is already on patch v1112fm.

> In this guide, `<DeusExRoot>` refers to the Steam install path, e.g. `D:\Program Files (x86)\Steam\steamapps\common\Deus Ex`

### Step 2: Install the Deus Ex SDK v1112fm

[Download SDK v1112fm from ModDB](https://www.moddb.com/games/deus-ex/downloads/sdk-v1112fm).

**Run `Setup.exe`** (not just extract) and point it at `<DeusExRoot>`. The installer registers components needed for conversation compilation. It provides `ucc.exe` (UnrealScript compiler), ConEdit (conversation editor), and UnrealEd (level editor).

> **Important:** Do NOT replace `Core.dll` with the SDK's version — the Steam GOTY `Core.dll` is required for `#exec CONVERSATION IMPORT` to work. The SDK's `Core.dll` silently breaks conversation compilation.

### Step 3: Install the Deus Ex Community Update

[Download from ModDB](https://www.moddb.com/mods/deus-ex-community-update/downloads/deus-ex-community-update-version-241). Install to `<DeusExRoot>`. This provides a patched editor at `Mods/Community Update/System/UnrealEd.exe` that handles large maps without freezing.

After installation, create `DeusEx.exe` in the Community Update folder (the editor's "Play Level" needs it):
```cmd
copy "<DeusExRoot>\Mods\Community Update\System\Deus Ex Community Update.exe" "<DeusExRoot>\Mods\Community Update\System\DeusEx.exe"
```

### Step 4: Clone the Repo and Create Junctions

Clone the repo to any location, then create **directory junctions** from the Deus Ex root:

```cmd
mklink /J "<DeusExRoot>\CodenameNebulaUpdated" "<path-to-this-repo>"
mklink /J "<DeusExRoot>\CNN" "<path-to-this-repo>\CNN"
mklink /J "<DeusExRoot>\CNNText" "<path-to-this-repo>\CNNText"
mklink /J "<DeusExRoot>\CNNMaps" "<path-to-this-repo>\Maps"
```

- `CodenameNebulaUpdated` — main repo access for the engine
- `CNN` — required for `ucc make` to find UnrealScript source files
- `CNNText` — required for `ucc make` to compile conversation/text package
- `CNNMaps` — short path for the editor (avoids path length truncation in UnrealEd 1.x)

### Step 5: Copy Runtime Dependencies to `<DeusExRoot>\System\`

Copy DLLs (engine needs them at runtime):
```cmd
copy "<repo>\System\DXOgg.dll" "<DeusExRoot>\System\"
copy "<repo>\CNN\System\RenderExt.dll" "<DeusExRoot>\System\"
```

Copy precompiled dependency packages:
```cmd
copy "<repo>\System\GaussGun.u" "<DeusExRoot>\System\"
copy "<repo>\System\DXOgg.u" "<DeusExRoot>\System\"
copy "<repo>\System\DXRVNewVehicles.u" "<DeusExRoot>\System\"
copy "<repo>\System\PFAD.u" "<DeusExRoot>\System\"
```

### Step 6: Configure `<DeusExRoot>\System\DeusEx.ini`

This is used by the SDK compiler (`ucc make`) and the original editor.

**Under `[Core.System]`** — append after existing `Paths=` lines:
```ini
Paths=..\CodenameNebulaUpdated\System\*.u
Paths=..\CodenameNebulaUpdated\Maps\*.dx
Paths=..\CodenameNebulaUpdated\Textures\*.utx
Paths=..\CodenameNebulaUpdated\CNN\Sounds\*.uax
Paths=..\CodenameNebulaUpdated\Music\*.umx
```

**Under `[Editor.EditorEngine]`** — append after the last `EditPackages=` line:
```ini
EditPackages=GaussGun
EditPackages=CNN
EditPackages=CNNText
```

**Under `[Editor.EditorEngine]`** — increase cache size:
```ini
CacheSizeMegs=256
```

### Step 7: Configure `<DeusExRoot>\Mods\Community Update\System\DeusEx.ini`

This is used by the Community Update editor (the primary editor for CNN development).

**Under `[Core.System]`** — append after existing `Paths=` lines:
```ini
Paths=..\..\..\CodenameNebulaUpdated\System\*.u
Paths=..\..\..\CodenameNebulaUpdated\Maps\*.dx
Paths=..\..\..\CodenameNebulaUpdated\Textures\*.utx
Paths=..\..\..\CodenameNebulaUpdated\CNN\Sounds\*.uax
Paths=..\..\..\CodenameNebulaUpdated\Music\*.umx
Paths=..\..\..\CNNMaps\*.dx
```

**Under `[Editor.EditorEngine]`** — append after the last `EditPackages=` line:
```ini
EditPackages=GaussGun
EditPackages=CNN
EditPackages=CNNText
```

### Step 8: Compile

From `<DeusExRoot>\System\`:
```cmd
ucc.exe make
```

This produces:
- `CNN.u` — main game logic package (from `CNN/Classes/*.uc`)
- `CNNText.u` — conversations and text content (from `CNNText/Classes/*.uc` importing `.con` files)
- `CNNAudioCNN.u`, `CNNAudioChapter05.u`, `CNNAudioChapter06.u` — conversation audio packages

### Step 9: Deploy Compiled Packages

After compilation, copy packages to the Community Update editor folder:
```cmd
copy "<DeusExRoot>\System\CNN.u" "<DeusExRoot>\Mods\Community Update\System\"
copy "<DeusExRoot>\System\CNNText.u" "<DeusExRoot>\Mods\Community Update\System\"
copy "<DeusExRoot>\System\CNNAudio*.u" "<DeusExRoot>\Mods\Community Update\System\"
copy "<DeusExRoot>\System\GaussGun.u" "<DeusExRoot>\Mods\Community Update\System\"
copy "<DeusExRoot>\System\DXOgg.dll" "<DeusExRoot>\Mods\Community Update\System\"
copy "<DeusExRoot>\System\DXOgg.u" "<DeusExRoot>\Mods\Community Update\System\"
```

Also copy compiled packages back to the repo:
```cmd
copy "<DeusExRoot>\System\CNN.u" "<repo>\System\"
copy "<DeusExRoot>\System\CNNText.u" "<repo>\System\"
copy "<DeusExRoot>\System\CNNAudio*.u" "<repo>\System\"
```

### Step 10: Verify

1. Launch the Community Update editor: `<DeusExRoot>\Mods\Community Update\System\UnrealEd.exe`
2. Open a CNN map (e.g. `06_OpheliaL1.dx` from the `CNNMaps` folder)
3. Press Play Level — map should load with conversations working

### Level Editing Workflow

Use the **Community Update editor** for all map editing:
```
<DeusExRoot>\Mods\Community Update\System\UnrealEd.exe
```

The original SDK editor (`System\UnrealEd.exe`) works for small maps only — it freezes on large maps with 30+ texture packages.

### Known Issues & Pitfalls

- **Do NOT use the SDK's `Core.dll`** — it silently breaks `#exec CONVERSATION IMPORT`. Keep the Steam GOTY `Core.dll`.
- **UnrealEd 2.2 (UED22)** is incompatible with CNN maps — its stripped `.u` packages from UT 469e are missing Deus Ex functions. Engine versions are binary-incompatible; swapping `.u` files doesn't work.
- **Original SDK editor** freezes on large maps (OpheliaL1, MoonIntro) and crashes when clicking empty space with properties window open (`HitSize==0` assertion in `UnCamera.cpp`).
- **Path length limit** — UnrealEd 1.x truncates long file paths. Use the `CNNMaps` junction (short path) instead of the full `CodenameNebulaUpdated\Maps\` path.
- **`CNNText.u`** is a build artifact not in source control. It must be compiled via `ucc make` from `CNNText/Classes/` which imports `.con` conversation files.
- **Kentie's D3D10 renderer** causes `HitSize==0` crashes in the original editor on startup. The D3D9 renderer works but doesn't prevent the freeze.

## Repository Structure

| Directory | Contents |
|-----------|----------|
| `CNN/Classes/` | All UnrealScript source files (game logic, NPCs, weapons, UI, quests) |
| `CNN/Conversations/` | Binary conversation data files (.con) created by ConEdit |
| `CNN/Text/` | In-game text content (datacubes, books, bulletins) by chapter |
| `CNNText/Classes/` | UnrealScript source for conversation/text package (imports .con and .txt files) |
| `CNN/Audio/` | Dialogue audio organized by chapter/character |
| `CNN/Models/` | 3D model files |
| `CNN/Sounds/` | Sound effect archives (.uax) |
| `CodenameNebula/` | Distribution/deployment root (configs, compiled packages, maps, music) |
| `ConAnimSys/` | Native C++ plugin for conversation cutscene animations |
| `Converter/` | obj2de tool — converts 3DS/OBJ models to Unreal .t3d format |
| `CNNInstallUtil/` | C# .NET installer that configures game .ini files |
| `CNNInstaller/` | Installer resources and batch scripts |
| `CNNDocs/` | Design docs, story notes, concept art, walkthrough guides |
| `Maps/` | Raw map source files (.t3d, .dx) |
| `Textures/` | Unreal texture packages (.utx) |
| `Music/` | Game music (.umx, .ogg) |
| `System/` | Engine DLLs, compiled packages (.u), configuration |

## Key Source Files

- `CNN/Classes/CNNGameInfo.uc` — Game rules and initialization
- `CNN/Classes/TantalusDenton.uc` — Player character (extends JCDentonMale)
- `CNN/Classes/AiSkillManager.uc` — Skill progression system
- `CNN/Classes/AiAugmentationManager.uc` — Cybernetic augmentation system
- `CNN/Classes/AiConPlay.uc` / `CASConPlay.uc` — Conversation playback
- `CNN/Classes/QuestSystem.uc` — Mission/quest tracking
- `CodenameNebula/CNN.ini` — Main game configuration

## File Formats

- `.uc` — UnrealScript source
- `.u` — Compiled Unreal packages
- `.dx` — Deus Ex map files
- `.utx` — Unreal texture packages
- `.umx` / `.uax` — Unreal music/audio packages
- `.con` — Deus Ex conversation data (binary)
- `.t3d` — Unreal text interchange format

## Architecture Notes

- All gameplay classes inherit from Deus Ex base classes (e.g., `DeusExGameInfo`, `JCDentonMale`, `ScriptedPawn`)
- The conversation system uses binary `.con` files with companion audio files, animated via the native `ConAnimSys` C++ plugin
- The skill system adds custom skills (Chinese, French, Bionics, Piloting) beyond the base Deus Ex skills
- Multiple weapon systems extend the base game: coil gun, avatar bite, UPS weapons, Gauss gun
- Chapter structure: Moon base intro (Ch 5), Ophelia station (Ch 6), with NYC/UNATCO connecting segments

## Code Review (2026-04-04)

### Critical Issues

1. **Incomplete file won't compile** — `CNN/Classes/ApocalypseInsideMenuStartNewGame.uc:62`
   `defaultproperties` block cuts off mid-assignment (`buttonDefaults(0)=` with no value). File cannot compile.

2. **Self-assignment no-op** — `CNN/Classes/ToggleActorLifecycleTrigger.uc:44`
   `spawnPoint = spawnPoint;` assigns variable to itself. The member variable is never set, so actor spawning uses default coordinates.

3. **Pass-by-value counter never increments** — `CNN/Classes/ObjectsDestroyNotifier.uc:78`
   `destroyedObjectsCounter++` modifies a local copy of the integer parameter. The caller in `PollObjects()` never sees the increment, so the "all objects destroyed" condition at line 66 is never true. Parameter needs the `out` keyword.

4. **Empty bool function with no return** — `CNN/Classes/TantalusDenton.uc:155`
   `CheckActorDistances()` declares `bool` return but has an empty body. Returns undefined value.

5. **Buffer overflow in C++ converter** — `Converter/obj2de/Source/main.cpp:285`
   `strcpy(NameStr, NameStrCopy.c_str())` with no bounds check on a `char[_MAX_FNAME]` buffer. Also at line 275.

6. **Unsigned underflow on empty string** — `Converter/obj2de/Source/main.cpp:281`
   `NameStr[strlen(NameStr) - 1]` — if fgets reads an empty string, `strlen` returns 0, and `0 - 1` wraps to `SIZE_MAX`.

### High Priority

7. **AllActors in Tick — performance** — `CNN/Classes/CNNUPS.uc:287-334`
   Three `foreach AllActors()` loops iterate every actor every frame. Should cache references or use a timer.

8. **Missing null check on conOwner** — `CNN/Classes/CnnConversTrigger.uc:52`
   If `AllActors` loop finds no matching actor, `conOwner` stays `None` and is passed directly to `StartConversationByName()`.

9. **Missing null check on sCam** — `CNN/Classes/LaserSecurityController.uc:91`
   `sCam.bNoAlarm = bNoAlarm` executes even if no SecurityCamera with the given tag exists, crashing on `None` access.

10. **Duplicate augmentation grant** — `CNN/Classes/Chapter05.uc:115,160`
    Identical `HasHeartAug` check + `GivePlayerAugmentation(AugHeartLung)` block appears twice. Player can receive the augmentation twice.

11. **Division by zero risk** — `Converter/obj2de/Source/FileOBJ.cpp:25-27`
    `VectorLength(n)` result used as divisor without zero check. Degenerate triangles will crash.

12. **File handle leaks** — `Converter/obj2de/Source/File3DS.cpp:29`, `Converter/obj2de/Source/UnrealModel.cpp:184`
    `fopen()` file pointers are never closed if exceptions are thrown during processing.

13. **Dead functions return 0** — `Converter/obj2de/Source/FileOBJ.cpp:375-382`
    `GetNumPolygons()` and `GetNumVertices()` always return 0. Never implemented.

### Medium Priority

14. **Debug msgbox calls left in production code:**
    - `CNN/Classes/MandatoryMovementTriger.uc:72` — `msgbox("MovedPawn not finded")`
    - `CNN/Classes/DestroyTrigger.uc:38,42,49` — multiple `self.MsgBox()` calls

15. **Uninitialized variable in dead branch** — `CNN/Classes/CNNCreditsWindowTest.uc:206-211`
    `bKeyHandled` is declared but never assigned, making the `if (bKeyHandled)` branch unreachable.

16. **Variable shadowing in C++** — `Converter/obj2de/Source/UnrealModel.cpp:234-235`
    Iterator `v` declared, then immediately shadowed by loop variable `int v`. The iterator is dead code.

17. **Inconsistent path construction in C#** — `CNNInstallUtil/CNNInstallUtil/InstallUtil.cs:119-123`
    `pathToOggMusic` computed from parent directory, but `pathToModOggMusic` uses hardcoded `"Music\\Ogg"` from a different base.

18. **Broken format string** — `CNNInstallUtil/CNNInstallUtil/Program.cs:15`
    `WriteLine("...{0}..." + e.Message)` — the `{0}` placeholder is never filled; `e.Message` is concatenated to the format string instead.

### Low Priority

19. **Code duplication** — `CNN/Classes/GreenLaserTrigger.uc` and `CNN/Classes/DamageLaserTrigger.uc` are ~325-line near-duplicates differing only in emitter class/texture. Same for `CNN/Classes/IVUnit.uc` / `CNN/Classes/ShopCart.uc`.

20. **Typo in variable name** — `CNN/Classes/CNNMisson01.uc:7` — `laserDipatcher` (missing 's').
