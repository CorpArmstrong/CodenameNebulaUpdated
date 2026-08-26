# L2 Walkthrough Map — 06_OpheliaL2

A Detroit-style flow graph for L2: every player move, action, conversation and flag on the
way to each of the four endings.

**How this was produced.** Every coordinate, property, flag direction and owner below was
read out of the shipped binaries — `L2_export.t3d` for actors, `tools/con_dump.js --records
--flagmap` for conversation logic, and `CNN/Classes/Chapter06L2.uc` for the ending
decision. Nothing here is recalled or inferred from play.

**Confidence legend.** Read these markers literally; they are the point of the document.

| Marker | Meaning |
|---|---|
| OK | Measured from the binaries. Exact. |
| INF | Inferred from how the engine works, not directly observed in play. |
| DEAD | **Verified broken** — cannot happen in the shipped build. |
| UNK | Not knowable from the data. Do not trust, do not invent. |

> **The one thing this map does not contain: navigation.** Which door, ladder, keypad or
> corridor connects one coordinate to the next was never measured and is *not* recorded
> here. Coordinates are exact; the path between them is UNK. If you need the route, fly it
> once with `ghost` and write it down — do not guess from the numbers.

---

## 1. Launching and instrumenting a run

```
cnn package && cnn install     # never skip: the stale distribution CNN.u shadows a rebuild
cnn test                       # New Game, then console: open 06_OpheliaL2
```

Console key is **T** (or **~**). Both are bound by the generated `CNNUser.ini` only when
the player has nothing bound — see `tools/generate_cnn_ini.ps1`.

**Enabling cheats.** The player class is `CNN.TantalusDenton`, not `DeusExPlayer`, so the
class must be named explicitly:

```
set cnn.tantalusdenton bcheatsenabled true
```

Without that, `EditFlags` and `Legend` return early and do nothing. `CNNTestEnding` is an
exec function and needs no cheats. Useful once cheats are on: `ghost`, `allammo`,
`EditFlags` (read/write any flag live).

**Reading flags during a run.** `Chapter06L2` polls 22 flags every second and logs each
change (`bLogFlagChanges`, on by default):

```
cnn log "CNN L2 flag"
```

Kentie's exe writes the log into the OneDrive-localised Documents folder, not `System\`;
`cnn log` finds it either way.

---

## 2. Geography

The level runs roughly **north to south** (Y decreasing) across three vertical bands.

| Band | Z | Contents |
|---|---|---|
| Entry ledge | ~+870 | Arrival, `OnLevel2` trigger |
| Main deck | ~0 to +25 | MJ12 soldiers, Samantha Reed trigger, corridor south, tube area |
| Lower labs | ~-890 to -1350 | Magdalene's start, JC Avatar, IoT terminal, Mephistopheles, the Reed/Wong scene |

Anything at **positive Y** (e.g. `MikeWong1` at `(962, 3863, 268)`, `SamanthaReed` #2 at
`(944, 3788, 256)`, `BobPage2` at `(5835, -2160, 80)`) is an **offstage set** — holo and
cutscene doubles, not places the player walks. INF

---

## 3. The flow graph

