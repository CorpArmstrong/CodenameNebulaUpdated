# _Backups — repository quarantine

This folder holds files and directories that were removed from the active parts of the repository during cleanup work, but were **not** deleted outright. Everything here is preserved in git history and can be restored with a `git mv` back to its original location.

## Rules

1. **Nothing under `_Backups/` is referenced by the build or runtime.**
   - Not in `.ini` `Paths=` lines
   - Not in `cnn.bat`, `package.bat`, Inno Setup scripts, or any compiler input
   - Unreal's wildcard `Paths=` directives only match the listed directory (no recursion), so files here are invisible to the engine.
2. **Folders are grouped by cleanup phase** (`Phase2_OldMaps/`, `Phase2_Backups/`, etc.) so the provenance of every move is traceable via git log on the phase folder.
3. **To restore a file**, `git mv _Backups/PhaseX_Name/path/to/file.ext original/path/to/file.ext` and commit.
4. **Before deleting anything from here**, confirm via a final audit pass that no maps, scripts, or configs reference the filenames inside.

## Phases recorded here

| Phase | Folder | What & why |
|-------|--------|-----------|
| 2 | `Phase2_Backups/BackupConv/` | Backup copies of `.con` conversation files. Git is the authoritative history now. |
| 2 | `Phase2_OldMaps/OldMaps/` | Historical map iterations (WIP versions of Ophelia maps, test variants, `.t3d` prefabs). Not referenced by any active map list. |
| 2 | `Phase2_OldMaps/DeusEx.ini` | Vestigial Deus Ex config (Glide renderer, vanilla `JCDentonMale` player class) — unrelated to the mod's active `CNN.ini`. |
| 3 | `Phase3_Legacy/build.bat` | Dead 6-byte script containing only `dir /w`. Superseded by root `cnn.bat`. |
| 3 | `Phase3_Legacy/package.bat` | Legacy in-folder packaging script. Superseded by `cnn.bat package`; no other script references it. |
| 3 | `Phase3_Legacy/Terrified.umx` | Byte-identical duplicate of `Music/Terrified.umx` at repo root. Distribution copy that the build script regenerates anyway. |
| 3 | `Phase3_Legacy/CNN.ini.stale-2026-04-04` | Stale fallback config — zero build pipeline references. Canonical is `System/CNN.ini`. This copy had the Glide renderer, 640×480 resolution, and paths pointing at unrelated mods (`New Vision`, `fgrhk`). Date suffix records when it was last modified. |
| 4 | `Phase4_TextDup/Text/` | Pure dead duplicate of `CNNText/Text/` (25 files, all byte-identical). `CNN/Text/` had zero references; `CNNText/Text/` is the canonical location imported by `CNNText/Classes/CNNTextImport.uc` into `CNNText.u`. |
| 5 | `Phase5_Orphans/UC_Core/` | **1 true UC orphan:** BarrelBoomImportScript.uc. Zero refs in any `.uc`, `.dx` map, `.con` conversation, or config. The initial audit flagged 12 classes as orphan but only this one survived the full cross-check — see `Phase5_6_Audit.md` for the blind spots that caused the over-claim. |
| 5 | `Phase5_Orphans/UTX/` | 2 orphan texture packages: AIStalk.utx (4.2 MB), PFADTex.utx (5.8 MB). Zero references in UC code OR any `.dx` map (cross-checked). The other 5 packages initially flagged as orphans by the UC-only scan are actually used by maps — see `Phase5_6_Audit.md`. |
| 5 | `Phase5_Orphans/Prefabs/` | 17 orphan prefab/model source files (`.t3d`, `.u3d`, `.mtl`, `.obj`) in `Maps/`. None appear in the name table of any shipped `.dx` map or in UC code — they were imported as prefabs into earlier map iterations that were since scrapped. |
| 5 | `Phase5_Orphans/Utilities/` | 2 utility executables misfiled in asset folders: `MPMaps.exe` (multiplayer map tool, was in `Maps/`) and `TextureFiles.exe` (40.7 MB texture tool, was in `Textures/`). Not part of the mod build or runtime. |
| 7 | `Phase7_ConvDup/Conversations/` | 5 byte-identical conversation duplicates from `CNNText/Conversations/` (MoonCNN, OpheliaDocksAndL1, OpheliaL2, DL_Moon, OpheliaL2ArmMagdalene). The `CNN/Conversations/` tree is the canonical complete set (it includes `Chapter06.con` which CNNText was missing). Half-completed migration — both importers were compiling the same data into both `CNN.u` and `CNNText.u`. |
| 7 | `Phase7_ConvDup/Classes/CNNTextConversations.uc` | Importer class for the duplicated conversations. Removed so `CNNText.u` no longer carries duplicate conversation data; `CNNText.u` is now purely text content (datacubes, books, bulletins) — matching its name. |
| 10 | `Phase10_DeadClasses/CNNCreditsWindowTest.uc` | Dead alternate-credits class extending `CreditsScrollWindow`. Zero references in UC code, `.dx` maps, or configs. Looks like an in-progress experiment that was never wired up. |
