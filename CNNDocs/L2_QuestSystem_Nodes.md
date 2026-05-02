# L2 QuestSystem — Canonical Node Table

**Source of truth:** [CNNDocs/Story/CNNL2StoryFlowchart.vsdx](Story/CNNL2StoryFlowchart.vsdx) (Visio 2013+, 127 shapes / 70 text-bearing / 138 connectors). Extracted directly from `visio/pages/page1.xml`.

**Companion:** [CNNDocs/Story/CNNStoryFlowchart.vsdx](Story/CNNStoryFlowchart.vsdx) is a slightly older variant (117 shapes) — see "Diffs vs companion variant" at bottom.

**Purpose:** machine-translatable node definitions for [QuestSystem.uc](../CNN/Classes/QuestSystem.uc). Each row maps directly to a `QuestNode` struct entry in the upcoming `defaultproperties` block.

**Conventions:**
- Visio shape `ID` is preserved as a column so this table cross-references the source 1:1
- Shape `Master`: 2=rounded box (event/outcome), 5=oval (ending), 6=hexagon (location/hub), 8=parallelogram (decision), 4=arrow/label
- `id` is `L2_<beat>` for story beats, `Ending_<name>` for leaves
- Reach condition uses `All:` (AND), `Any:` (OR), `Not:` (negation); flag names in `'singleQuotes'` are UE1 names

---

## ⚠ FIVE endings, not four

The Visio source shows **5 separate ending circles**, but the cnn.bat package list only has **4 ending maps** (`06_Mutiny`, `06_Conspiracy`, `06_Hijacking`, `06_Transcend`). Reconciliation needed:

| Visio ending | Color | Description (full text from Visio) | Probable map | Notes |
|---|---|---|---|---|
| Mutiny | orange | "Mutiny ending. Gray Goo consumes LA." | `06_Mutiny` | ✓ direct match |
| Conspiracy | red | "Conspiracy ending. Bob Page speaks with Tantalus. Mephistopheles is taken as a test subject to Versalife and has gone crazy (Mutiny!)" | `06_Conspiracy` | ✓ direct match |
| Hijack Ophelia | green | "Hijack Ophelia ending. Ophelia docks+L1 fall into the ocean as a fireball. Tantalus and Magdalene stand on the bridge looking at Mars." | `06_Hijacking` | ✓ direct match |
| **Benevolent Dictator** | blue | "Benevolent Dictator ending. Ophelia speaks to the world. MJ12's conspiracy is exposed. Tantalus and Magdalene are backed up and can use any avatar they want." | **probably `06_Transcend`** | maps overlap |
| **Transcendence** | blue (sad) | "Transcendence ending. UNATCO and JC patrol Avatar lab. Tantalus and Magdalene are hiding as ghosts in the network. Real Tantalus died (sad ending)." | **probably `06_Transcend`** | maps overlap |

**Open question #1**: do Benevolent Dictator and Transcendence share the `06_Transcend` map (with conv-driven flavor based on `PlayerDiedOnL2`)? Or is one of them missing a dedicated map? The 4 shipped ending maps suggest they share — Benevolent = good outcome on Transcend map; Transcendence (sad) = bad outcome on the same map. Confirm.

---

## Node table

### Phase 1 — Entry (Visio IDs 202, 201, 283)