```mermaid
flowchart TD
    START["Arrive<br/>PlayerStart (-1044,-1900,891)<br/>Teleporter 'L2' (-1066,-1881,843)"]
    ONL2["FlagTrigger (-901,-1884,872) r=150<br/>SETS OnLevel2"]
    HALL["OpheliaHallway<br/>PRECOND: OnLevel2 + FinalGoodbyePlayed<br/>adds objective 'Free Ophelia'"]
    MOVE["MandatoryMovementTriger (260,-1547,8)<br/>moves PLAYER to MovePlayer (-547,-1874,52)"]
    SOLD["MeetSoldiers / GestureRight<br/>MJ12 group (853..923, -1587..-1653, ~22)<br/>SETS ReadyForBossFight"]

    SAM["ConversationTrigger0 (841,-2031,8)<br/>conversationTag=MeetSamanthaReed<br/>BindName EMPTY"]
    DEAD["INERT - never fires"]

    IOT["IoTterminal (701,-2861,-1348)<br/>'Give clearance to Level 2 Labs'"]
    OPENLABS["Dispatcher 'OpenLabs'<br/>to MagdaleneMandatoryMovementTriger<br/>and AvatarLabHatch"]
    MAGMOVE["Magdalene teleports<br/>(1083,-2133,-1335) to MagdaleneLabPoint (878,-1682,0)"]

    MAG["FROB MAGDALENE<br/>MagdaleneHijackTheStation<br/>owner=Magdalene, NO preconditions"]
    ARM["SETS CanArmMagdalene<br/>(at the END of the conversation)"]

    TUBE["ConversationTrigger1 (843,-6084,8)<br/>LoadingInTube, BindName=Magdalene"]
    WALK["OrdersTrigger 'WalkIntoATube'<br/>Magdalene runs to MagdalenePoint (786,-6080,-8)"]
    FINAL["ConversationTrigger2 (1801,-6412,8) r=40<br/>MagdaleneInsideTube, BindName=Magdalene<br/>SETS FinalGoodbyePlayed"]

    DEATH["Player dies anywhere<br/>SETS PlayerDiedOnL2 / PlayerDiedDuringUpload"]

    DECIDE{"Chapter06L2.CheckEndingReached<br/>polled every 1s"}
    MUT["06_Mutiny"]
    HIJ["06_Hijacking"]
    TRA["06_Transcend"]
    CON["06_Conspiracy"]

    START --> ONL2 --> HALL --> MOVE --> SOLD
    SOLD --> SAM --> DEAD
    SOLD --> IOT --> OPENLABS --> MAGMOVE
    SOLD --> MAG
    MAGMOVE --> MAG
    MAG --> ARM
    ARM --> TUBE
    SOLD --> TUBE
    TUBE --> WALK --> FINAL --> DECIDE
    DEATH --> DECIDE

    DECIDE -->|"died"| MUT
    DECIDE -->|"CanArmMagdalene"| HIJ
    DECIDE -->|"MikeWongExposed or SeedsOfDoubtPlanted"| TRA
    DECIDE -->|"otherwise"| CON

    style DEAD fill:#7f1d1d,color:#fff
    style SAM fill:#7f1d1d,color:#fff
    style TRA fill:#7f1d1d,color:#fff
```

---

## 4. Node reference

### Spine — every run passes through these

| # | Node | Position | Effect | Conf |
|---|---|---|---|---|
| 1 | `PlayerStart` | `(-1044, -1900, 891)` | New-game / EXEC spawn | OK |
| 1b | `Teleporter` tag `L2` | `(-1066, -1881, 843)` | Arrival point from L1 | OK |
| 2 | `FlagTrigger` | `(-901, -1884, 872)` r=150 | **SETS `OnLevel2`** | OK |
| 3 | `OpheliaHallway` | owner `OpheliaUI` | PRECOND on `OnLevel2` + `FinalGoodbyePlayed`; adds "Free Ophelia" | OK |
| 4 | `MandatoryMovementTriger` | `(260, -1547, 8)` | Moves **the player** to `MovePlayer (-547,-1874,52)` | OK |
| 5 | MJ12 group | `(853..923, -1587..-1653, ~22)` | `MeetSoldiers`; `GestureRight` **SETS `ReadyForBossFight`** so avatars turn hostile | OK |
| 6 | `LoadingInTube` | `(843, -6084, 8)` | Starts upload scene; fires `WalkIntoATube` | OK |
| 7 | `MagdaleneInsideTube` | `(1801, -6412, 8)` r=40 | **SETS `FinalGoodbyePlayed`** — the ending gate | OK |

Node 2 sits ~145 units from the spawn with a 150 radius, so `OnLevel2` is set on your
first steps. `FlagTrigger` defaults (`bSetFlag=True`, `flagValue=True`, `flagExpiration=-1`,
`bTriggerOnceOnly=True`) make it permanent. OK

### The Hijacking branch

| # | Node | Position | Effect | Conf |
|---|---|---|---|---|
| H1 | **Magdalene** | `(1083, -2133, -1335)` | `Tag=HiddenMagdalene`, `Orders=Standing`, CoilGun, `Alliance=Player`, `bInvincible` — friendly and frobbable from level start | OK |
| H2 | `IoTterminal` | `(701, -2861, -1348)` | Option "Give clearance to Level 2 Labs" fires event `OpenLabs` | OK |
| H3 | `Dispatcher OpenLabs` | `(-97, -2536, -1338)` | to `MagdaleneMandatoryMovementTriger`, `AvatarLabHatch` | OK |
| H4 | `MagdaleneMandatoryMovementTriger` | `(-95, -2465, -890)` | `MT_MovePawn`, `MovedPawnTag=HiddenMagdalene`, teleports her to `MagdaleneLabPoint (878,-1682,0)` | OK |
| H5 | `MagdaleneLabOrdersTrigger` | `(-94, -2280, 8)` | `Orders=Following` | OK |
| H6 | **`MagdaleneHijackTheStation`** | owner Magdalene | **No flag preconditions.** **SETS `CanArmMagdalene`** at the *end* of the record (`@0x00644f`) | OK |

