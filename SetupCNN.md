# Codename Nebula — Dev Environment Setup from Scratch

## Step 1: Install Deus Ex GOTY (Steam)

Install **Deus Ex: Game of the Year Edition** from Steam. The Steam version is already on patch v1112fm. Note the install path (e.g. `D:\Program Files (x86)\Steam\steamapps\common\Deus Ex`).

> In this guide, `<DeusExRoot>` refers to the Steam install path, e.g. `D:\Program Files (x86)\Steam\steamapps\common\Deus Ex`

## Step 2: Install the Deus Ex SDK v1112fm

Download: [SDK v1112fm — ModDB](https://www.moddb.com/games/deus-ex/downloads/sdk-v1112fm)

**Run `Setup.exe`** (don't just extract files) and point it at your Deus Ex directory. The installer registers components needed for conversation compilation. It provides `ucc.exe`, ConEdit, and UnrealEd.

> **Critical:** Do NOT replace the Steam `Core.dll` with the SDK's version. The Steam GOTY `Core.dll` is required for `#exec CONVERSATION IMPORT` to work. The SDK's `Core.dll` silently breaks conversation compilation.

## Step 3: Install the Deus Ex Community Update

Download: [Community Update v2.4.1 — ModDB](https://www.moddb.com/mods/deus-ex-community-update/downloads/deus-ex-community-update-version-241)

Install to the Deus Ex root. This provides a patched editor at `Mods\Community Update\System\UnrealEd.exe` that can handle large CNN maps without freezing.

After installation, create `DeusEx.exe` (the editor's "Play Level" needs it):
```cmd
copy "Mods\Community Update\System\Deus Ex Community Update.exe" "Mods\Community Update\System\DeusEx.exe"
```

## Step 4: Clone the Repo and Create Junctions

Clone the Codename Nebula repo to any location, then create directory junctions from the Deus Ex root:

```cmd
mklink /J "<DeusExRoot>\CodenameNebulaUpdated" "<path-to-repo>"
mklink /J "<DeusExRoot>\CNN" "<path-to-repo>\CNN"
mklink /J "<DeusExRoot>\CNNText" "<path-to-repo>\CNNText"
mklink /J "<DeusExRoot>\CNNMaps" "<path-to-repo>\Maps"
```

What each junction does:
- **CodenameNebulaUpdated** — main repo access for the engine (textures, sounds, music, maps)
- **CNN** — required for `ucc make` to find UnrealScript source files in `CNN\Classes\`
- **CNNText** — required for `ucc make` to compile the conversation/text package
- **CNNMaps** — short path for the editor (UnrealEd 1.x truncates long file paths)

## Step 5: Copy Runtime Dependencies

Copy DLLs to `<DeusExRoot>\System\`:
```cmd
copy "<repo>\System\DXOgg.dll" "<DeusExRoot>\System\"
copy "<repo>\CNN\System\RenderExt.dll" "<DeusExRoot>\System\"
```

Copy precompiled dependency packages to `<DeusExRoot>\System\`:
```cmd
copy "<repo>\System\GaussGun.u" "<DeusExRoot>\System\"
copy "<repo>\System\DXOgg.u" "<DeusExRoot>\System\"
copy "<repo>\System\DXRVNewVehicles.u" "<DeusExRoot>\System\"
copy "<repo>\System\PFAD.u" "<DeusExRoot>\System\"
```

## Step 6: Configure `<DeusExRoot>\System\DeusEx.ini`

Used by the SDK compiler (`ucc make`).

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

## Step 7: Configure `<DeusExRoot>\Mods\Community Update\System\DeusEx.ini`

Used by the Community Update editor (the primary editor for CNN development).

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

## Step 8: Build Tool

The repo includes `cnn.bat` — a build tool that auto-detects all paths (Steam, GOG, CD installs via registry). No hardcoded paths.

```cmd
cnn setup       First-time setup (junctions, DLLs, INI config)
cnn compile     Compile UnrealScript packages
cnn package     Copy assets into distribution folder
cnn installer   Build Inno Setup installer
cnn install     Deploy mod to local Deus Ex for testing
cnn test        Launch the mod
cnn clean       Remove compiled packages
cnn bump        Increment version (patch/minor/major)
cnn all         compile + package + installer
```

If Deus Ex is not auto-detected, the tool prompts for the path and saves it to `cnn.local.bat`.

## Step 9: Compile and Build

```cmd
cnn all
```

This compiles (`CNN.u`, `CNNText.u`, audio packages), packages distribution files, and builds the Inno Setup installer at `Build/CodenameNebula_v<version>.exe`.

## Step 10: Launch the Mod

```cmd
cnn test
```

This creates `CodenameNebula.exe` (a renamed copy of the original 1112fm `DeusEx.exe`) in `<DeusExRoot>\System\` and launches it with the CNN ini files. The rename is required because **Steam intercepts `DeusEx.exe`** by name and strips command-line arguments.

## Step 11: Verify

1. `cnn compile` — should produce CNN.u and CNNText.u with 0 errors
2. `cnn test` — mod should launch with the CNN main menu
3. Community Update editor > open a CNN map > Play Level — conversations should work

## Known Pitfalls

- **Steam intercepts `DeusEx.exe`** — always use `CodenameNebula.exe` (renamed copy). `cnn test` handles this.
- **Renderer:** `CNN.ini` must use `OpenGlDrv.OpenGLRenderDevice`. D3D9 from Community Update is incompatible with the original 1112fm exe.
- **Never replace Steam's `Core.dll`** with the SDK version — it silently kills conversation imports
- **UnrealEd 2.2 (UED22)** is incompatible with CNN — its stripped `.u` packages are missing Deus Ex functions and engine versions are binary-incompatible
- **Original SDK editor** (`System\UnrealEd.exe`) freezes on large maps and crashes on empty-space click — use the Community Update editor instead
- **Path length limit** — always open maps via the `CNNMaps` junction, not the full `CodenameNebulaUpdated\Maps\` path
- **Kentie's D3D10 renderer** causes crashes in the original editor — avoid it
