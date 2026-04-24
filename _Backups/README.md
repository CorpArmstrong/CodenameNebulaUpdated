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