**Frobbing her at any stage should start it** (INF — the record has no gate). But the SET
is at the tail, so **breaking off early earns nothing**. OK

Her position depends on progress: start, then `OpenLabs` teleports her up near the entry,
then `Following`, then after `JCboss` she turns hostile to `BPAvatar` and fights, then
after `LoadingInTube` she runs to the tube. OK

### Where the rest of the cast actually is

The cast is placed as **generic pawns with `BindName` overrides**, not as named classes —
a search for `Class=SamanthaReed` finds nothing and is misleading. OK

| BindName | Class | Position |
|---|---|---|
| `SamanthaReed` | `Female2`, Sitting | `(971, -3991, -1284)` |
| `MikeWong` | `Male2` | `(782, -4058, -1301)` |
| `DrMephistopheles` | `Doctor`, tag `Mephistopheles` | `(866, -4480, -1233)` |
| `JCAvatar` | `BPAvatar` | `(894, -2315, -1303)` |
| `PageAvatar` | `LuciusDeBeers` | `(1279, -6067, 110)` |
| `OpheliaMedbot` | `MedicalBot` | `(1487, -6294, 4)` |
| `DrJohnson` | `DrJohnson`, Sitting | `(757, -4138, -1304)` |

Samantha Reed and Mike Wong are **in the lower labs at Y around -4000**, roughly 2000 units
south of and 1300 below the trigger that is supposed to introduce them.

---

## 5. Route per ending

| Ending | What the player does | Condition | Reachable |
|---|---|---|---|
| **Mutiny** (worst) | **Die anywhere on L2.** Judged immediately — never needs the tube. | `PlayerDiedOnL2` or `PlayerDiedDuringUpload` | yes |
| **Hijacking** (best) | Reach Magdalene, **play `MagdaleneHijackTheStation` to the end**, then reach the tube. | `CanArmMagdalene` | yes |
| **Conspiracy** | Walk the spine, talk to nobody, reach the tube. | none of the above (passive) | yes |
| **Transcend** | *No route exists.* See section 6. | `MikeWongExposed` or `SeedsOfDoubtPlanted` | **NO** |

Decision logic lives in `Chapter06L2.CheckEndingReached()`, polled once a second. Death
outranks everything; every other branch waits for `FinalGoodbyePlayed`.

---

## 6. Transcend is unreachable in the shipped build

Both of its conditions are dead, for different reasons.

**`MikeWongExposed`** is SET in exactly one place: the `ContinueOn` record (`@0x009eca`,
`ET_SetFlag`), part of the Samantha Reed scene. The only thing in the map that can start
that scene is `ConversationTrigger0` at `(841, -2031, 8)` — and it has **no `BindName`**.
Vanilla `ConversationTrigger.Touch()` reads:

```unrealscript
if ((BindName != "") && (conversationTag != ''))
```

With `BindName` empty the whole body is skipped, so the trigger is **inert**: it never
calls `StartConversationByName`. OK — and note the level's two working triggers both carry
`BindName="Magdalene"`.

**`SeedsOfDoubtPlanted`** is SET only in `AccuseofBluffing`, a branch under `SocialBoss`.
`SocialBoss` carries a PRECOND on `ReadyForSocialBoss`, which is SET only by `TalkToPage`,
and no trigger in the map starts `TalkToPage`. OK for the chain; UNK on whether some other
path reaches it.

### Fix — implemented 2026-08-26

`Chapter06L2.RepairSamanthaReedTrigger()`, called from `PrepareFirstFrame()`, walks
`AllActors(class'ConversationTrigger')` and fills in `BindName="SamanthaReed"` on the
trigger whose `conversationTag` is `MeetSamanthaReed`, but **only when `BindName` is
empty** — so if the map is ever fixed properly this becomes a no-op. Matching on
`conversationTag` rather than `Tag` because two of the three triggers share the generic
tag `ConversationTrigger`.

Doing it in script rather than UnrealEd keeps the change diffable, the same reason the
rest of L2's logic lives in source.

Confirmed running in-game — the log line appears at level load: OK

