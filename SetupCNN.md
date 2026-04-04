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

## Step 8: Compile

From `<DeusExRoot>\System\`:
```cmd
ucc.exe make
```

This produces:
- **CNN.u** — main game logic (from `CNN\Classes\*.uc`)
- **CNNText.u** — conversations and text content (from `CNNText\Classes\*.uc` importing `.con` files)
- **CNNAudioCNN.u**, **CNNAudioChapter05.u**, **CNNAudioChapter06.u** — conversation audio

## Step 9: Deploy Compiled Packages

Copy to the Community Update editor folder:
```cmd
copy "<DeusExRoot>\System\CNN.u" "<DeusExRoot>\Mods\Community Update\System\"
copy "<DeusExRoot>\System\CNNText.u" "<DeusExRoot>\Mods\Community Update\System\"
copy "<DeusExRoot>\System\CNNAudio*.u" "<DeusExRoot>\Mods\Community Update\System\"
copy "<DeusExRoot>\System\GaussGun.u" "<DeusExRoot>\Mods\Community Update\System\"
copy "<DeusExRoot>\System\DXOgg.dll" "<DeusExRoot>\Mods\Community Update\System\"
copy "<DeusExRoot>\System\DXOgg.u" "<DeusExRoot>\Mods\Community Update\System\"
```

Copy compiled packages back to the repo:
```cmd
copy "<DeusExRoot>\System\CNN.u" "<repo>\System\"
copy "<DeusExRoot>\System\CNNText.u" "<repo>\System\"
copy "<DeusExRoot>\System\CNNAudio*.u" "<repo>\System\"
```

## Step 10: Verify

1. Launch the Community Update editor: `<DeusExRoot>\Mods\Community Update\System\UnrealEd.exe`
2. File > Open — navigate to `CNNMaps` folder, open `06_OpheliaL1.dx`
3. Press Play Level — map should load with conversations working

## Known Pitfalls

- **Never replace Steam's `Core.dll`** with the SDK version — it silently kills conversation imports
- **UnrealEd 2.2 (UED22)** is incompatible with CNN — its stripped `.u` packages are missing Deus Ex functions and engine versions are binary-incompatible
- **Original SDK editor** (`System\UnrealEd.exe`) freezes on large maps and crashes on empty-space click — use the Community Update editor instead
- **Path length limit** — always open maps via the `CNNMaps` junction, not the full `CodenameNebulaUpdated\Maps\` path
- **Kentie's D3D10 renderer** causes crashes in the original editor — avoid it
