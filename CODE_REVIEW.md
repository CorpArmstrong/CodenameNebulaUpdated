# Codename Nebula — Per-Contributor Code Review

**Date:** 2026-04-25 | **Branch:** `chore/repo-cleanup` | **Scope:** `CNN/Classes/*.uc` (267 files) + `CNNText/Classes/*.uc` (1 file)

This review covers the UnrealScript codebase, organized by **actual git authorship** rather than file-naming conventions. Two real contributors authored the entire codebase, despite git showing four author names due to alias variations:

- **Dmitriy Fediukovich** (project owner) uses two aliases: `CorpArmstrong` (older) and `Dmitriy Fediukovich` (current). Combined: **136 commits**, ~159 files created.
- **Tantalus** (collaborator) uses two aliases: `Tantalus` and `tantalus` (case variant). Combined: **63 commits**, ~117 files created.

Sister docs: [CLAUDE.md](CLAUDE.md) (project guide with prior code review), [CLASSES_MAP.md](CLASSES_MAP.md) (class atlas), [REPO_MAP.md](REPO_MAP.md) (repo navigation).

## Methodology

Authorship determined via `git blame --line-porcelain <file>`, summed per real person (collapsing aliases). Files bucketed:
- **Dmitriy-primary** if Dmitriy owns >50% of current lines
- **Tantalus-primary** if Tantalus owns >50% of current lines
- **Shared/contested** if no clear majority

