# Codename Nebula — Open UnrealScript Issues

**Date:** 2026-04-25 | **Branch:** `chore/repo-cleanup` | **Scope:** [CNN/Classes/](CNN/Classes/)*.uc (267 files) + [CNNText/Classes/](CNNText/Classes/)*.uc (1 file)

Open issues found during a sampling-based UnrealScript review. Methodology: ~30-40 representative files read across all subsystems (game core, NPCs, weapons, HUD, triggers, missions). Findings extrapolate to similar files. All citations verified at the line level via direct file read.

Sister docs: [CLAUDE.md](CLAUDE.md) (project guide with prior 20-issue list), [CLASSES_MAP.md](CLASSES_MAP.md) (class atlas), [REPO_MAP.md](REPO_MAP.md) (repo navigation).

This is a sampling-based review — not every file was read line-by-line.

**M5 (added 2026-09-23)** used a different methodology: a live in-game session driven through the `CNNAgentBridge` file-based command bridge (`.claude/skills/cnn-playtest`), not a static read — see `memory/project_agent_bridge.md` for how that bridge works.

---

## CRITICAL — resolved

| # | Issue | Location | Status |
|---|---|---|---|
| C1 | Self-assignment in `ToggleActorLifecycleTrigger.uc:44` — closer reading shows the local-shadow `spawnPoint` is correctly bound by the foreach loop, and `spawnLocation`/`spawnRotation` are set from it. The class member `spawnPoint` is unused dead code; line 44 is a no-op leftover. | [ToggleActorLifecycleTrigger.uc:44](CNN/Classes/ToggleActorLifecycleTrigger.uc#L44) | **FALSE POSITIVE** |
| C2 | Pass-by-value counter in `HandleDestroyedObject` — increment didn't propagate back to caller's local. Quest goals using `ObjectsDestroyNotifier` (e.g., `BurnEvidence`) couldn't complete in a single poll cycle. | [ObjectsDestroyNotifier.uc:73](CNN/Classes/ObjectsDestroyNotifier.uc#L73) | **FIXED 2026-04-25** (added `out` keyword) |
| C3 | Missing null guard on `sCam` — `sCam.bNoAlarm = bNoAlarm;` would crash when no `SecurityCamera` with the matching tag exists. | [LaserSecurityController.uc:91](CNN/Classes/LaserSecurityController.uc#L91) | **FIXED 2026-04-25** (wrapped in `if (sCam != none)`) |

---

## HIGH — all fixed or mitigated (2026-09-24)

| # | Issue | Location | Severity rationale |
|---|---|---|---|
| H1 | **FIXED (verified 2026-09-24, was already in code)** — ~~**Empty bool function**~~ now an explicit `return false;` intentional override with a comment. Original: — `function bool CheckActorDistances() { }` declares `bool` return but has empty body. Returns undefined value. | [TantalusDenton.uc:152-155](CNN/Classes/TantalusDenton.uc#L152) | Undefined return value used by callers |
| H2 | **FIXED 2026-09-24** — second block removed (it was dead: the first block already sets `PlayerGotHeartAug`, so it could never fire, but it was noise). Original: ~~**Duplicate augmentation grant**~~ — Identical `if (HasHeartAug && !PlayerGotHeartAug)` block appears twice. Player can receive `AugHeartLung` twice. | [Chapter05.uc:115,160](CNN/Classes/Chapter05.uc#L115) | Gameplay duplication |
| H3 | **FIXED (verified 2026-09-24, was already in code)** — `if (conOwner == none) return;` present after the loop. Original: ~~**Missing null check on `conOwner`**~~ — `AllActors` loop may not find a matching actor; `conOwner` stays `None` and is passed directly to `StartConversationByName()`. | [CnnConversTrigger.uc:52](CNN/Classes/CnnConversTrigger.uc#L52) | Potential crash |
| H4 | **FIXED 2026-09-24** — early `if (player == None) return;` (vanilla MenuMain has the same unguarded code; defensive only). Original: ~~**Missing player null guard in menu**~~ — `UpdateButtonStatus()` accesses `player.IsInState('Dying')` without null-check on `player`. | [ApocalypseInsideMenuMain.uc:39-46](CNN/Classes/ApocalypseInsideMenuMain.uc#L39) | Edge-case crash |
| H5 | **MITIGATED 2026-09-23 (permanent safety net; underlying compiler flakiness not fully root-caused)** — **Scrolling end-credits showed no text, which collapsed the entire ending sequence to a few seconds and dumped the player at the main menu** (`CreditsScrollWindow`'s scroll-to-bottom check has nothing to scroll when the text is empty, so `FinishedScrolling()` fires almost immediately and [CNNCreditsWindow.uc](CNN/Classes/CNNCreditsWindow.uc)'s `DestroyWindow()` sends the player to `"cnnentry"`). Confirmed live on Hijacking/Mutiny/Transcend and by the user watching a Conspiracy playtest. **Investigation trail:** (1) a real, reproducible bug found and fixed — `CNNText/Classes/CNNTextImport.uc` had an explicit `#exec DEUSEXTEXT IMPORT` for `CNNCredits.txt` at the same time `CNN/Classes/ApocalypseInsideText.uc`'s `#exec ALLDEUSEXTEXT IMPORT` auto-discovered the same file (it used to sit directly at `CNNText\Text\` root, the only spot ALLDEUSEXTEXT's top-level-only cross-package scan reaches — every other CNNText content file lives one level deeper in a mission05/mission06 subfolder and was never affected), so two mechanisms raced to import one file into a resource both named `CNNCredits`; removing the duplicate directive let one real compile through with the content present (verified: `grep -aoc "Project director" CNN.u` → `3`). (2) Moved `CNNCredits.txt` to `CNNText/Text/credits/CNNCredits.txt`, fully out of `ALLDEUSEXTEXT`'s reach, importing it solely via the same explicit `DEUSEXTEXT IMPORT` every other (reliably-working) CNNText text file uses; `CNNCreditsWindow.uc`'s `textPackage` changed from `"CNN"` to `"CNNText"` to match. (3) Despite this, the import proved **nondeterministic across repeat compiles with zero source changes** — content present in only ~1 of 8 otherwise-identical rebuilds, tested down to a 10-line excerpt and a differently-named resource, ruling out file length, resource-name collision, and location as the sole cause. This rate is in the same ballpark as the already-documented ~25% intermittent GPF on `CONVERSATION IMPORT` (`feedback_ucc_gpf` memory) and is suspected to be the same underlying 32-bit `ucc.exe` heap flakiness, manifesting as a silently dropped resource instead of a hard crash — not confirmed. **Fix landed:** [CNNCreditsWindow.ProcessText()](CNN/Classes/CNNCreditsWindow.uc#L12) now has a permanent hardcoded fallback (behind `if (!bGotText)`) that renders whenever `parser.OpenText()` fails for that compile, so players always see real credits text either way. Verified live twice: once via the real import (full scroll, correct pace, correct formatting) and once via the fallback (same rendering quality, shorter list) — confirming `CreditsScrollWindow`/`CNNCreditsWindow`'s display logic was never the problem. **Still open:** root cause of the ucc-level nondeterminism itself. **Re-confirmed 2026-09-23 (later same day):** all four endings (Hijacking, Mutiny, Conspiracy, Transcend) individually re-tested via fresh `CNNAgentBridge` sessions — credits scroll with real content and the game returns cleanly to `cnnentry` every time, no exceptions. The fallback text was also expanded since first written here (now lists all 8 known team members, not a short excerpt) and briefly grew a dev-facing `"Full credits: <path>"` pointer line alongside that expansion; a user caught it as player-visible during a playtest and it was removed. | [ApocalypseInsideText.uc:5](CNN/Classes/ApocalypseInsideText.uc#L5), [CNNTextImport.uc](CNNText/Classes/CNNTextImport.uc), [CNNCreditsWindow.uc](CNN/Classes/CNNCreditsWindow.uc) | Player-visible content bug, ending sequence — mitigated |

---

## MEDIUM — all fixed (2026-09-24)

| # | Issue | Location | Severity |
|---|---|---|---|
| M1 | **FIXED (verified 2026-09-24, was already in code)** — now `Log(...)`. Original: ~~**Debug msgbox in production**~~ — `msgbox("MovedPawn not finded")` blocks game with a dialog (also typo: "finded" → "found", and filename typo: "Triger"). Should be `ClientMessage()` or removed. | [MandatoryMovementTriger.uc:72](CNN/Classes/MandatoryMovementTriger.uc#L72) | UX issue + dual typo |
| M2 | **FIXED (verified 2026-09-24, was already in code)** — no `MsgBox` left in DestroyTrigger. Original: ~~**Debug msgbox calls in production**~~ — multiple `self.MsgBox()` calls in trigger handlers. | [DestroyTrigger.uc:38,42,49](CNN/Classes/DestroyTrigger.uc#L38) | UX issue |
| M3 | **FIXED 2026-09-24** — guarded on `SkinTex != none`; also fixed an unguarded `spot[i].Skin` right after `Spawn` in `CalcTrace`. Original: ~~**Skin assignment without validation**~~ — `proxy.Skin = SkinTex;` without checking SkinTex was populated. | [AiLaserEmitter.uc](CNN/Classes/AiLaserEmitter.uc) (around BeginPlay) | Silent visual bug |
| M4 | **FIXED 2026-09-24** — commented alternatives removed from AiLaserEmitter and CNNLaserEmitter, replaced by one comment stating the difference from vanilla. Original: ~~**Cryptic history comments**~~ — Two alternative laser-filter implementations preserved as inline commented-out lines with annotation markers. Future maintainers can't tell which branch was authoritative. | [AiLaserEmitter.uc:25-31](CNN/Classes/AiLaserEmitter.uc#L25), [CNNLaserEmitter.uc:25-29](CNN/Classes/CNNLaserEmitter.uc#L25) | Maintainability |
| M5 | ~~`DeusExLevelInfo.mapName` copy-pasted across three L2 ending maps~~ **FIXED 2026-09-23 (self-heal, no UnrealEd)** — `06_Conspiracy`, `06_Hijacking`, `06_Transcend` all reported `mapName="MUTINY"`. Rather than editing the `.dx` files in UnrealEd, [CNNMissionEndgame.uc:52-62](CNN/Classes/CNNMissionEndgame.uc#L52) now writes the correct value at runtime: `dxInfo.mapName = mapName` right where `mapName` is already computed from `GetURLMap()`. `dxInfo` (declared on `MissionScript`) is the actual placed `DeusExLevelInfo` instance for the current map, found via `foreach AllActors` — writing to it changes only that map's instance, not the class default, and runs once per map load (guarded by `bQuotePrinted`). Verified live: `CNNWhere` on `06_Transcend` now reports `map=06_TRANSCEND` instead of `Mutiny`. | [CNNMissionEndgame.uc:52-62](CNN/Classes/CNNMissionEndgame.uc#L52) | Fixed |

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
| 4 | Empty bool `TantalusDenton.uc:155` | **FIXED** | See H1 |
| 5 | Buffer overflow `Converter/obj2de/main.cpp:285` | OUT OF SCOPE (C++) | This review is UC only |
| 6 | Unsigned underflow `main.cpp:281` | OUT OF SCOPE (C++) | |
| 7 | AllActors in Tick `CNNUPS.uc:287-334` | **WITHDRAWN** (idiomatic UE1) | See N1 |
| 8 | Missing null `CnnConversTrigger.uc:52` | **FIXED** | See H3 |
| 9 | Missing null `LaserSecurityController.uc:91` | **FIXED** (2026-04-25) | See C3 |
| 10 | Duplicate aug grant `Chapter05.uc:115,160` | **FIXED** (2026-09-24) | See H2 |
| 11-13 | Various C++ issues | OUT OF SCOPE | |
| 14 | Debug msgbox `MandatoryMovementTriger.uc:72` | **FIXED** | See M1 + M2 |
| 15 | Uninitialized `bKeyHandled` `CNNCreditsWindowTest.uc:206-211` | NOT VERIFIED | Worth a follow-up |
| 16 | Variable shadowing in C++ | OUT OF SCOPE | |
| 17 | Path inconsistency `InstallUtil.cs:119-123` | OUT OF SCOPE (C#) | |
| 18 | Format string `Program.cs:15` | OUT OF SCOPE (C#) | |
| 19 | Code dup `GreenLaserTrigger`/`DamageLaserTrigger` | NOT VERIFIED | Worth a follow-up |
| 20 | Typo `laserDipatcher` `CNNMisson01.uc:7` | NOT VERIFIED | Trivial fix |

**Net (2026-09-24):** Of 12 UnrealScript issues from the original list: 7 fixed, 1 false positive, 1 withdrawn, 0 open, 3 unverified.

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

### Immediate fixes — all done 2026-09-24

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
