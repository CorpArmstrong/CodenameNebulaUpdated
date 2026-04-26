# Codename Nebula — Open UnrealScript Issues

**Date:** 2026-04-25 | **Branch:** `chore/repo-cleanup` | **Scope:** [CNN/Classes/](CNN/Classes/)*.uc (267 files) + [CNNText/Classes/](CNNText/Classes/)*.uc (1 file)

Open issues found during a sampling-based UnrealScript review. Methodology: ~30-40 representative files read across all subsystems (game core, NPCs, weapons, HUD, triggers, missions). Findings extrapolate to similar files. All citations verified at the line level via direct file read.

Sister docs: [CLAUDE.md](CLAUDE.md) (project guide with prior 20-issue list), [CLASSES_MAP.md](CLASSES_MAP.md) (class atlas), [REPO_MAP.md](REPO_MAP.md) (repo navigation).

This is a sampling-based review — not every file was read line-by-line.

---

## CRITICAL — resolved

| # | Issue | Location | Status |
|---|---|---|---|
| C1 | Self-assignment in `ToggleActorLifecycleTrigger.uc:44` — closer reading shows the local-shadow `spawnPoint` is correctly bound by the foreach loop, and `spawnLocation`/`spawnRotation` are set from it. The class member `spawnPoint` is unused dead code; line 44 is a no-op leftover. | [ToggleActorLifecycleTrigger.uc:44](CNN/Classes/ToggleActorLifecycleTrigger.uc#L44) | **FALSE POSITIVE** |
| C2 | Pass-by-value counter in `HandleDestroyedObject` — increment didn't propagate back to caller's local. Quest goals using `ObjectsDestroyNotifier` (e.g., `BurnEvidence`) couldn't complete in a single poll cycle. | [ObjectsDestroyNotifier.uc:73](CNN/Classes/ObjectsDestroyNotifier.uc#L73) | **FIXED 2026-04-25** (added `out` keyword) |
| C3 | Missing null guard on `sCam` — `sCam.bNoAlarm = bNoAlarm;` would crash when no `SecurityCamera` with the matching tag exists. | [LaserSecurityController.uc:91](CNN/Classes/LaserSecurityController.uc#L91) | **FIXED 2026-04-25** (wrapped in `if (sCam != none)`) |

---

## HIGH — open

| # | Issue | Location | Severity rationale |
|---|---|---|---|
| H1 | **Empty bool function** — `function bool CheckActorDistances() { }` declares `bool` return but has empty body. Returns undefined value. | [TantalusDenton.uc:152-155](CNN/Classes/TantalusDenton.uc#L152) | Undefined return value used by callers |
| H2 | **Duplicate augmentation grant** — Identical `if (HasHeartAug && !PlayerGotHeartAug)` block appears twice. Player can receive `AugHeartLung` twice. | [Chapter05.uc:115,160](CNN/Classes/Chapter05.uc#L115) | Gameplay duplication |
| H3 | **Missing null check on `conOwner`** — `AllActors` loop may not find a matching actor; `conOwner` stays `None` and is passed directly to `StartConversationByName()`. | [CnnConversTrigger.uc:52](CNN/Classes/CnnConversTrigger.uc#L52) | Potential crash |
| H4 | **Missing player null guard in menu** — `UpdateButtonStatus()` accesses `player.IsInState('Dying')` without null-check on `player`. | [ApocalypseInsideMenuMain.uc:39-46](CNN/Classes/ApocalypseInsideMenuMain.uc#L39) | Edge-case crash |

---

## MEDIUM — open

| # | Issue | Location | Severity |
|---|---|---|---|
| M1 | **Debug msgbox in production** — `msgbox("MovedPawn not finded")` blocks game with a dialog (also typo: "finded" → "found", and filename typo: "Triger"). Should be `ClientMessage()` or removed. | [MandatoryMovementTriger.uc:72](CNN/Classes/MandatoryMovementTriger.uc#L72) | UX issue + dual typo |
| M2 | **Debug msgbox calls in production** — multiple `self.MsgBox()` calls in trigger handlers. | [DestroyTrigger.uc:38,42,49](CNN/Classes/DestroyTrigger.uc#L38) | UX issue |
| M3 | **Skin assignment without validation** — `proxy.Skin = SkinTex;` without checking SkinTex was populated. | [AiLaserEmitter.uc](CNN/Classes/AiLaserEmitter.uc) (around BeginPlay) | Silent visual bug |
| M4 | **Cryptic history comments** — Two alternative laser-filter implementations preserved as inline commented-out lines with annotation markers. Future maintainers can't tell which branch was authoritative. | [AiLaserEmitter.uc:25-31](CNN/Classes/AiLaserEmitter.uc#L25), [CNNLaserEmitter.uc:25-29](CNN/Classes/CNNLaserEmitter.uc#L25) | Maintainability |

---

## NEUTRAL — withdrawn from prior review

| # | Original concern | Location | Why withdrawn |
|---|---|---|---|
| N1 | "AllActors in Tick — performance" | [CNNUPS.uc:287-334](CNN/Classes/CNNUPS.uc#L287) | `foreach AllActors()` in Tick paths is the **idiomatic UE1 pattern** for the Deus Ex 1 era. Original Deus Ex missions use it extensively. UE1 actor lists are designed for this access pattern; refactoring to caching adds complexity (Spawn/Destroy invalidation) without measurable gain at typical UE1 actor counts. Only flag if you observe actual frame stutter on a specific map. |

---

## Status of CLAUDE.md "Code Review (2026-04-04)" findings

The existing review section in [CLAUDE.md:254-321](CLAUDE.md#L254) lists 20 issues. Status as of 2026-04-25:

| # | Issue (CLAUDE.md) | Status | Notes |
|---|---|---|---|
| 1 | Incomplete file `ApocalypseInsideMenuStartNewGame.uc:62` | **FIXED** (2026-04-05) | `defaultproperties` now closes properly at line 64 |
| 2 | Self-assignment `ToggleActorLifecycleTrigger.uc:44` | **FALSE POSITIVE** (verified 2026-04-25) | See C1 |
| 3 | Pass-by-value `ObjectsDestroyNotifier.uc:78` | **FIXED** (2026-04-25) | See C2 |
| 4 | Empty bool `TantalusDenton.uc:155` | **OPEN** | See H1 |
| 5 | Buffer overflow `Converter/obj2de/main.cpp:285` | OUT OF SCOPE (C++) | This review is UC only |
| 6 | Unsigned underflow `main.cpp:281` | OUT OF SCOPE (C++) | |
| 7 | AllActors in Tick `CNNUPS.uc:287-334` | **WITHDRAWN** (idiomatic UE1) | See N1 |
| 8 | Missing null `CnnConversTrigger.uc:52` | **OPEN** | See H3 |
| 9 | Missing null `LaserSecurityController.uc:91` | **FIXED** (2026-04-25) | See C3 |
| 10 | Duplicate aug grant `Chapter05.uc:115,160` | **OPEN** | See H2 |
| 11-13 | Various C++ issues | OUT OF SCOPE | |
| 14 | Debug msgbox `MandatoryMovementTriger.uc:72` | **OPEN** | See M1 + M2 |
| 15 | Uninitialized `bKeyHandled` `CNNCreditsWindowTest.uc:206-211` | NOT VERIFIED | Worth a follow-up |
| 16 | Variable shadowing in C++ | OUT OF SCOPE | |
| 17 | Path inconsistency `InstallUtil.cs:119-123` | OUT OF SCOPE (C#) | |
| 18 | Format string `Program.cs:15` | OUT OF SCOPE (C#) | |
| 19 | Code dup `GreenLaserTrigger`/`DamageLaserTrigger` | NOT VERIFIED | Worth a follow-up |
| 20 | Typo `laserDipatcher` `CNNMisson01.uc:7` | NOT VERIFIED | Trivial fix |

**Net:** Of 12 UnrealScript issues from the original list: 3 fixed, 1 false positive, 1 withdrawn, 4 confirmed open, 3 unverified.

---

## Cross-cutting observations

**Patterns worth keeping:**
- State machine discipline in conversation playback ([AiConPlay.uc](CNN/Classes/AiConPlay.uc), [CASConPlay.uc](CNN/Classes/CASConPlay.uc))
- Heavy `defaultproperties` use rather than constructor logic — UE1 idiom
- Custom struct definitions for tabular data (Quest/QuestPath/etc.)

**Recurring weaknesses:**
- **Inconsistent null-check discipline.** Some files defensive ([QuestSystem.uc](CNN/Classes/QuestSystem.uc)), others cavalier ([LaserSecurityController.uc](CNN/Classes/LaserSecurityController.uc), [CnnConversTrigger.uc](CNN/Classes/CnnConversTrigger.uc)). No coherent rule.
- **Compilation correctness ≠ runtime correctness.** Multiple bugs (C2, C3, H3) are silent failures: code compiles fine but runtime behavior is broken. Suggests no integration test catching these.

**Not a weakness:** `foreach AllActors()` in Tick or per-frame paths is **idiomatic UE1** and used throughout original Deus Ex code. Don't refactor unless you observe actual frame stutter.

---

## Recommendations

### Immediate fixes (~1-2 hours total)

| Priority | Action | File:Line | Effort |
|---|---|---|---|
| 🟡 1 | Remove duplicate aug block | [Chapter05.uc:160-164](CNN/Classes/Chapter05.uc#L160) — delete second occurrence | 5 lines |
| 🟡 2 | Add null guard | [CnnConversTrigger.uc](CNN/Classes/CnnConversTrigger.uc) — `if (conOwner == none) return;` after AllActors loop | 1 line |
| 🟡 3 | Implement or remove `CheckActorDistances()` | [TantalusDenton.uc:152-155](CNN/Classes/TantalusDenton.uc#L152) — currently empty `bool` function | varies |
| 🟢 4 | Add null guard | [ApocalypseInsideMenuMain.uc:39-46](CNN/Classes/ApocalypseInsideMenuMain.uc#L39) — wrap `player.IsInState` access | 1 line |
| 🟢 5 | Replace debug msgbox | [MandatoryMovementTriger.uc:72](CNN/Classes/MandatoryMovementTriger.uc#L72) — use `Log()` or remove | 1 line |
| 🟢 6 | Replace debug msgbox calls | [DestroyTrigger.uc:38,42,49](CNN/Classes/DestroyTrigger.uc#L38) | ~3 lines |

### Medium-term (~2-4 hours)

- **Resolve laser-filter history comments** (M4) — pick the active branch, delete the commented alternatives, leave a one-line note explaining the change. Both [AiLaserEmitter.uc](CNN/Classes/AiLaserEmitter.uc) and [CNNLaserEmitter.uc](CNN/Classes/CNNLaserEmitter.uc).
- **Tackle the unverified CLAUDE.md issues** — #15 (uninitialized bKeyHandled), #19 (GreenLaser/DamageLaser duplication), #20 (laserDipatcher typo).

### Long-term

- **Compile-time defaultproperties validation** — multiple bugs are caused by tuple values silently being incomplete (the closed CLAUDE.md issue #1 is an example). A linter pass that flags unclosed `defaultproperties` blocks would catch this category before runtime.

---

## Final verdict

The CRITICAL bugs are mechanical fixes — none are architectural problems. With the immediate-fixes batch landed, the codebase is ready for the L2 quest work without more cleanup.

---

*Generated 2026-04-25 on branch `chore/repo-cleanup`. Sample-based review; not exhaustive. Update when significant refactors land.*