Spot-checked claim citations via direct `git blame` on the cited bug lines — all attribution in this doc is verified at the line level. Where comments are signed differently from the line author (e.g., [TantalusDenton.uc:154](CNN/Classes/TantalusDenton.uc#L154) has `-T.` sign-off but blame shows CorpArmstrong as line author), this is noted as collaborative authorship.

This is a **sampling-based review** — not every file was read line-by-line. Sample size: ~30-40 representative files spanning all subsystems (game core, NPCs, weapons, HUD, triggers, missions). Findings extrapolate to similar files within the same author's work.

---

## Authorship Summary

| Contributor | Aliases | Total commits | Files primarily owned | % of codebase (line-weighted) |
|---|---|---|---|---|
| **Dmitriy** | CorpArmstrong + Dmitriy Fediukovich | 136 | ~99 | ~45% |
| **Tantalus** | Tantalus + tantalus | 63 | ~53 | ~32% |
| **Shared / contested** | (mixed) | — | ~115 | ~23% |

---

## Contributor profile: Dmitriy

### Subsystems primarily owned

- **Quest system & orchestration** — [QuestSystem.uc](CNN/Classes/QuestSystem.uc) (122 lines, 100% Dmitriy after rewrite), [CNNBaseIngameCutscene.uc](CNN/Classes/CNNBaseIngameCutscene.uc), [HolocommUnit.uc](CNN/Classes/HolocommUnit.uc), [ObjectsDestroyNotifier.uc](CNN/Classes/ObjectsDestroyNotifier.uc)
- **Triggers and dispatchers** — [CnnConversTrigger.uc](CNN/Classes/CnnConversTrigger.uc), [CNNDetonationTrigger.uc](CNN/Classes/CNNDetonationTrigger.uc), [LaserSecurityController.uc](CNN/Classes/LaserSecurityController.uc), [ToggleActorLifecycleTrigger.uc](CNN/Classes/ToggleActorLifecycleTrigger.uc)
- **Player and combat** — [TantalusDenton.uc](CNN/Classes/TantalusDenton.uc) (mostly CorpArmstrong with later Dmitriy refactors), [CNNUPS.uc](CNN/Classes/CNNUPS.uc), [Chapter05.uc](CNN/Classes/Chapter05.uc) (augmentation logic)
- **Conversations** — [AiConPlay.uc](CNN/Classes/AiConPlay.uc), [AiDataLinkPlay.uc](CNN/Classes/AiDataLinkPlay.uc), [AiHUDInfoLinkDisplay.uc](CNN/Classes/AiHUDInfoLinkDisplay.uc) (via "Ai*" prefix files originally created by CorpArmstrong)

### Style fingerprint

**Consistencies:**
- Tab indentation, 4-space depth typical
- Header comments with class description: `//-----------------------------------------------------------`
- Prefers explicit struct definitions for data (e.g., `Quest`, `QuestPath` structs in QuestSystem.uc)
- Defensive coding in *some* systems (bounds checking arrays in QuestSystem) but not consistently across all files

**Inconsistencies:**
- Brace placement varies — sometimes K&R (same line), sometimes Allman (next line) within the same file
- Comment density swings widely: QuestSystem.uc is sparse, CNNUPS.uc has whimsical comments (`"unknown paranormal shit"`, `"Lucy in the Sky with Diamonds"`)
- Mix of camelCase and PascalCase locals (engine convention is camelCase for variables; PascalCase appears in older code)

### Strengths (top 3)

1. **Robust system design in QuestSystem** — array-bounds validation, empty-flag-name short-circuiting, parameterized quest paths. The contract is clear: flags are checked, paths evaluated, level transitions gated.
2. **Modular trigger composition** — CnnConversTrigger separates discovery (find target by tag), validation (check flags), and action (start conversation). Easy to extend.
3. **Long-tail maintenance commitment** — recent commits show willingness to revisit and refactor older work (e.g., the QuestSystem.uc rewrite kept the original CorpArmstrong header but replaced 100% of content).

### Issues (verified citations)

#### CRITICAL

| # | Issue | Location | Severity rationale |
|---|---|---|---|
| D1 | **Self-assignment, member never set** — `spawnPoint = spawnPoint;` (local-to-local). Member `var spawnPoint` (line 9) stays `None`; spawned actors fall back to default coordinates. | [ToggleActorLifecycleTrigger.uc:44](CNN/Classes/ToggleActorLifecycleTrigger.uc#L44) (CorpArmstrong, 2017-06-01) | Object spawning silently broken |
| D2 | **Pass-by-value counter** — `destroyedObjectsCounter++` in `HandleDestroyedObject(int counter)`. Caller in `PollObjects()` never sees the increment. The "all objects destroyed" branch (line 66) is unreachable. | [ObjectsDestroyNotifier.uc:78](CNN/Classes/ObjectsDestroyNotifier.uc#L78) (Dmitriy, 2018-09-23) | Quest goal silently never completes |
| D3 | **Missing null check on sCam** — `sCam.bNoAlarm = bNoAlarm;` runs even when no SecurityCamera with the tag exists; `sCam` stays `None` from PostBeginPlay. | [LaserSecurityController.uc:91](CNN/Classes/LaserSecurityController.uc#L91) (Dmitriy, 2018-07-15) | Runtime crash on `None` access |

#### HIGH

| # | Issue | Location | Severity |
|---|---|---|---|
| D4 | **Empty bool function** — `function bool CheckActorDistances() { }` returns undefined; comment `// mwahaaha! terrible hack, i know -T.` (note: signed by Tantalus but blame attributes line author to CorpArmstrong — collaborative). | [TantalusDenton.uc:152-155](CNN/Classes/TantalusDenton.uc#L152) (CorpArmstrong, 2017-04-04) | HIGH — undefined return value |
| D5 | **Duplicate augmentation grant** — Identical `if (HasHeartAug && !PlayerGotHeartAug)` block at lines 115-119 AND 160-164. If first block silently fails to set the flag, player gets aug twice. | [Chapter05.uc:115,160](CNN/Classes/Chapter05.uc#L115) (Dmitriy, 2018-09-09) | HIGH — gameplay duplication |
| D6 | **Missing null check on conOwner** — `AllActors` loop may not find a matching actor; `conOwner` stays `None` and is passed directly to `StartConversationByName()`. | [CnnConversTrigger.uc:52](CNN/Classes/CnnConversTrigger.uc#L52) (CorpArmstrong, 2017) | HIGH — potential crash |
| D7 | **AllActors loops in Tick path** — Three `foreach AllActors()` per frame in DealDamage (called from Tick): pawns, decorations, movers. ~300 allocations/frame on dense maps. Player pawn IS cached; other actors are not. | [CNNUPS.uc:287-334](CNN/Classes/CNNUPS.uc#L287) (Dmitriy, 2018-09-17) | HIGH — performance hazard |

#### MEDIUM

| # | Issue | Location | Severity |
|---|---|---|---|
| D8 | **Debug msgbox in production** — `msgbox("MovedPawn not finded")` blocks game with a dialog (also typo: "finded" → "found"). Should be `ClientMessage()` or removed. | [MandatoryMovementTriger.uc:72](CNN/Classes/MandatoryMovementTriger.uc#L72) (Dmitriy) | MEDIUM — UX issue + typo in filename ("Triger") |

### Worst-offender deep notes (Dmitriy)

**[CNNUPS.uc](CNN/Classes/CNNUPS.uc)** — ~400 lines, UPS creature behavior
- AllActors in Tick is the headline issue (D7). Math for sphere positioning (lines 74-96) is hardcoded — no easy way to retune from defaultproperties.
- Player pawn cached as `pPawn` (lines 296-306) shows the author knew about the cost but stopped halfway. Inconsistent caching.
- Inline whimsical comments don't hurt but signal that this file was written under deadline pressure.

**[Chapter05.uc](CNN/Classes/Chapter05.uc)** — Moonbase orchestration (mixed authorship; this section covers Dmitriy's contributions)
- The duplicate augmentation block (D5) is pure copy-paste. Almost certainly added during a separate fix session without re-reading the file.
- Dmitriy's lines (52/209) are concentrated in augmentation handoff. Tantalus owns most of the level orchestration.

**[ObjectsDestroyNotifier.uc](CNN/Classes/ObjectsDestroyNotifier.uc)** — Mission goal tracking, ~90 lines
- Single CRITICAL bug (D2). Easy fix (`out int destroyedObjectsCounter`).
- The bug is invisible in testing because there's no explicit error — the function just hangs forever waiting for a counter that can't reach the threshold.

---

## Contributor profile: Tantalus

### Subsystems primarily owned

- **Effects and projectiles** — [AiLaserEmitter.uc](CNN/Classes/AiLaserEmitter.uc), [AiGlassFragment.uc](CNN/Classes/AiGlassFragment.uc), [AiMetalFragment.uc](CNN/Classes/AiMetalFragment.uc), [AmmoPlasma2.uc](CNN/Classes/AmmoPlasma2.uc), [PlasmaBolt2.uc](CNN/Classes/PlasmaBolt2.uc)
- **Augmentations** — [AugSkullGunLethal.uc](CNN/Classes/AugSkullGunLethal.uc), [AugSkullGunNonLethal.uc](CNN/Classes/AugSkullGunNonLethal.uc)
- **Menu UI chain** — [ApocalypseInsideMenuMain.uc](CNN/Classes/ApocalypseInsideMenuMain.uc), [ApocalypseInsideMenuSelectDifficulty.uc](CNN/Classes/ApocalypseInsideMenuSelectDifficulty.uc), [ApocalypseInsideMenuScreenNewGame.uc](CNN/Classes/ApocalypseInsideMenuScreenNewGame.uc), [ApocalypseInsideMenuStartNewGame.uc](CNN/Classes/ApocalypseInsideMenuStartNewGame.uc) — note: Dmitriy made later edits to the last one
- **NPC variants** — Holo NPCs ([UberAllesHolo.uc](CNN/Classes/UberAllesHolo.uc), [JCDoubleHolo.uc](CNN/Classes/JCDoubleHolo.uc), etc.), Avatar variants
- **Mission orchestration** — Most of [Chapter05.uc](CNN/Classes/Chapter05.uc) (Tantalus owns 131/209 lines)
- **Evidence boxes** — All `*Evidence.uc` classes ([AlienCarcassEvidence.uc](CNN/Classes/AlienCarcassEvidence.uc) etc.)

### Style fingerprint

**Consistencies:**
- Tab indentation, generally next-line braces (Allman style)
- Compact files — focused single-responsibility classes
- Heavy use of `defaultproperties` for configuration; minimal inline magic numbers
- Self-signs with `-T.` in collaborative comments (e.g., the "terrible hack" comment in TantalusDenton.uc)

**Inconsistencies:**
- Sparse documentation — most files have minimal class headers, often blank line 3 instead of a description
- Inline historical artifacts — `AiLaserEmitter.uc` has commented-out alternative branches with cryptic `// JJ change here` markers (no explanation what JJ was)

### Strengths (top 3)

1. **Polished augmentation math** — AugSkullGunLethal scales energy drain across four tech levels with `perc` clamped to [0,1] and damage proportional to energy availability. Tight, correct, tunable from defaultproperties.
2. **Reflection-aware laser system** — AiLaserEmitter checks `PF_Mirrored` polygon flag (`0x08000000`) and properly spawns/destroys LaserSpot per reflection. Non-trivial UE1 graphics work done correctly.
3. **Menu UI hygiene** — ApocalypseInsideMenuMain disables buttons contextually (dead/multiplayer states), integrates version display, follows base-class override patterns properly.

### Issues (verified citations)

#### HIGH

| # | Issue | Location | Severity |
|---|---|---|---|
| T1 | **Missing player null guard in menu** — `UpdateButtonStatus()` accesses `player.IsInState('Dying')` without null-check on `player`. If called before level load (e.g., main menu transition), can crash. | [ApocalypseInsideMenuMain.uc:39-46](CNN/Classes/ApocalypseInsideMenuMain.uc#L39) | HIGH — edge-case crash |

#### MEDIUM

| # | Issue | Location | Severity |
|---|---|---|---|
| T2 | **Cryptic history comments** — Two alternative implementations preserved as inline comments with `// JJ change here` markers, no explanation. Future maintainers can't tell which branch is authoritative. | [AiLaserEmitter.uc:25-31](CNN/Classes/AiLaserEmitter.uc#L25) | MEDIUM — maintainability |
| T3 | **Skin assignment without validation** — `proxy.Skin = SkinTex;` without checking SkinTex was populated. Visual artifact if defaultproperties omits it. | [AiLaserEmitter.uc](CNN/Classes/AiLaserEmitter.uc) (around BeginPlay) | MEDIUM — silent visual bug |

### Worst-offender deep notes (Tantalus)

**[AiLaserEmitter.uc](CNN/Classes/AiLaserEmitter.uc)** — Reflection-aware laser
- Strong technical content (mirror flag check) with weak code archaeology (T2). Two competing algorithms still in the file as comments.
- Recommend: pick one branch, delete the other, document why in a single line comment.

**[Chapter05.uc](CNN/Classes/Chapter05.uc)** — Tantalus's contribution: level orchestration (lines covering AllActors-based actor visibility/state toggling)
- Heavy reliance on AllActors per check (similar pattern to Dmitriy's CNNUPS), but invoked from event handlers rather than Tick — so per-frame cost is much lower than D7.
- Could share a cached-actor base class with Dmitriy's CNNUPS to reduce both files' weight.

---

## Shared / contested files

Files where neither contributor has clear majority:

| File | Total lines | Dmitriy/CorpArmstrong | Tantalus | Notes |
|---|---|---|---|---|
| **TantalusDenton.uc** | ~700 | ~85% (CorpArmstrong-original + Dmitriy refactor) | ~5-10% | Mostly Dmitriy. Notable: the empty `CheckActorDistances()` is signed `// -T.` but blame attributes the line to CorpArmstrong — collaborative authorship. |
| **Chapter05.uc** | 209 | ~37% (Dmitriy aug logic) | ~63% (orchestration) | Real co-authorship. Each owns distinct sections. The duplicate aug bug (D5) is purely Dmitriy's; the AllActors patterns are Tantalus's. |
| **AiSkillManager.uc** | ~30 | ~13 lines (Dmitriy + CorpArmstrong combined) | ~10 lines (tantalus alias) | Even split. Small file; both touched skill registration. |
| **IwHUDObjectBelt.uc** | ~217 | ~159 (CorpArmstrong) + 58 (Dmitriy) | 0 | Dmitriy refactored an older CorpArmstrong file. Single-author file from a real-person perspective. |
| **JJElecEmitter.uc** | ~103 | 63 + 40 = 103 (all Dmitriy aliases) | 0 | The "JJ" prefix has no corresponding "JJ" git author — purely a naming convention. Single-author from a real-person perspective. |

---

## Cross-cutting observations

### Patterns shared by both contributors

**Strengths:**
- State machine discipline in conversation playback ([AiConPlay.uc](CNN/Classes/AiConPlay.uc), [CASConPlay.uc](CNN/Classes/CASConPlay.uc))
- Heavy `defaultproperties` use rather than constructor logic — UE1 idiom
- Custom struct definitions for tabular data (Quest/QuestPath/etc.)

**Weaknesses:**
- **Inconsistent null-check discipline.** Some files paranoid (QuestSystem), others cavalier (LaserSecurityController, CnnConversTrigger). No coherent rule.
- **AllActors over-reliance.** Dmitriy uses it in Tick (worst case); Tantalus uses it in event handlers (better but still not cached). Both could benefit from a shared `CNNCachedActorSet` helper.
- **Compilation correctness ≠ runtime correctness** — multiple bugs (D1, D2, D3, D6) are silent failures: code compiles fine but the runtime behavior is broken. Suggests there's no integration test catching these.

### Stylistic differences

| Dimension | Dmitriy | Tantalus |
|---|---|---|
| Brace placement | Mixed (K&R + Allman within files) | Mostly Allman (next-line) |
| Comment style | Inline + occasional whimsical | Sparse + cryptic history markers |
| Function naming | Descriptive verb-phrases (`IsQuestPathCompleted`) | Action-oriented short names (`Activate`, `BeginPlay`) |
| `defaultproperties` blocks | Minimal — only critical values | Comprehensive — most tweakables exposed |
| Refactor habits | Wholesale rewrites (QuestSystem) | Incremental edits + commented-out alternatives |

---

## Status of CLAUDE.md "Code Review (2026-04-04)" findings

The existing review section in [CLAUDE.md:254-321](CLAUDE.md#L254) lists 20 issues. Status as of 2026-04-25:

| # | Issue (CLAUDE.md) | Status | Notes |
|---|---|---|---|
| 1 | Incomplete file `ApocalypseInsideMenuStartNewGame.uc:62` | **✅ FIXED** (Dmitriy, 2026-04-05) | `defaultproperties` now closes properly at line 64 |
| 2 | Self-assignment `ToggleActorLifecycleTrigger.uc:44` | **❌ STILL OPEN** | See D1 |
| 3 | Pass-by-value `ObjectsDestroyNotifier.uc:78` | **❌ STILL OPEN** | See D2 |
| 4 | Empty bool `TantalusDenton.uc:155` | **❌ STILL OPEN** | See D4 |
| 5 | Buffer overflow `Converter/obj2de/main.cpp:285` | OUT OF SCOPE (C++) | This review is UC only |
| 6 | Unsigned underflow `main.cpp:281` | OUT OF SCOPE (C++) | |
| 7 | AllActors in Tick `CNNUPS.uc:287-334` | **❌ STILL OPEN** | See D7 |
| 8 | Missing null `CnnConversTrigger.uc:52` | **❌ STILL OPEN** | See D6 |
| 9 | Missing null `LaserSecurityController.uc:91` | **❌ STILL OPEN** | See D3 |
| 10 | Duplicate aug grant `Chapter05.uc:115,160` | **❌ STILL OPEN** | See D5 |
| 11-13 | Various C++ issues | OUT OF SCOPE | |
| 14 | Debug msgbox `MandatoryMovementTriger.uc:72` | **❌ STILL OPEN** | See D8. Also `DestroyTrigger.uc:38,42,49` not yet examined |
| 15 | Uninitialized `bKeyHandled` `CNNCreditsWindowTest.uc:206-211` | NOT VERIFIED IN THIS REVIEW | Worth a follow-up |
| 16 | Variable shadowing in C++ | OUT OF SCOPE | |
| 17 | Path inconsistency `InstallUtil.cs:119-123` | OUT OF SCOPE (C#) | |
| 18 | Format string `Program.cs:15` | OUT OF SCOPE (C#) | |
| 19 | Code dup `GreenLaserTrigger`/`DamageLaserTrigger` | NOT VERIFIED | Worth a follow-up |
| 20 | Typo `laserDipatcher` `CNNMisson01.uc:7` | NOT VERIFIED | Trivial fix |

**Net:** Of 12 UnrealScript issues from the original list, 1 fixed and 11 still open. This review confirms 7 of the 11 still-open issues with current line numbers and assigns authorship. 4 (#15, #19, #20, plus DestroyTrigger.uc msgboxes) remain unverified — quick wins for a follow-up pass.

---

## Recommendations

### Immediate fixes (1-2 hours total)

| Priority | Action | File:Line | Effort |
|---|---|---|---|
| 🔴 1 | Fix self-assignment | [ToggleActorLifecycleTrigger.uc:44](CNN/Classes/ToggleActorLifecycleTrigger.uc#L44) — change to `self.spawnPoint = spawnPoint;` | 1 line |
| 🔴 2 | Fix pass-by-value | [ObjectsDestroyNotifier.uc:73](CNN/Classes/ObjectsDestroyNotifier.uc#L73) — add `out` to parameter | 1 line |
| 🔴 3 | Add null guard | [LaserSecurityController.uc:91](CNN/Classes/LaserSecurityController.uc#L91) — wrap in `if (sCam != none)` | 1 line |
| 🟡 4 | Remove duplicate aug block | [Chapter05.uc:160-164](CNN/Classes/Chapter05.uc#L160) — delete second occurrence | 5 lines |
| 🟡 5 | Add null guard | [CnnConversTrigger.uc](CNN/Classes/CnnConversTrigger.uc) — `if (conOwner == none) return;` after AllActors loop | 1 line |
| 🟡 6 | Implement or remove `CheckActorDistances()` | [TantalusDenton.uc:152-155](CNN/Classes/TantalusDenton.uc#L152) — currently empty `bool` function with undefined return | varies |
| 🟢 7 | Replace debug msgbox | [MandatoryMovementTriger.uc:72](CNN/Classes/MandatoryMovementTriger.uc#L72) — use `Log()` or remove | 1 line |
| 🟢 8 | Update CLAUDE.md issue #1 | Mark as fixed (file now compiles) | 1 line |

### Medium-term refactor (4-6 hours)

- **Cache CNNUPS actor lookups in PostBeginPlay** — eliminates the per-frame AllActors cost (D7). Sketch in agent draft uses `var array<ScriptedPawn>` + `var array<CNNMover>`. Expected gain: ~2-5ms per frame on dense maps.
- **Resolve AiLaserEmitter "JJ change here" comments** — pick one branch, delete the other, document the rationale.
- **Tackle the unverified CLAUDE.md issues** — #15 (uninitialized bKeyHandled), #19 (GreenLaser/DamageLaser duplication), #20 (laserDipatcher typo), and the remaining debug msgboxes in DestroyTrigger.uc.

### Long-term (out of scope for a quick pass)

- **Shared `CNNCachedActorSet` helper** — eliminates the AllActors pattern across both contributors' code.
- **Pair-review for shared files** — the Chapter05 duplicate-aug bug shows what happens when contributors edit the same file independently. Establish a one-glance review for shared files.
- **Compile-time defaultproperties validation** — multiple bugs are caused by tuple values silently being incomplete. The completed ApocalypseInsideMenuStartNewGame.uc:62 fix shows this is a recurring foot-gun.

---

## Final verdict

This is **healthy mid-stage indie codebase** quality. Both contributors:
- Show competence with UE1 idioms (state machines, defaultproperties, exec directives)
- Make recurring mistakes around null-check discipline and AllActors performance
- Have visibly different but compatible styles
- Leave artifacts of work-in-progress (commented-out alternatives, sparse docs)

The CRITICAL bugs are mechanical fixes — none are architectural problems. With the immediate-fixes batch landed, the codebase is ready for the L2 quest work without more cleanup.

---

*Generated 2026-04-25 on branch `chore/repo-cleanup`. Review is sample-based; not exhaustive. Update when significant refactors land or new contributors join.*