| id | title | shape ID | reach condition | onReach | →children |
|---|---|---|---|---|---|
| L2_AtAirlock | At airlock | 202 | All: `EnteredOpheliaL2` | `L2_AtAirlock` | L2_AtHub |
| L2_AtHub | At Hub (after depressurize event) | 201 | All: `L2_DepressurizeComplete` | `L2_AtHub` | L2_JCHologramReceived |
| L2_JCHologramReceived | Tantalus listens to JC's hologram and receives endgame instructions from Page's avatar (says he's hiding in Mt Weather) | 283 | All: `L2_PageAvatarSpoken` | `L2_JCHologramReceived` | L2_MagdaleneShootsAvatar |

### Phase 2 — Command Center (Visio IDs 286, 204, 288, 206)

| id | title | shape ID | reach condition | onReach | →children |
|---|---|---|---|---|---|
| L2_MagdaleneShootsAvatar | Magdalene comes out and shoots Page's avatar with coil gun | 286 | All: `MagdaleneFiredCoilGun` | `L2_MagdaleneShootsAvatar` | L2_AtCommandCenter |
| L2_AtCommandCenter | At Command Center | 204 | All: `L2_AtCommandCenter` (entry) | `L2_AtCommandCenter` | L2_MJ12VsAvatarsBattle |
| L2_MJ12VsAvatarsBattle | MJ12 (mini crossbows) vs Avatars | 288 | All: `MJ12VsAvatarsBattleStarted` | `L2_MJ12VsAvatarsBattle` | L2_DoorsOpened |
| L2_DoorsOpened | Player opens doors to Avatar lab and Gravity Lab | 206 | All: `L2DoorsToLabsOpened` | `L2_DoorsOpened` | L2_AtGravityLab, **L2_TantalusMeetsOphelia** ¹ |

¹ Visio shows TWO outgoing edges from `Player opens doors`: one to `Gravity lab` (26), one to `Tantalus meets Ophelia` (257) labeled "On your way to Avatar Lab". Player can pursue both labs in any order.

### Phase 3 — Gravity Lab + Reed's Stateroom (Visio IDs 26, 23, 24, 292, 182, 12, 196)

| id | title | shape ID | reach condition | onReach | →children |
|---|---|---|---|---|---|
| L2_AtGravityLab | Gravity lab (hub for Wong/Samantha choice) | 26 | All: `L2_AtGravityLab` (entry) | `L2_AtGravityLab` | L2_WongLeavesSamantha, L2_SamanthaFollowsWong |
| L2_WongLeavesSamantha | Player convinces Wong to leave Samantha alone | 23 | All: `WongLeftSamanthaAlone` | `L2_WongLeavesSamantha` | L2_AtReedsStateroom (Samantha gives key) |
| L2_SamanthaFollowsWong | Player convinces Samantha to follow Wong | 24 | All: `SamanthaFollowedWong` | `L2_SamanthaFollowsWong` | **L2_WongSparesSamantha** ² |
| L2_AtReedsStateroom | At Reed's stateroom | 182 | All: `L2_WongLeavesSamantha` (only this branch grants the key) | `L2_AtReedsStateroom` | L2_SawWongVideo, L2_DaedalusOpenedBridge ³ |
| L2_SawWongVideo | Player saw video recording of Wong in Dr Reed's stateroom (proves Wong has his own motives) | 12 | All: `PlayerSawWongVideo` | `L2_SawWongVideo` | **L2_PlayerConvincesBetray** ⁴ |

² **Important**: in Visio, `Player convinces Samantha to follow Wong` directly leads to `Wong Spares Samantha`, BYPASSING social boss R1. So this Phase 3 choice immediately determines R1's outcome — if Samantha follows, Wong spares her without conv prompting.

³ Reed's stateroom has 2 outgoing edges in Visio: one to "Player saw video" (12), one to "Daedalus says he opened the door" (196). Both fire when player visits.

⁴ Saw Wong video unlocks the `Player tries to convince Wong to betray Mephistopheles` choice in Social boss R2. Without seeing video, only "Player tries to manipulate Wong" is available (and even that needs `PlayerKnowsChinese`).

### Phase 4 — The Bridge / Social Boss Fight (Visio IDs 178, 4, 192, 3, 32, 6, 292, 42, 13, 46, 16, 54, 59, 298, 18, 305, 51)

| id | title | shape ID | reach condition | onReach | →children |
|---|---|---|---|---|---|
| L2_AtBridge | The Bridge | 178 | All: `L2_AtBridge` (entry, after Daedalus opens door) | `L2_AtBridge` | L2_WongKillsMJ12Hostage |
| L2_WongKillsMJ12Hostage | Wong kills MJ12 troop hostage | 4 | All: `WongKilledMJ12Hostage` | `L2_WongKillsMJ12Hostage` | (decision: DestroyedDocksEvidence?) |
| L2_DocksEvidenceCheck | Player destroyed all evidence in the docks? **(decision)** | 192 | (always) | (none — branch only) | L2_MephSparesHostages (YES), L2_SocialBossR1 (NO) |
| L2_MephSparesHostages | Mephistopheles orders Wong to spare the hostages | 3 | All: `DestroyedDocksEvidence` | `HostagesAlive`, `L2_MephSparesHostages` | **L2_SocialBossR1** ⁵ |
| L2_SocialBossR1 | Social boss choice 1 | 32 | All: Not: `DestroyedDocksEvidence` (NO branch) **OR** All: `L2_MephSparesHostages` (YES branch) | `L2_SocialBossR1Active` | L2_WongKillsSamantha, L2_WongSparesSamantha, L2_PlayerGivesUp |
| L2_WongKillsSamantha | Wong kills Samantha (R1 outcome A) | 6 | All: `WongKilledSamantha` | `L2_SocialBossR1Done` | L2_SocialBossR2 |
| L2_WongSparesSamantha | Wong spares Samantha (R1 outcome B, OR set by `SamanthaFollowedWong`) | 292 | Any: `WongSparedSamantha`, `SamanthaFollowedWong` | `L2_SocialBossR1Done` | L2_SocialBossR2 |
| L2_SocialBossR2 | Social boss choice 2 | 42 | All: `L2_SocialBossR1Done` | `L2_SocialBossR2Active` | L2_PlayerManipulatesWong, L2_PlayerConvincesBetray, L2_PlayerGivesUp |
| L2_PlayerManipulatesWong | Player tries to manipulate Wong (R2 outcome A) | 13 | All: `PlayerKnowsChinese`, `PlayerManipulatedWong` ⁶ | `L2_R2Manipulate` | L2_WongKillsRandomHostage1 |
| L2_PlayerConvincesBetray | Player tries to convince Wong to betray Mephistopheles (R2 outcome B) | 46 | All: `PlayerSawWongVideo`, `PlayerConvincedBetray` | `L2_R2Betray` | L2_SocialBossR3 |
| L2_WongKillsRandomHostage1 | Wong kills one of two hostages at random (R2 manipulate) | 16 | All: `WongKilledRandomHostage1` | `L2_SocialBossR2Done` | L2_SocialBossR3 |
| L2_SocialBossR3 | Social boss choice 3 | 54 | All: `L2_SocialBossR2Done` | `L2_SocialBossR3Active` | L2_WongKillsRandomHostage2, L2_PlayerGivesUp |
| L2_WongKillsRandomHostage2 | Wong kills one of two hostages at random (R3) | 59 | All: `WongKilledRandomHostage2` | `L2_SocialBossR3Done` | L2_SocialBossR4, L2_PlayerConvincedSuicide |
| L2_SocialBossR4 | Social boss choice 4 | 298 | All: `L2_SocialBossR3Done` | `L2_SocialBossR4Active` | L2_PlayerGivesUp, L2_DaedalusKillsAvatar, L2_PlayerConvincedSuicide |
| L2_PlayerGivesUp | Player gives up (any round R1-R4 outcome — direct path to Mutiny) | 18 | All: `PlayerGaveUp` | `L2_PlayerGivesUp` | **Ending_Mutiny** ⁷ |
| L2_DaedalusKillsAvatar | Daedalus kills Tantalus' avatar (R4 outcome) | 305 | All: `DaedalusKilledAvatar` | `L2_DaedalusKillsAvatar` | **Ending_Mutiny** ⁷ |
| L2_PlayerConvincedSuicide | Player convinced Wong to kill Mephistopheles and commit suicide (R4 outcome) | 51 | All: `WongKilledMephAndSelf` | `L2_SocialBossCompleted` | L2_PageCongratsTantalus |

⁵ Visio shows `Mephistopheles orders Wong to spare hostages` → `Social boss choice 1` (does NOT skip the boss). The L2_QuestImplementation.txt prose says it DOES skip. Per the user's instruction (PDF/Visio is source of truth), the Visio interpretation wins: **the social boss still happens, but with hostages already spared**. Open question #2.

⁶ `Player tries to manipulate Wong` is gated by `PlayerKnowsChinese` per the Visio edge `1 → 13`. Without Chinese skill, this R2 option is locked.

⁷ Both `Player gives up` and `Daedalus kills Tantalus' avatar` directly route to Mutiny ending — confirmed by Visio edges `18 → 21` and `305 → 21`.

### Phase 5 — Post-Boss (Visio IDs 63, 69, 72, 74)

| id | title | shape ID | reach condition | onReach | →children |
|---|---|---|---|---|---|
| L2_PageCongratsTantalus | Page congratulates Tantalus and says MJ12 will be there in 3 minutes | 63 | All: `L2_SocialBossCompleted` | `L2_PageCongratsTantalus` | L2_HostagesAliveCheck |
| L2_HostagesAliveCheck | Any Hostages alive? **(decision)** | 69 | (always at this phase) | — | Ending_Conspiracy (YES) ⁸, L2_TimerStarts3Min (NO) |
| L2_TimerStarts3Min | Timer begins (3 min) | 72 | All: Not: `HostagesAlive` | `TimerActive` | L2_PlayerSpeaksMagdalene |
| L2_PlayerSpeaksMagdalene | Player speaks with Magdalene | 74 | All: `PlayerSpokeWithMagdalene` | `L2_PlayerSpeaksMagdalene` | L2_Undock (start hijack chain) |

⁸ The Visio edge `69 → 62 [LABEL: YES]` means **if hostages are alive, the Conspiracy ending fires immediately**. This contradicts the PDF/text doc interpretation that hostages-alive lets player continue to hijack. Open question #3.

### Phase 6 — Avatar Lab (Visio IDs 257, 186, 196, 263, 261, 268)

| id | title | shape ID | reach condition | onReach | →children |
|---|---|---|---|---|---|
| L2_TantalusMeetsOphelia | Tantalus meets Ophelia and receives endgame instructions | 257 | All: `TantalusMetOphelia` | `L2_TantalusMeetsOphelia` | L2_AtAvatarLab |
| L2_AtAvatarLab | At Avatar lab | 186 | All: `L2_AtAvatarLab` (entry) | `L2_AtAvatarLab` | L2_OpheliaCarrierBotGreets (after BobPage infolink) |
| L2_DaedalusOpenedBridge | Daedalus says he opened the door to the Bridge | 196 | All: `DaedalusOpenedBridgeDoor` | `L2_DaedalusOpenedBridge` | L2_AtBridge |
| L2_OpheliaCarrierBotGreets | Ophelia (avatar carrier bot) greets player; gives instructions to close door to Avatar Lab | 263 | All: `OpheliaCarrierBotGreeted` (after Bob Page infolink fires) | `L2_OpheliaCarrierBotGreets` | L2_MagdaleneOnMedBed |
| L2_MagdaleneOnMedBed | Magdalene sits on medical bed; Ophelia (medbot) gives Reizene; scans embryo (it is dead) | 261 | All: `MagdaleneScannedEmbryoDead` | `L2_MagdaleneOnMedBed` | L2_OpheliaShowsReedCarcass |
| L2_OpheliaShowsReedCarcass | Ophelia shows Megan Reed's carcass; says she uploaded herself; MagdaleneInsideTube starts | 268 | All: `OpheliaShowedReedCarcass` | `L2_OpheliaShowsReedCarcass` | L2_MagdaleneInTube1 |

### Phase 7 — Upload Sequence (Visio IDs 265, 271, 273, 275, 91, 95)

| id | title | shape ID | reach condition | onReach | →children |
|---|---|---|---|---|---|
| L2_MagdaleneInTube1 | Magdalene goes to Upload tube; player closes the tube from the console with a button; second tube opens | 265 | All: `Tube1ClosedTube2Opened` | `L2_MagdaleneInTube1` | L2_PlayerInTube2 |
| L2_PlayerInTube2 | Player walks into the second tube; teleports to same map as Tantalus' human server | 271 | All: `PlayerEnteredTube2` | `L2_PlayerInTube2` | L2_HumanServerOpens |
| L2_HumanServerOpens | Second tube closes; Tantalus' avatar carcass appears in tube; human server opens; human server has 0 health in both legs | 273 | All: `HumanServerOpened` | `L2_HumanServerOpens` | L2_PlayerCrawlsToAvatar |
| L2_PlayerCrawlsToAvatar | Player crawls; Ophelia-medbot can heal his legs; player comes to his avatar and has small dialog with himself | 275 | All: `PlayerReachedAvatar` | `L2_PlayerCrawlsToAvatar` | L2_PressUploadButton |
| L2_PressUploadButton | Presses button to start upload of Magdalene and Tantalus' avatar; "WalkingInTube" dialogue starts | 91 | All: `UploadButtonPressed` | `L2_PressUploadButton` | L2_AvatarsAttack_PageMonologue |
| L2_AvatarsAttack_PageMonologue | Avatars attack; upload timer starts; Page's face appears on window screens speaking about NSF/Tantalus/JC Denton | 95 | All: `UploadSequenceUnderway` | `L2_AvatarsAttack_PageMonologue` | L2_UploadTimerCheck |
| L2_UploadTimerCheck | Timer expired or player died? **(decision)** | 175 | (always) | — | Ending_Transcend (`Real Tantalus died (sad ending)` label), Ending_BenevolentDictator (`Timer expired` label) ⁹ |

⁹ Per Visio: edge `175 → 88 [LABEL: Timer expired]` → Benevolent Dictator. Edge `175 → 279 [LABEL: Real Tantalus died (sad ending)]` → Transcendence. So **Timer expired alone = Benevolent**, **Tantalus dead = Transcendence**. The "or" in the decision label means either branch path. Open question #4: which branch fires when BOTH are true?

### Hijack actions (parallel to Phases 5-7) (Visio IDs 76, 78, 80)

These three nodes fire in sequence in the Visio: `74 → 76 → 78 → 80 → 99`. The Hijack ending requires all three completed before the timer expires.

| id | title | shape ID | reach condition | onReach | →children |
|---|---|---|---|---|---|
| L2_Undock | Undock Level 2 from the rest of Ophelia | 76 | All: `UndockedL2` | `UndockedL2` | L2_StartBlueFusion |
| L2_StartBlueFusion | Start the Blue Fusion reactor (hack the keypad) | 78 | All: `StartedBlueFusion` | `StartedBlueFusion` | L2_TookSteeringWheel |
| L2_TookSteeringWheel | Take the steering wheel | 80 | All: `TookSteeringWheel` | `TookSteeringWheel` | L2_HijackTimerCheck |
| L2_HijackTimerCheck | Timer expired? **(decision)** | 99 | (always) | — | Ending_Conspiracy (YES) ¹⁰, Ending_Hijack (NO) |

¹⁰ The Visio shows two `Timer expired?` decision diamonds: one in the hijack path (99) and one in the upload path (175). They're SEPARATE timers — the 3-min countdown after Page's congratulation ends the hijack opportunity; a different timer governs the upload sequence outcome.

### Map exit trigger (Visio ID 254)

| id | title | shape ID | reach condition | onReach | →children |
|---|---|---|---|---|---|
| L2_PlayerEntersInfusionChamber | Player enters the infusion chamber → triggers MapExit | 254 | All: `PlayerInInfusionChamber` | `L2_PlayerEntersInfusionChamber` | (triggers QuestSystem.Update() → endings) |

### Endings (leaves) (Visio IDs 21, 62, 82, 88, 279)

| id | title | shape ID | reach condition | onReach | endMap |
|---|---|---|---|---|---|
| Ending_Mutiny | Mutiny ending. Gray Goo consumes LA. | 21 | Any: `PlayerDiedOnL2`, `L2_PlayerGivesUp`, `L2_DaedalusKillsAvatar`, (`PlayerEnteredInfusionChamber` & flag-mismatch fallback) ¹¹ | `IsGameCompleted` | `06_Mutiny` |
| Ending_Conspiracy | Conspiracy ending (Bob Page wins; Mephistopheles taken to Versalife as test subject, gone crazy) | 62 | Any: All: `HostagesAlive`, `PageCongratulatedPlayer` (immediate after Phase 5 if hostages alive); All: `TimerExpired`, Not: `UndockedL2` | `IsGameCompleted` | `06_Conspiracy` |
| Ending_Hijack | Hijack Ophelia ending (Ophelia docks+L1 fall; Tantalus & Magdalene on bridge looking at Mars) | 82 | All: `UndockedL2`, `StartedBlueFusion`, `TookSteeringWheel`, Not: `TimerExpired` | `IsGameCompleted` | `06_Hijacking` |
| Ending_BenevolentDictator | Benevolent Dictator ending (Ophelia speaks to world; MJ12 conspiracy exposed; Tantalus & Magdalene backed up) | 88 | All: `UploadSequenceUnderway`, `TimerExpired`, Not: `PlayerDiedDuringUpload` | `IsGameCompleted` | `06_Transcend` (likely) |
| Ending_Transcend | Transcendence ending (UNATCO + JC patrol Avatar lab; Tantalus & Magdalene as ghosts; Real Tantalus died — sad) | 279 | All: `UploadSequenceUnderway`, `PlayerDiedDuringUpload` | `IsGameCompleted` | `06_Transcend` (likely) |

¹¹ `Player enters infusion chamber → Mutiny` per the Visio edge `254 → 21`. This is the "fallback if nothing else matches" path. Implementation: when `MapExit` fires, the QuestSystem evaluates all leaf reach conditions; if none match, default to Mutiny.

---

## Side conditions (gates, not flow nodes)

These don't fire as nodes — they're flags read by reach conditions or conv-choice gating:

| flag | source | gates |
|---|---|---|
| `PlayerKnowsChinese` | `AiSkillChinese.uc` Master skill check (also visible as Visio shape ID 1, edge `1 → 13`) | `L2_PlayerManipulatesWong` (R2 outcome A) |
| `DestroyedDocksEvidence` | Set in Docks/L1 mission scripts | Phase 4 decision (`L2_DocksEvidenceCheck`) |
| `bChoseHostileToArmstrong` | Set by Docks conv | (not visible in L2 Visio — may gate dialogue tone in social boss only) |
| `HostagesAlive` | Computed by Chapter06L2 at Phase 5 entry from hostage NPC count | `L2_HostagesAliveCheck` decision |
| `TimerActive` | Set by `L2_TimerStarts3Min` | Watched by Chapter06L2 timer countdown |
| `TimerExpired` | Set when 3-min timer reaches 0 | `Ending_Conspiracy`, `Ending_Hijack` |
| `PlayerDiedOnL2` | Set in Chapter06L2 death handler (only if death happens BEFORE `L2_PressUploadButton`) | `Ending_Mutiny` |
| `PlayerDiedDuringUpload` | Set in Chapter06L2 death handler (only if death happens AFTER `L2_PressUploadButton`) | `Ending_Transcend` (sad path) |

---

## Flag dictionary

### External flags (set by code/conv/triggers outside QuestSystem)

| flag | set by | read by |
|---|---|---|
| `EnteredOpheliaL2` | Chapter06L2 InitStateMachine | `L2_AtAirlock` |
| `L2_DepressurizeComplete` | Map trigger after airlock anim | `L2_AtHub` |
| `L2_PageAvatarSpoken` | JC hologram + Page avatar conv | `L2_JCHologramReceived` |
| `MagdaleneFiredCoilGun` | Conv event / Magdalene NPC script | `L2_MagdaleneShootsAvatar` |
| `MJ12VsAvatarsBattleStarted` | Map trigger / NPC script | `L2_MJ12VsAvatarsBattle` |
| `L2DoorsToLabsOpened` | UseTrigger on player-operated doors | `L2_DoorsOpened` |
| `WongLeftSamanthaAlone` | Wong/Samantha conv (Gravity Lab) | `L2_WongLeavesSamantha` |
| `SamanthaFollowedWong` | Wong/Samantha conv (Gravity Lab) | `L2_SamanthaFollowsWong`, `L2_WongSparesSamantha` (Any) |
| `PlayerSawWongVideo` | UseTrigger on video screen | `L2_SawWongVideo`, `L2_PlayerConvincesBetray` |
| `WongKilledMJ12Hostage` | Bridge conv intro | `L2_WongKillsMJ12Hostage` |
| `DestroyedDocksEvidence` | Docks/L1 mission script | `L2_DocksEvidenceCheck` decision |
| `WongKilledSamantha` | Social boss conv R1 outcome | `L2_WongKillsSamantha` |
| `WongSparedSamantha` | Social boss conv R1 outcome | `L2_WongSparesSamantha` (Any with `SamanthaFollowedWong`) |
| `PlayerManipulatedWong` | Social boss conv R2 outcome A (only if `PlayerKnowsChinese`) | `L2_PlayerManipulatesWong` |
| `PlayerConvincedBetray` | Social boss conv R2 outcome B (only if `PlayerSawWongVideo`) | `L2_PlayerConvincesBetray` |
| `WongKilledRandomHostage1` | Social boss conv R2 → script picks random hostage | `L2_WongKillsRandomHostage1` |
| `WongKilledRandomHostage2` | Social boss conv R3 → script picks random hostage | `L2_WongKillsRandomHostage2` |
| `PlayerGaveUp` | Social boss conv any-round give-up choice | `L2_PlayerGivesUp` |
| `DaedalusKilledAvatar` | Social boss R4 outcome | `L2_DaedalusKillsAvatar` |
| `WongKilledMephAndSelf` | Social boss R4 outcome | `L2_PlayerConvincedSuicide` |
| `PageCongratulatedPlayer` | Page conv after social boss | `L2_PageCongratsTantalus` |
| `HostagesAlive` | Computed by Chapter06L2 from hostage actor count at Phase 5 entry | `L2_HostagesAliveCheck` |
| `PlayerSpokeWithMagdalene` | Magdalene conv | `L2_PlayerSpeaksMagdalene` |
| `BobPageInfolinkPlayed` | Datalink trigger | (gates `L2_OpheliaCarrierBotGreets` reach) |
| `TantalusMetOphelia` | Ophelia conv | `L2_TantalusMeetsOphelia` |
| `DaedalusOpenedBridgeDoor` | Daedalus conv at Avatar Lab | `L2_DaedalusOpenedBridge` |
| `OpheliaCarrierBotGreeted` | Ophelia carrier bot conv | `L2_OpheliaCarrierBotGreets` |
| `MagdaleneScannedEmbryoDead` | Ophelia medbot conv | `L2_MagdaleneOnMedBed` |
| `OpheliaShowedReedCarcass` | Ophelia conv (Reed carcass) | `L2_OpheliaShowsReedCarcass` |
| `Tube1ClosedTube2Opened` | Console-button UseTrigger | `L2_MagdaleneInTube1` |
| `PlayerEnteredTube2` | TouchTrigger inside tube 2 | `L2_PlayerInTube2` |
| `HumanServerOpened` | Scripted sequence on human-server map | `L2_HumanServerOpens` |
| `PlayerReachedAvatar` | TouchTrigger near avatar | `L2_PlayerCrawlsToAvatar` |
| `UploadButtonPressed` | UseTrigger on upload button | `L2_PressUploadButton` |
| `UploadSequenceUnderway` | First frame after button press | `L2_AvatarsAttack_PageMonologue`, both upload endings |
| `UndockedL2` | UseTrigger on Undock button | `L2_Undock`, ending conditions |
| `StartedBlueFusion` | UseTrigger on hacked keypad | `L2_StartBlueFusion`, `Ending_Hijack` |
| `TookSteeringWheel` | UseTrigger on steering wheel | `L2_TookSteeringWheel`, `Ending_Hijack` |
| `TimerExpired` | Chapter06L2 countdown | `L2_HijackTimerCheck`, ending exclusions |
| `PlayerDiedOnL2` | Chapter06L2 death handler (death BEFORE `L2_PressUploadButton`) | `Ending_Mutiny` |
| `PlayerDiedDuringUpload` | Chapter06L2 death handler (death AFTER `L2_PressUploadButton`) | `Ending_Transcend` |
| `PlayerInInfusionChamber` | TouchTrigger on infusion chamber entry | `L2_PlayerEntersInfusionChamber` |
| `PlayerKnowsChinese` | `AiSkillChinese.uc` Master check | `L2_PlayerManipulatesWong` |
| `IsGameCompleted` | Set by `QuestSystem.EndQuestPath()` | Existing termination signal |

---

## Open questions

These need decisions before Phase 1 implementation starts:

1. **Benevolent Dictator vs Transcendence map mapping.** Both are blue endings in Visio, but only `06_Transcend` exists. Confirm both share `06_Transcend` (with conv flavor based on `PlayerDiedDuringUpload` flag), OR a new `06_BenevolentDictator` map needs creation.
2. **Mephistopheles-spares-hostages branch.** Visio shows it leading to `Social boss choice 1`. L2_QuestImplementation.txt prose says it skips the social boss. Visio is source of truth → social boss still happens with hostages already spared. Confirm.
3. **Hostages-alive → Conspiracy ending.** Visio's `69 → 62 [YES]` says hostages-alive immediately = Conspiracy ending. L2_QuestImplementation.txt says hostages-alive lets player skip the timer and go to hijack. **This is a conflict.** Which is correct?
4. **Upload-phase ending priority.** Both `TimerExpired` and `PlayerDiedDuringUpload` could be true. Per Visio labels: timer-expired alone → Benevolent; player-died → Transcendence. Confirm: if both, does death take priority (Transcendence wins)?
5. **`PlayerDiedOnL2` vs `PlayerDiedDuringUpload`.** The Visio shows ONE "Player dies at any time on Level2" box, but the Mutiny/Transcendence split implies these need to be separate flags. The Chapter06L2 death handler must check whether `L2_PressUploadButton` has fired and set the appropriate flag. Confirm this design.
6. **`Player attacks Mephistopheles and Wong`.** This node exists in `CNNStoryFlowchart.vsdx` (the older companion file) but NOT in `CNNL2StoryFlowchart.vsdx`. Was this option deliberately cut, or should it be reinstated as an R3/R4 outcome?
7. **R1/R2/R3 give-up paths.** Visio shows `Player gives up` reachable from R1, R2, R3, AND R4 — every round has a give-up exit, all leading directly to Mutiny ending. Confirm that "give up" at R1 ends the game with Mutiny (not just continues to next round).
8. **Reed's stateroom only via Wong-leaves-Samantha branch.** Visio shows `SamanthaFollowsWong` does NOT lead to Reed's stateroom (that branch goes directly to `Wong Spares Samantha`). So if player picks "Samantha follows Wong" in Phase 3, they can't see the Wong video and `PlayerConvincesBetray` (R2 outcome B) is locked. Is that intentional?

---

## Diffs vs companion variant `CNNStoryFlowchart.vsdx`

The older companion file (`CNNStoryFlowchart.vsdx`, 117 shapes) differs from the canonical L2 file in three ways:

1. **Hostage count**: companion says "one of THREE hostages at random", canonical says "one of TWO hostages at random". Affects `WongKillsRandomHostage1/2` outcome semantics — does Wong kill from a pool of 2 or 3? Probably 2 (recent revision).
2. **Extra R-something option**: companion has a `Player attacks Mephistopheles and Wong` choice, canonical doesn't. Cut content.
3. **Connection differences**: minor topology drift; canonical is cleaner.

**Recommendation**: use canonical `CNNL2StoryFlowchart.vsdx` exclusively for implementation. Reference the companion only if filling design gaps.

---

## Translation guarantee

If every "Open question" above is resolved, this document is sufficient input for Phase 1 to produce concrete `defaultproperties` for `QuestSystem.uc` with no further design decisions.

Phase 5 (social boss conv) reads the **External flags** table as its task list — every flag with "Social boss conv" as its source is a `SetFlag` event the conv must contain.
