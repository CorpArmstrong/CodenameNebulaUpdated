# Phase 8 — `ApocalypseInside.u` Dependency Survey

**Date:** 2026-04-25
**Branch:** `chore/repo-cleanup`
**Goal:** Make CNN a fully standalone mod, independent of the parent `ApocalypseInside.u` package.

This document is a snapshot of every reference from CNN to the external `ApocalypseInside` package, the path to fixing each, and the work split into stages by required tooling.

---

## Background

CNN was originally part of a parent mod called "Apocalypse Inside" and was separated in commit `a5b02b9` ("CNN is now separate from Apocalypse Inside"). The split moved most asset source files (`.3d` meshes, `.pcx` textures) into [CNN/Models/](CNN/Models/) and added `#exec MESH IMPORT` stub classes in [CNN/Classes/](CNN/Classes/), but the `defaultproperties` references in the actor classes were never updated — they still point at `'ApocalypseInside.X'`.

This means CNN's compiled `CNN.u` package contains duplicate mesh data (everything in `CNN/Models/` is embedded into `CNN.u`) AND the runtime still loads the same meshes from `ApocalypseInside.u` when actors spawn — making `ApocalypseInside.u` a hidden runtime dependency.

---

## Survey results

### Total scope

- **18 `.uc` files** with 39 individual `'ApocalypseInside.X'` references
- **3 `.dx` maps** with embedded references in their binary name tables: `06_Conspiracy.dx`, `06_Hijacking.dx`, `06_Transcend.dx` (1 hit each)

### Reference categorization

#### A. Local equivalent already exists (mesh + import stub) — 11 unique assets

These can be fixed by simple text find/replace in the actor classes:

