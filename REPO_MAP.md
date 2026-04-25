# Codename Nebula — Repository Map

Total conversion mod for Deus Ex (GOTY/UE1) featuring a Moon → Ophelia campaign with branching dialogue and custom weapon/augmentation/skill systems. Build pipeline:

```
source (CNN/Classes, CNN/Conversations, CNN/Audio, CNNText/Text, Maps, Textures, Music)
  → ucc.exe make → System/*.u
  → cnn.bat package → CodenameNebula/ (distribution staging)
  → Inno Setup → Build/CodenameNebula_v<version>.exe
```

Sister docs: [CLAUDE.md](CLAUDE.md) (project guide), [SetupCNN.md](SetupCNN.md) (setup), [Phase5_6_Audit.md](Phase5_6_Audit.md) (reachability audit), [_Backups/README.md](_Backups/README.md) (cleanup history).

## Quick reference

| Category | Locations | Tracked? |
|---|---|---|
| Source | [CNN/Classes/](CNN/Classes/), [CNN/Conversations/](CNN/Conversations/), [CNN/Audio/](CNN/Audio/), [CNNText/Classes/](CNNText/Classes/), [CNNText/Text/](CNNText/Text/), [Maps/](Maps/), [Textures/](Textures/), [Music/](Music/) | yes |
| Build tooling | [cnn.bat](cnn.bat), [tools/](tools/), [CNNInstallUtil/](CNNInstallUtil/), [CNNInstaller/](CNNInstaller/), [Converter/](Converter/), [ConAnimSys/](ConAnimSys/) | yes |
| Distribution staging | [CodenameNebula/](CodenameNebula/) | partial (placeholders + a few source files only) |
| Build output | `System/*.u`, [Build/](Build/) | no (gitignored) |
| Documentation | [CLAUDE.md](CLAUDE.md), [SetupCNN.md](SetupCNN.md), [CNNDocs/](CNNDocs/), [Phase5_6_Audit.md](Phase5_6_Audit.md), [REPO_MAP.md](REPO_MAP.md) | yes |
| Engine runtime support | `System/*.dll`, [CodenameNebula/RootSystemFiles/](CodenameNebula/RootSystemFiles/) | partial |
| Quarantine (cleanup archive) | [_Backups/](_Backups/) | yes |

**Counts (post-Phase 7):** 267 UC in CNN/Classes + 1 UC in CNNText/Classes • 6 `.con` conversations • 398 `.wav` audio files • 25 text files in CNNText/Text • 11 `.dx` maps (10 shipped + 1 experimental `Entryv2.dx`) • 10 `.utx` texture packages • 22 `.ogg` music tracks + 1 `.umx` • Version `1.3.9`.

---

## 1. Source

### UnrealScript — `CNN/Classes/` (267 files) + `CNNText/Classes/` (1 file)

Compiled into `CNN.u` and `CNNText.u` by `ucc.exe make`. Picked up via `EditPackages=CNN` and `EditPackages=CNNText` lines in the SDK's `<DeusExRoot>\System\DeusEx.ini` (not in this repo).

UE1 constraint: every `.uc` must live directly in `<Package>/Classes/` — no nested directories allowed.

### Conversations — `CNN/Conversations/` (6 binary `.con` files)

Imported via `#exec CONVERSATION IMPORT FILE=Conversations\X.Con` directives in [CNN/Classes/ImportConversations.uc:9-14](CNN/Classes/ImportConversations.uc). Compiled into `CNN.u`. UE1 resolves the path relative to the package directory.

After Phase 7 cleanup, this is the **canonical** conversation tree (the duplicate `CNNText/Conversations/` was quarantined).

### Audio — `CNN/Audio/` (398 `.wav` files)

Organized by `ChapterXX/<character>/` subdirectories. Two reachability paths:
- 4 files explicitly imported via `#exec AUDIO IMPORT` in [CNN/Classes/ImportSounds.uc](CNN/Classes/ImportSounds.uc)
- ~394 referenced by name from `.con` conversation files (the conversation system pulls them at runtime)

Compiled into `CNNAudioCNN.u`, `CNNAudioChapter05.u`, `CNNAudioChapter06.u`.