```
ScriptLog: CNN L2: repaired MeetSamanthaReed trigger (BindName was empty)
```

**Still unverified end-to-end:** that the conversation actually *plays* when the trigger is
touched. Samantha Reed is at `(971,-3991,-1284)`, roughly 2000 units south of and 1300
below the trigger at `(841,-2031,8)`, and Deus Ex needs its speakers present to run a
scene. UNK until someone walks it. If it fails, `Invoke Con` (section 8) will start the
conversation directly and tell you whether the scene itself works.

---

## 7. Flags — the complete L2 picture

Generated by `node tools/con_dump.js CNN/Conversations/OpheliaL2.con --flagmap`.

| Flag | Set by | Notes |
|---|---|---|
| `OnLevel2` | map `FlagTrigger` | PRECOND of `OpheliaHallway`; never set by any conversation |
| `ReadyForBossFight` | `GestureRight` | avatars turn hostile — designed, not a bug |
| `CanArmMagdalene` | `MagdaleneHijackTheStation` | **Hijacking** |
| `FinalGoodbyePlayed` | `MagdaleneInsideTube` | **the ending gate** |
| `MikeWongExposed` | `ContinueOn` | **Transcend** — unreachable, see section 6 |
| `SeedsOfDoubtPlanted` | `AccuseofBluffing` | **Transcend** — unreachable, see section 6 |
| `SamUnfriendly` | `mephcapt` | also CHECKed by `mephcapt`, `SamGivesQuest` |
| `WongParanoid` | `GiveUp` | |
| `ReadyForSocialBoss` | `TalkToPage` | PRECOND of `SocialBoss` |
| `HideJCHolo`, `HideMJ12TroopHolo`, `HideMeadHolo`, `HideUberAllesHolo` | `JCboss`, `CommCenterDispatcher`, `PhilipMeadHolo`, `UberAllesBriefing` | hologram staging |
| `AllObjectsDestroyed` | **the Docks**, `CNNDetonationTrigger.uc:37` | CHECK-only in L2 (by `SocialBoss`) — the one reason to enter L2 *through* L1 |
| `MetReedAndWong` | **nothing, anywhere** | PRECOND of `SamGivesQuest`. Searched all 6 `.con` files, all of `CNN/Classes/`, and the map. Polarity UNK — if it wants *true*, `SamGivesQuest` is dead |
| `IsArrivalPlayed`, `HideBobPageHolo` | — | declared, never referenced |

`PRECOND` polarity (wants true vs wants false) is **not recoverable** from the file format.
UNK. Treat it as "gated on this flag" and nothing more.

---

## 8. Fast path for testing

`CNNTestEnding hijack | transcend | conspiracy | mutiny` — an exec on `TantalusDenton`, no
cheats needed. It sets the accumulated-state flags for one ending; `CheckEndingReached()`
travels on the next tick (~1s).

It **bypasses reachability entirely**, which is why all four passed on 2026-08-16 while
Transcend was in fact unreachable in play. Use it to test the *endings*; use a real
playthrough plus `cnn log "CNN L2 flag"` to test the *routes*.

### The in-game debug menu — `Legend`

Deus Ex ships a developer menu. Console `Legend` (needs
`set cnn.tantalusdenton bcheatsenabled true` first) opens `BehindTheCurtain`:

| Button | What it does |
|---|---|
| **Edit Flags** | read and write any flag live — the interactive counterpart to `cnn log` |
| **Invoke Con** | pick an actor by `BindName`, see its conversations, see the flags each one references, and **start it directly** |
| **Load Map** | load any map from the MAPS directory |
| **Show Class** | display actors in the 3D scene |
| Add Dump / View Dumps | **teleport bookmarks**, not conversation dumps — the name collision is misleading |

**`Invoke Con` is the one to know for L2.** It lists conversations bound to actors that are
actually in the level, so it can start `MeetSamanthaReed` on demand — useful for testing
the Transcend scene independently of whether the repaired trigger fires.

**How it differs from `tools/con_dump.js`:** Invoke Con needs the game running with the
level loaded and cheats on, only sees conversations whose owner is present, and lists flag
*names* with no direction. `con_dump` reads the `.con` files offline, sees every record
including ones no live actor owns, labels each reference SET / CHECK / PRECOND / REF, and
its output can be diffed in git. Neither replaces the other — but note that Invoke Con
could not have found the inert trigger, because it inspects actor-bound conversations, not
triggers.