| External ref | CNN-local source files | CNN import class | Actor class(es) using ext ref |
|---|---|---|---|
| `ApocalypseInside.bassein` | `CNN/Models/bassein_a.3d`, `_d.3d`, `.pcx` | [Bassein.uc](CNN/Classes/Bassein.uc) | [BassGuitar.uc:39](CNN/Classes/BassGuitar.uc#L39), [Bassein.uc:28](CNN/Classes/Bassein.uc#L28) |
| `ApocalypseInside.CoffeeCup` | `CNN/Models/CoffeeCup_a.3d`, `_a.pcx`, `_d.3d` | [CoffeeCup.uc](CNN/Classes/CoffeeCup.uc) | [CoffeeCup.uc:69-80](CNN/Classes/CoffeeCup.uc#L69) (4 refs: PlayerView, PickupView, ThirdPerson, Mesh) |
| `ApocalypseInside.CoffeeMachine` | `CNN/Models/CoffeeMachine_a.3d`, `_a.pcx`, `_b.pcx`, `_d.3d` | [CoffeeMachine.uc](CNN/Classes/CoffeeMachine.uc) | [CoffeeMachine.uc:63](CNN/Classes/CoffeeMachine.uc#L63) |
| `ApocalypseInside.ObserX` | `CNN/Models/ObserX_a.3d`, `.pcx`, `_d.3d` | [ObserX.uc](CNN/Classes/ObserX.uc) | [ObserX.uc:26](CNN/Classes/ObserX.uc#L26) |
| `ApocalypseInside.Pallet` | `CNN/Models/Pallet_a.3d`, `_d.3d` | [Pallet.uc](CNN/Classes/Pallet.uc) | [pallet.uc:11](CNN/Classes/pallet.uc#L11) |
| `ApocalypseInside.Pipe619` | `CNN/Models/Pipe619_a.3d`, `_d.3d` | [Pipe619.uc](CNN/Classes/Pipe619.uc) | [Pipe619.uc:26](CNN/Classes/Pipe619.uc#L26) |
| `ApocalypseInside.Pipe994` | `CNN/Models/Pipe994_a.3d`, `_d.3d` | [Pipe994.uc](CNN/Classes/Pipe994.uc) | [Pipe994.uc:26](CNN/Classes/Pipe994.uc#L26) |
| `ApocalypseInside.Pipe996` | `CNN/Models/Pipe996_a.3d`, `_d.3d` | [Pipe996.uc](CNN/Classes/Pipe996.uc) | [Pipe996.uc:26](CNN/Classes/Pipe996.uc#L26) |
| `ApocalypseInside.Pipe998` | `CNN/Models/Pipe998_a.3d`, `_d.3d` | [Pipe998.uc](CNN/Classes/Pipe998.uc) | [Pipe998.uc:26](CNN/Classes/Pipe998.uc#L26) |
| `ApocalypseInside.scart4598` | `CNN/Models/scart4598_a.3d`, `_d.3d`, `.pcx` | [scart4598.uc](CNN/Classes/scart4598.uc) | [ShopCart.uc:73](CNN/Classes/ShopCart.uc#L73) |
| `ApocalypseInside.wallfuse8` | `CNN/Models/wallfuse8_a.3d`, `_d.3d`, `.pcx` | [wallfuse8.uc](CNN/Classes/wallfuse8.uc) | [wallfuse8.uc:26](CNN/Classes/wallfuse8.uc#L26) |

**Action:** simple textual find/replace `'ApocalypseInside.X'` → `'CNN.X'` in the listed actor files.

#### B. Mesh missing — must be extracted from `ApocalypseInside.u` (2 unique meshes)

| External ref | Used by | Status |
|---|---|---|
| `ApocalypseInside.Burger01` | [Burger.uc:40-49](CNN/Classes/Burger.uc#L40) (4 refs) | No `Burger01_*` files in `CNN/Models/`, no import stub |
| `ApocalypseInside.fries01` | [Fries.uc:40-49](CNN/Classes/Fries.uc#L40) (4 refs) | No `fries01_*` files, no import stub |

**Action:** open `ApocalypseInside.u` in UnrealEd → mesh browser → export Burger01 and fries01 to `.3d`/`.pcx` files → drop into `CNN/Models/` → create import stubs `CNN/Classes/Burger01.uc` and `CNN/Classes/fries01.uc` (use `scart4598.uc` as a template).

#### C. Textures missing — none have local equivalents (15 unique textures)

| External ref | Used by | Group |
|---|---|---|
| `ApocalypseInside.Skins.bassein` | [Bassein.uc:27](CNN/Classes/Bassein.uc#L27) | Skins |
| `ApocalypseInside.Skins.NoodleCupTex0` | [NoodleCup.uc:52](CNN/Classes/NoodleCup.uc#L52) | Skins |
| `ApocalypseInside.mea1` | [WebAccessPoint.uc:8](CNN/Classes/WebAccessPoint.uc#L8) | (root) |
| `ApocalypseInside.mea2` | [IoTterminal.uc:94](CNN/Classes/IoTterminal.uc#L94) | (root) |
| `ApocalypseInside.mea3` | [ZeroClient.uc:15](CNN/Classes/ZeroClient.uc#L15) | (root) |
| `ApocalypseInside.Icons.BeltIconBurger` | [Burger.uc:43](CNN/Classes/Burger.uc#L43) | Icons |
| `ApocalypseInside.Icons.LargeIconBurger` | [Burger.uc:44](CNN/Classes/Burger.uc#L44) | Icons |
| `ApocalypseInside.Icons.BeltIconCoffeeCup` | [CoffeeCup.uc:73](CNN/Classes/CoffeeCup.uc#L73) | Icons |
| `ApocalypseInside.Icons.LargeIconCoffeeCup` | [CoffeeCup.uc:74](CNN/Classes/CoffeeCup.uc#L74) | Icons |
| `ApocalypseInside.Icons.BeltIconFries` | [Fries.uc:43](CNN/Classes/Fries.uc#L43) | Icons |
| `ApocalypseInside.Icons.LargeIconFries` | [Fries.uc:44](CNN/Classes/Fries.uc#L44) | Icons |
| `ApocalypseInside.Icons.BeltIconNoodleCup` | [NoodleCup.uc:45](CNN/Classes/NoodleCup.uc#L45) | Icons |
| `ApocalypseInside.Icons.LargeIconNoodleCup` | [NoodleCup.uc:46](CNN/Classes/NoodleCup.uc#L46) | Icons |

**Action:** open `ApocalypseInside.u` in UnrealEd → texture browser → export each texture to `.pcx` (or `.bmp`) preserving group structure (`Skins/`, `Icons/`) → drop into `CNN/Models/` (or a dedicated import folder) → add `#exec TEXTURE IMPORT` directives in a CNN-side import class. Either extend [AllCnnResources.uc](CNN/Classes/AllCnnResources.uc) or create a new dedicated importer.

#### D. Embedded in `.dx` map binaries (3 maps)

`grep -ao "ApocalypseInside" Maps/*.dx` shows:
- `06_Conspiracy.dx`: 1 hit
- `06_Hijacking.dx`: 1 hit
- `06_Transcend.dx`: 1 hit

These are likely single actor placements that hardcode an `ApocalypseInside` mesh/texture reference in the map's name table. Cannot be fixed by text edit — must open each map in UnrealEd, find the offending actor (texture browser will flag missing references when loaded without `ApocalypseInside.u`), re-point its `Mesh=` / `Texture=` property to the CNN-local equivalent, and re-save the map.

#### E. False positives (these are FINE — no action)

The grep also matches CNN-internal class names that happen to contain "ApocalypseInside" as a string. These are CNN classes, not external package references:

- `ApocalypseInsideFragment` — CNN class, parent of `AiGlassFragment`/`AiMetalFragment`
- `ApocalypseInsideMenuMain`, `MenuSelectDifficulty`, `MenuScreenNewGame`, `MenuStartNewGame`, `ApocalypseInsideText` — CNN classes (the production main-menu chain entered from `CNNMenuMainTest.StartNewGame()`)
- The function `ApocalypseInsideGo()` in `ApocalypseInsideMenuStartNewGame.uc` — internal function name
- An inline comment in [TantalusDenton.uc:160](CNN/Classes/TantalusDenton.uc#L160) noting that the override exists so the custom `ApocalypseInsideMenu` chain can be used

These can stay or be renamed for cosmetic clarity (e.g., drop the "ApocalypseInside" prefix on the menu chain), but they don't block the standalone goal.

---

## Path to standalone — staged plan

| Stage | Work | Tooling | Estimated effort | Risk |
|---|---|---|---|---|
| **8A — Mechanical refactor** | Update 12 `.uc` files to reference `CNN.X` instead of `ApocalypseInside.X` for the 11 already-imported meshes (category A above). 15 individual line edits. | Terminal (Edit/sed) | 30 min | Low — `cnn compile` + runtime test catches regressions |
| **8B — Asset extraction** | Export Burger01, fries01 meshes and all 13 missing textures from `ApocalypseInside.u`. Drop files into `CNN/Models/`. Create import stubs (or add `#exec TEXTURE IMPORT` to `AllCnnResources.uc`). Update Burger.uc, Fries.uc, NoodleCup.uc, WebAccessPoint.uc, IoTterminal.uc, ZeroClient.uc, Bassein.uc to reference local. | UnrealEd + terminal | 2-3 hours | Low — same import pattern as scart4598 |
| **8C — Map fixes** | Open 06_Conspiracy.dx, 06_Hijacking.dx, 06_Transcend.dx in UnrealEd. Identify the 1 actor in each that references `ApocalypseInside.X`. Re-point to CNN-local equivalent. Save. | UnrealEd | 30-45 min | Medium — UnrealEd 1.x can corrupt large maps; backup before saving |
| **8D — Verification** | Temporarily rename `ApocalypseInside.u` on dev machine to force runtime to fall back to CNN-local copies. `cnn test` and traverse all production maps, paying attention to bassein/burger/fries/coffee/noodle/observer/pallet/pipes/shopping cart/wall fuse rendering. Any pink-checkerboard or missing-mesh placeholders identifies a missed reference. | UnrealEd or in-game | 30 min | None — read-only verification |

---

## Recommended execution order

1. **8A first** — quickest, validates the pattern, establishes ~half the dependency removal with zero editor work.
2. **8B textures + 8B meshes** — second; once these are imported, asset coverage is complete.
3. **8C** — last among the editing stages; the maps will compile against either external or local refs as long as the named asset exists somewhere.
4. **8D** — once 8A+B+C land, run verification.

---

## Notes for future maintenance

- **Naming convention:** prefer lowercase asset names matching the `.3d`/`.pcx` filenames to avoid case-mismatch confusion (the existing tree mixes `Bassein.uc` with `bassein` mesh names — Windows is case-insensitive but the engine's package system can be picky).
- **Import-stub template:** [scart4598.uc](CNN/Classes/scart4598.uc) is a clean reference pattern for a mesh import stub — duplicate it, change the mesh name, point at the right model files.
- **Double-imports avoided:** removing the `ApocalypseInside.X` references from CNN should reduce package coupling but won't shrink `CNN.u` (the meshes are already embedded via `#exec` in the existing import stubs). The size win comes from no longer needing `ApocalypseInside.u` to be on the Paths= list at runtime.