### Text content — `CNNText/Text/` (25 files)

Plain `.txt` files (datacubes, books, bulletins, profiles, credits) organized by `missionXX/`. Imported via `#exec DEUSEXTEXT IMPORT FILE=text\...` directives in [CNNText/Classes/CNNTextImport.uc](CNNText/Classes/CNNTextImport.uc). Compiled into `CNNText.u`.

### Maps — `Maps/` (11 `.dx` files)

**Production maps** (10, whitelisted in [cnn.bat:364](cnn.bat#L364)):
- `CNNentry.dx` — entry point, copied to `DX.dx` at install
- `05_MoonIntro.dx`
- `06_OpheliaDocks.dx`, `06_OpheliaL1.dx`, `06_OpheliaL2.dx`, `06_OpheliaL2_QuestSystem.dx`
- `06_Conspiracy.dx`, `06_Hijacking.dx`, `06_Mutiny.dx`, `06_Transcend.dx`

**Experimental:** `Entryv2.dx` — WIP variant of CNNentry, not in the whitelist.

### Textures — `Textures/` (10 `.utx` packages)

Copied verbatim by [cnn.bat:385](cnn.bat#L385). Each `.utx` is a pre-built UE1 texture container; references come from map name tables and UC `defaultproperties`. Per Phase 5 audit, all 10 packages remaining are reachable from at least one map.

### Music — `Music/`

`Terrified.umx` (UE1 music package) + `Music/Ogg/*.ogg` (22 streaming Ogg tracks loaded by `DXOgg` plugin). Both copied verbatim by `cnn.bat package`.

---

## 2. Build tooling

### `cnn.bat` — root build tool

15 subcommands (dispatch table at [cnn.bat:130-144](cnn.bat#L130)):

| Subcommand | Role |
|---|---|
| `setup` | First-time setup: junctions, DLL copies, `.ini` patches |
| `compile` | Run `ucc.exe make` — compiles all `EditPackages` |
| `package` | Stage built assets into [CodenameNebula/](CodenameNebula/) |
| `installer` | Generate Inno Setup script + build `Build/CodenameNebula_v<version>.exe` |
| `install` | Deploy mod to local Deus Ex install for testing |
| `test` | Launch via `CodenameNebula.exe` (renamed `DeusEx.exe`) |
| `steam` | Launch via Steam (preserves overlay/playtime) |
| `reset` | Regenerate `CNN.ini`/`CNNUser.ini` from player's `DeusEx.ini` |
| `clean` | Delete compiled `.u` packages |
| `bump [part]` | Increment version in `version.txt` (default `patch`) |
| `version` | Print current version |
| `hd` | Detect/inject NewVision/HDTP texture paths |
| `renderer` | Switch graphics renderer in `CNN.ini` |
| `all` | `compile` + `package` + `installer` |
| `help` | Show help with detected paths |

Auto-detects Deus Ex root (Steam → GOG → CD registry) and Inno Setup. Manual override saved to `cnn.local.bat` (gitignored).

### PowerShell helpers — [tools/](tools/)

- [generate_cnn_ini.ps1](tools/generate_cnn_ini.ps1) — Generate `CNN.ini` from player's `DeusEx.ini`, preserving renderer/resolution/audio settings (called by `cnn install` and `cnn reset`)
- [inject_hd_paths.ps1](tools/inject_hd_paths.ps1) — Inject NewVision/HDTP texture paths (called by `cnn hd`)
- [steam_launch.ps1](tools/steam_launch.ps1) — Steam-overlay-preserving launch wrapper (called by `cnn steam`)

### C# installer post-processor — [CNNInstallUtil/](CNNInstallUtil/)

Visual Studio 2022 solution. Build via MSBuild (preferred) or `dotnet publish` for single-file `.exe` ([cnn.bat:446-471](cnn.bat#L446)). Generates per-player `CNN.ini` from the player's existing `DeusEx.ini` at install time. Output binary copied into [CodenameNebula/](CodenameNebula/).

### Inno Setup installer — [CNNInstaller/](CNNInstaller/)

Template script: [CNNSetup.iss](CNNInstaller/CNNSetup.iss). `cnn installer` generates a dynamic version with current paths/version/file list and runs `iscc.exe`. Output: `Build/CodenameNebula_v<version>.exe`. Bundled assets: license, info text, wizard images.

### Legacy tools — [Converter/](Converter/) + [ConAnimSys/](ConAnimSys/)

- **Converter/obj2de/** — VC++ project that converts 3DS/OBJ models to UE1 `.t3d`. Not invoked by the active pipeline; kept as standalone source tool.
- **ConAnimSys/** — Native C++ DLL plugin for conversation cutscene animations. Source-only in this repo; the compiled DLL ships with the mod via `RootSystemFiles/`.

---

## 3. Distribution staging — `CodenameNebula/`

Mostly build output. **Tracked source files** (regenerating these by hand requires care):

| File | Purpose |
|---|---|
| [CodenameNebula/PlayCNNSteam.bat](CodenameNebula/PlayCNNSteam.bat) | Steam launcher (copied to dist by `cnn package`) |
| [CodenameNebula/cnnico.ico](CodenameNebula/cnnico.ico) | Installer/launcher icon |
| [CodenameNebula/RootSystemFiles/D3D9Drv.int](CodenameNebula/RootSystemFiles/D3D9Drv.int) | D3D9 renderer localization (lands in game `System/`) |
| [CodenameNebula/RootSystemFiles/DXOgg.u](CodenameNebula/RootSystemFiles/DXOgg.u) | Prebuilt Ogg playback package |
| [CodenameNebula/RootSystemFiles/enbseries.ini](CodenameNebula/RootSystemFiles/enbseries.ini) | Optional ENB graphics config |
| `CodenameNebula/Maps/dummy.txt`, `CodenameNebula/Save/dummy.txt` | Empty-dir placeholders for the installer |

**Generated by `cnn package`** (gitignored): everything else — `Maps/*.dx`, `Music/`, `Textures/`, `System/` packages, `CNNInstallUtil.exe`, `PlayCodenameNebula.bat`, `tools/steam_launch.ps1`. The 449 MB on disk regenerates from sources every package run.

---

## 4. Build output (gitignored)

### Compiled packages — `System/`
`ucc.exe make` writes here, then `cnn package` copies into `CodenameNebula/System/`:
- `CNN.u` — main script package (~35 MB)
- `CNNText.u` — text content (after Phase 7, **no longer** holds duplicate conversations)
- `CNNAudioCNN.u`, `CNNAudioChapter05.u`, `CNNAudioChapter06.u` — audio packages
- Dependencies copied during setup: `GaussGun.u`, `PFAD.u`, `DXRVNewVehicles.u`, `DXOgg.u`, `DXOgg.dll`, `D3D9Drv.dll`, `RenderExt.dll`

### Installer — `Build/`
- `CodenameNebula_v<version>.exe` — Inno Setup output
- `CNNSetup.generated.iss` — temp script regenerated each build

---

## 5. Documentation

| File | Role |
|---|---|
| [CLAUDE.md](CLAUDE.md) | Primary project guide; setup steps, code organization, code-review notes |
| [SetupCNN.md](SetupCNN.md) | Concise setup-only doc (dependencies, junctions, INI config) |
| [CNNDocs/](CNNDocs/) | Design docs, story notes, audio transcripts, walkthroughs, concept art |
| [Phase5_6_Audit.md](Phase5_6_Audit.md) | Reachability audit history with corrections (which classes/textures are actually used) |
| [REPO_MAP.md](REPO_MAP.md) | This file |
| [_Backups/README.md](_Backups/README.md) | Provenance index for everything in the cleanup archive |

---

## 6. Engine runtime support

Files needed at runtime that aren't compiled or generated:

| File | Role |
|---|---|
| `System/DXOgg.dll` | Ogg streaming plugin |
| `System/RenderExt.dll` | UnrealEd extension (also used by Community Update editor) |
| `System/D3D9Drv.dll` | D3D9 renderer |
| `CodenameNebula/RootSystemFiles/D3D9Drv.int` | Localization for D3D9Drv |
| `CodenameNebula/RootSystemFiles/DXOgg.u` | Prebuilt Ogg package (separate from compiled `CNN.u`) |
| `CodenameNebula/RootSystemFiles/enbseries.ini` | ENB graphics preset (optional) |

These are copied into the game's `System/` folder during install.

---

## 7. Quarantine — `_Backups/`

Cleanup archive. Files here are **not** referenced by any build step or runtime path. See [_Backups/README.md](_Backups/README.md) for full per-file provenance.

| Phase | Folder | Why |
|---|---|---|
| 1 | (none) | Gitignore preparation only — no physical moves |
| 2 | `Phase2_Backups/`, `Phase2_OldMaps/` | `.con` backups, WIP map iterations, stray notes — git history is authoritative |
| 3 | `Phase3_Legacy/` | Retired `build.bat`/`package.bat`, stale `CNN.ini` (Glide-era), duplicate `Terrified.umx` |
| 4 | `Phase4_TextDup/` | Byte-identical duplicate of `CNNText/Text/` (was at `CNN/Text/`) |
| 5 | `Phase5_Orphans/` | 1 UC orphan (`BarrelBoomImportScript`), 2 UTX (`AIStalk`, `PFADTex`), 17 prefab sources, 2 utility `.exe` |
| 7 | `Phase7_ConvDup/` | 5 byte-identical conversation duplicates from `CNNText/Conversations/` + `CNNTextConversations.uc` importer |

---

## 8. Key entry points (load-bearing files)

| Role | File |
|---|---|
| Game rules | [CNN/Classes/CNNGameInfo.uc](CNN/Classes/CNNGameInfo.uc) (referenced by `DefaultGame=CNN.CNNGameInfo` in `CNN.ini`) |
| Player class | [CNN/Classes/TantalusDenton.uc](CNN/Classes/TantalusDenton.uc) (extends `JCDentonMale`) |
| Production main menu | [CNN/Classes/CNNMenuMainTest.uc](CNN/Classes/CNNMenuMainTest.uc) → `ApocalypseInsideMenuSelectDifficulty` flow |
| Conversation playback | [CNN/Classes/AiConPlay.uc](CNN/Classes/AiConPlay.uc), [CNN/Classes/CASConPlay.uc](CNN/Classes/CASConPlay.uc) |
| Quest tracking | [CNN/Classes/QuestSystem.uc](CNN/Classes/QuestSystem.uc) |
| Skill system | [CNN/Classes/AiSkillManager.uc](CNN/Classes/AiSkillManager.uc) |
| Augmentation system | [CNN/Classes/AiAugmentationManager.uc](CNN/Classes/AiAugmentationManager.uc) |
| HUD root | [CNN/Classes/CNNHUD.uc](CNN/Classes/CNNHUD.uc), [CNN/Classes/CNNRootWindow.uc](CNN/Classes/CNNRootWindow.uc) |
| Conversation imports | [CNN/Classes/ImportConversations.uc](CNN/Classes/ImportConversations.uc) (canonical after Phase 7) |
| Sound imports | [CNN/Classes/ImportSounds.uc](CNN/Classes/ImportSounds.uc) |
| Forced asset embedding | [CNN/Classes/AllCnnResources.uc](CNN/Classes/AllCnnResources.uc) (`#forceexec MESH IMPORT`, `#forceexec TEXTURE IMPORT`) |
| Text imports | [CNNText/Classes/CNNTextImport.uc](CNNText/Classes/CNNTextImport.uc) |
| Active runtime config | `System/CNN.ini` (Phase 3C made this canonical) |

---

## 9. Build pipeline cross-reference

Each `cnn.bat` subcommand and what it reads/writes:

| Subcommand | Reads | Writes |
|---|---|---|
| `setup` | Registry (Deus Ex root), repo files | Junctions in `<DeusExRoot>`, copied DLLs, edited `.ini` files |
| `compile` | `CNN/Classes/*.uc`, `CNN/Conversations/*.con`, `CNN/Audio/*.wav`, `CNNText/Classes/*.uc`, `CNNText/Text/*.txt`, SDK `ucc.exe` | `System/*.u` (CNN.u, CNNText.u, CNNAudio*.u) |
| `package` | `System/*.u`, `Maps/*.dx`, `Textures/*.utx`, `Music/*`, `tools/*.ps1`, `CNNInstallUtil.sln` | [CodenameNebula/](CodenameNebula/) staging — generated launcher, packaged `CNNInstallUtil.exe`, copied assets |
| `installer` | `CodenameNebula/`, `CNNInstaller/CNNSetup.iss`, `version.txt` | `Build/CodenameNebula_v<version>.exe`, `Build/CNNSetup.generated.iss` |
| `install` | `CodenameNebula/`, player's `DeusEx.ini`, `tools/generate_cnn_ini.ps1` | `<DeusExRoot>/CodenameNebula/` (mod copy), generated `CNN.ini`/`CNNUser.ini` |
| `test` | `<DeusExRoot>/CodenameNebula/`, `DeusEx.exe` | Running game (renamed `CodenameNebula.exe` to bypass Steam hook) |
| `steam` | Same as `test` plus Steam registry, `tools/steam_launch.ps1` | Running game via `steam://` protocol |
| `reset` | Player's `DeusEx.ini`, `tools/generate_cnn_ini.ps1` | Regenerated `CNN.ini`/`CNNUser.ini` (with `.bak` of old) |
| `clean` | (nothing) | Deletes `System/*.u` and `<DeusExRoot>/CodenameNebula/System/*.u` |
| `bump` | `version.txt` | Updated `version.txt` |
| `version` | `version.txt` | (prints to stdout) |
| `hd` | Registry (NewVision/HDTP), `System/CNN.ini`, `tools/inject_hd_paths.ps1` | Updated `System/CNN.ini` with HD `Paths=` lines |
| `renderer` | `System/CNN.ini` | Updated `GameRenderDevice=` line |
| `all` | (chains compile + package + installer) | Build/CodenameNebula_v<version>.exe |

---

## 10. Common edit checklists

### Adding a new conversation
1. Create `.con` file in `CNN/Conversations/X.con` via ConEdit
2. Add `#exec CONVERSATION IMPORT FILE="Conversations\X.Con"` to [CNN/Classes/ImportConversations.uc](CNN/Classes/ImportConversations.uc)
3. Add `.wav` audio files in `CNN/Audio/Chapter0X/<character>/`
4. Verify all NPC class names referenced inside the `.con` exist in `CNN/Classes/`
5. `cnn compile && cnn package && cnn install && cnn test`

### Adding a new map
1. Save `.dx` file to `Maps/`
2. Add filename to whitelist in [cnn.bat:364](cnn.bat#L364) (the `for %%f in (...)` list)
3. Verify all referenced classes/textures exist (open in UnrealEd, check property panel)
4. `cnn compile && cnn package && cnn install && cnn test`

### Adding a new texture package
1. Drop `.utx` in [Textures/](Textures/) — `cnn package` copies all `Textures/*.utx` automatically (no whitelist)
2. Reference from UC `defaultproperties` (`Texture=PkgName.Group.Name`) or place in a map
3. `cnn compile && cnn package && cnn install`

### Adding a new UnrealScript class
1. Create `CNN/Classes/X.uc` (or `CNNText/Classes/X.uc`) — filename must match class name exactly
2. Auto-picked up by `EditPackages=CNN`/`EditPackages=CNNText` in the SDK's DeusEx.ini
3. `cnn compile`

### Adding a new datacube/text file
1. Create `CNNText/Text/missionXX/X.txt`
2. Add `#exec DEUSEXTEXT IMPORT FILE=text\missionXX\X.txt` to [CNNText/Classes/CNNTextImport.uc](CNNText/Classes/CNNTextImport.uc)
3. Reference at runtime via `Level.GetTextEntry("X")` or matching property
4. `cnn compile && cnn package`

### Verifying changes won't break the build
After any source change, the safety chain is:
1. `cnn compile` — catches UnrealScript errors and missing-class references
2. `cnn package` — catches missing/renamed asset paths
3. `cnn installer` — catches Inno Setup script issues
4. `cnn test` — catches runtime issues (load order, renderer, conversation flow)

---

*Last updated: 2026-04-25, branch `chore/repo-cleanup`. Update this file whenever a load-bearing path changes (new build subcommand, restructured directory, new entry point).*
