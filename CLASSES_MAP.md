# CNN/Classes — Class Atlas

This document catalogs all 267 UnrealScript classes from Codename Nebula: 266 in [CNN/Classes/](CNN/Classes/) and 1 in [CNNText/Classes/](CNNText/Classes/). Sister document to [REPO_MAP.md](REPO_MAP.md) and [Phase5_6_Audit.md](Phase5_6_Audit.md). Reachability verified across four dimensions (the four blind spots that broke Phase 5 are listed in the Methodology section at the bottom).

**Phase 8A status (added 2026-04-25):** 12 classes had their `Mesh=` references re-pointed from `'ApocalypseInside.X'` to `'CNN.X'`. Affected: BassGuitar, Bassein, CoffeeCup, CoffeeMachine, ObserX, Pallet, Pipe619/994/996/998, ShopCart, wallfuse8. Reachability tags unchanged — the assets are now sourced from the local `CNN.u` package instead of the external `ApocalypseInside.u`. 21 `ApocalypseInside.X` refs remain (Burger01 + fries01 meshes + 15 textures + 3 map embeddings) — see [Phase8_ApocalypseInside_Survey.md](Phase8_ApocalypseInside_Survey.md) for the path to full standalone.

## Quick reference

- **Total classes:** 266 (CNN/Classes) + 1 (CNNText/Classes) = **267**
- **Entry points (ROOT):** [CNNGameInfo](CNN/Classes/CNNGameInfo.uc) (DefaultGame), [TantalusDenton](CNN/Classes/TantalusDenton.uc) (player class), [CNNRootWindow](CNN/Classes/CNNRootWindow.uc) / [CNNHUD](CNN/Classes/CNNHUD.uc) (UI), [CNNMenuMainTest](CNN/Classes/CNNMenuMainTest.uc) (root menu → ApocalypseInsideMenu* chain)
- **Canonical importers:** [ImportConversations](CNN/Classes/ImportConversations.uc), [ImportSounds](CNN/Classes/ImportSounds.uc), [AllCnnResources](CNN/Classes/AllCnnResources.uc), [CNNTextures](CNN/Classes/CNNTextures.uc), [CNNTextImport](CNNText/Classes/CNNTextImport.uc)
- **UNREACHABLE classes after Phase 5+7 cleanup:** **0** (every class is reachable through at least one path; see Methodology)

## Class hierarchy snapshot

```
Actor (DeusEx/Engine root)
├── CNNActor (custom base for some CNN actors)
├── MissionScript / CNNBaseIngameCutscene
│   ├── Chapter05 / Chapter06 / CNNChapter06
│   ├── CNNMisson01
│   ├── MissionMoonIntro / MissionDocks / MissionIntroTest
│   └── Chapter06L1 / Chapter06L2
├── DeusExGameInfo → CNNGameInfo (ROOT)
├── JCDentonMale → TantalusDenton (ROOT player class)
├── ScriptedPawn / CNNCivilian / CNNMilitary
│   ├── 20+ named NPCs (Magdalene, OpheliaUI, CaptainValiante, …)
│   └── Holo variants (UberAllesHolo, JCDoubleHolo, BobPageHolo, …)
├── DeusExWeapon → 5 custom weapons (CoilGun, AvatarBite, UPSMelee, Microwave, Snowblind)
├── Augmentation → 2 custom (AugSkullGunLethal/NonLethal)
├── Skill → CNNSkill → 6 (Bionics, Chinese, French, Piloting, Computer, base)
├── AugmentationManager / SkillManager → AiAugmentationManager / AiSkillManager
├── Trigger / CNNTrigger / CNNSimpleTrigger → 30+ trigger variants
├── Dispatcher → CnnDispatcher / CnnDispatcher32 / CNNEventDispatcher
├── DeusExMover → CNNMover → MoverMetal
├── DeusExDecoration / CNNDeco / AIDeco → 25+ decorations
├── Containers → 11 barrel/box/cannister variants + BodyBox
├── DeusExCarcass / CNNCarcass → 8 carcass variants + 9 *Evidence boxes
├── MenuMain / MenuUIMenuWindow → CNNMenuMainTest (ROOT) → ApocalypseInsideMenu* chain
├── DeusExRootWindow → CNNRootWindow (ROOT)
├── DeusExHUD → CNNHUD (ROOT) + 11 IwHUD* widgets
├── ConPlay / ConEventAnimation → 6 conversation playback variants
└── Object (abstract) → 27 import declaration stubs (DecoX templates) + 6 importers
```

---

## 1. Game core

| Class | Extends | Role | Reachability |
|---|---|---|---|
| [CNNGameInfo](CNN/Classes/CNNGameInfo.uc) | DeusExGameInfo | Game rules entry — `DefaultGame=CNN.CNNGameInfo` in CNN.ini | ROOT |
| [TantalusDenton](CNN/Classes/TantalusDenton.uc) | JCDentonMale | Player character with quest/aug hooks | ROOT |
| [CNNRootWindow](CNN/Classes/CNNRootWindow.uc) | DeusExRootWindow | Root UI window | ROOT |
| [CNNHUD](CNN/Classes/CNNHUD.uc) | DeusExHUD | Custom HUD with damage/info-link/active-items | ROOT |
| [CNNMenuMainTest](CNN/Classes/CNNMenuMainTest.uc) | MenuMain | Main menu → invokes ApocalypseInsideMenuSelectDifficulty | ROOT |
| [CNNCreditsWindow](CNN/Classes/CNNCreditsWindow.uc) | CreditsWindow | Custom credits screen (invoked by main menu) | REACHABLE-CODE |

## 2. Mission / Quest system

| Class | Extends | Role | Reachability |
|---|---|---|---|
| [QuestSystem](CNN/Classes/QuestSystem.uc) | Actor | Quest tracking & progression (used by TantalusDenton) | REACHABLE-CODE |
| [CNNBaseIngameCutscene](CNN/Classes/CNNBaseIngameCutscene.uc) | MissionScript | Abstract base for cutscenes/orchestration | REACHABLE-CODE |
| [Chapter05](CNN/Classes/Chapter05.uc) | CNNBaseIngameCutscene | Chapter 5 mission handler (aug requirement checks) | REACHABLE-CODE |
| [Chapter06](CNN/Classes/Chapter06.uc) | CNNBaseIngameCutscene | Chapter 6 OpheliaDocks handler | REACHABLE-CODE |
| [CNNChapter06](CNN/Classes/CNNChapter06.uc) | MissionScript | Alternative Chapter 6 handler | REACHABLE-CODE |
| [Chapter06L1](CNN/Classes/Chapter06L1.uc) | MissionScript | Chapter 6 Level 1 handler | REACHABLE-CODE |
| [Chapter06L2](CNN/Classes/Chapter06L2.uc) | MissionScript | Chapter 6 Level 2 handler | REACHABLE-CODE |
| [CNNMisson01](CNN/Classes/CNNMisson01.uc) | CNNBaseIngameCutscene | Mission 1 variant (note: typo "Misson") | REACHABLE-CODE |
| [CNNMissionEndgame](CNN/Classes/CNNMissionEndgame.uc) | MissionEndgame | Endgame orchestration | REACHABLE-CODE |
| [MissionDocks](CNN/Classes/MissionDocks.uc) | MissionScript | Docks mission | REACHABLE-CODE |
| [MissionIntroTest](CNN/Classes/MissionIntroTest.uc) | MissionScript | Intro mission test | REACHABLE-CODE |
| [MissionMoonIntro](CNN/Classes/MissionMoonIntro.uc) | MissionScript | Moon intro (references MoonCNN.con) | REACHABLE-CODE |
| [TestIngameCutscene](CNN/Classes/TestIngameCutscene.uc) | MissionScript | Test cutscene | REACHABLE-CODE |

## 3. NPCs / Pawns / Avatars

| Class | Extends | Role | Reachability |
|---|---|---|---|
| [Avatar](CNN/Classes/Avatar.uc) | Male1 | Custom player avatar | REACHABLE-CODE |
| [BPAvatar](CNN/Classes/BPAvatar.uc) | Avatar | Blueprint/variant avatar | REACHABLE-CODE |
| [JCAvatar](CNN/Classes/JCAvatar.uc) | JCDouble | JC Denton avatar variant | REACHABLE-CODE |
| [AvatarGenerator](CNN/Classes/AvatarGenerator.uc) | PawnGenerator | Spawns Avatar instances | REACHABLE-CODE |
| [AvatarCarcass](CNN/Classes/AvatarCarcass.uc) | TestFMCarcass | Avatar death corpse | REACHABLE-CODE |
| [CNNUPS](CNN/Classes/CNNUPS.uc) | CNNDog | UPS creature | REACHABLE-CODE |
| [SilentUPS](CNN/Classes/SilentUPS.uc) | CNNUPS | Silent UPS variant | REACHABLE-CODE |
| [CNNCivilian](CNN/Classes/CNNCivilian.uc) | ScriptedPawn | Base civilian NPC (abstract) | REACHABLE-CODE |
| [CNNMilitary](CNN/Classes/CNNMilitary.uc) | ScriptedPawn | Base military NPC (abstract) | REACHABLE-CODE |
| [CorpArmstrong](CNN/Classes/CorpArmstrong.uc) | CNNMilitary | Corp Armstrong | REACHABLE-CODE |
| [DrJohnson](CNN/Classes/DrJohnson.uc) | CNNCivilian | Dr. Johnson | REACHABLE-CODE |
| [Magdalene](CNN/Classes/Magdalene.uc) | Female1 | Magdalene character | REACHABLE-CODE |
| [MagdaleneDenton](CNN/Classes/MagdaleneDenton.uc) | Magdalene | Magdalene/Denton state | REACHABLE-CODE |
| [OpheliaUI](CNN/Classes/OpheliaUI.uc) | Secretary | Ophelia UI character (NPC) | REACHABLE-CODE |
| [CaptainValiante](CNN/Classes/CaptainValiante.uc) | Sailor | Captain Valiante | REACHABLE-CODE |
| [MikeWong](CNN/Classes/MikeWong.uc) | Sailor | Mike Wong | REACHABLE-CODE |
| [SamanthaReed](CNN/Classes/SamanthaReed.uc) | ScientistFemale | Samantha Reed | REACHABLE-CODE |
| [DoctorIsaac](CNN/Classes/DoctorIsaac.uc) | ScientistMale | Doctor Isaac | REACHABLE-CODE |
| [DrCharlesMonroe](CNN/Classes/DrCharlesMonroe.uc) | Doctor | Dr. Charles Monroe | REACHABLE-CODE |
| [CNNBurningScientist](CNN/Classes/CNNBurningScientist.uc) | ScientistMale | Burning scientist | REACHABLE-CODE |
| [Pagan](CNN/Classes/Pagan.uc) | CNNBurningScientist | Pagan (refs DrIsaacCarcass) | REACHABLE-CODE |
| [UberAlles](CNN/Classes/UberAlles.uc) | MIB | UberAlles MIB agent | REACHABLE-CODE |
| [UberAllesHolo](CNN/Classes/UberAllesHolo.uc) | UberAlles | Holographic UberAlles | REACHABLE-CODE |
| [AnnaNavarreAi](CNN/Classes/AnnaNavarreAi.uc) | AnnaNavarre | Anna Navarre AI variant | REACHABLE-CODE |
| [MJ12TroopHolo](CNN/Classes/MJ12TroopHolo.uc) | MJ12Troop | MJ12 Troop hologram | REACHABLE-CODE |
| [JCDoubleHolo](CNN/Classes/JCDoubleHolo.uc) | JCDouble | JC Denton hologram | REACHABLE-CODE |
| [BobPageHolo](CNN/Classes/BobPageHolo.uc) | BobPage | Bob Page hologram | REACHABLE-CODE |
| [PhilipMeadHolo](CNN/Classes/PhilipMeadHolo.uc) | PhilipMead | Philip Mead hologram | REACHABLE-CODE |
| [TantalusNPC](CNN/Classes/TantalusNPC.uc) | JCDouble | Generic Tantalus NPC | REACHABLE-CODE |
| [CNNDog](CNN/Classes/CNNDog.uc) | Dog | Custom dog variant | REACHABLE-CODE |
| [UnknownParanormalShit](CNN/Classes/UnknownParanormalShit.uc) | Doberman | Unidentified creature | REACHABLE-CODE |
| [CNNBlinkingActor](CNN/Classes/CNNBlinkingActor.uc) | Male1 | Male char with blinking anim | REACHABLE-CODE |
| [GrayNonRadioactive](CNN/Classes/GrayNonRadioactive.uc) | Animal | Non-radioactive creature | REACHABLE-CODE |

## 4. Conversation system

| Class | Extends | Role | Reachability |
|---|---|---|---|
| [ImportConversations](CNN/Classes/ImportConversations.uc) | Object | Canonical conversation importer (`#exec CONVERSATION IMPORT` for 6 .con files) | ROOT |
| [CNNConPlay](CNN/Classes/CNNConPlay.uc) | ConPlay | CNN conversation play handler | REACHABLE-CODE |
| [CNNConEventAnimation](CNN/Classes/CNNConEventAnimation.uc) | ConEvent | CNN conversation event animation | REACHABLE-CODE |
| [AiConPlay](CNN/Classes/AiConPlay.uc) | ConPlay | Alternative conversation play | REACHABLE-CODE |
| [AiConEventAnimation](CNN/Classes/AiConEventAnimation.uc) | ConEventAnimation | Alternative event animation | REACHABLE-CODE |
| [MyConPlay](CNN/Classes/MyConPlay.uc) | ConPlay | Custom conversation play variant | REACHABLE-CODE |
| [MyConEventAnimation](CNN/Classes/MyConEventAnimation.uc) | ConEventAnimation | Custom event animation | REACHABLE-CODE |
| [AiDataLinkPlay](CNN/Classes/AiDataLinkPlay.uc) | DataLinkPlay | Datalink conversation player | REACHABLE-CODE |
| [AiHUDInfoLinkDisplay](CNN/Classes/AiHUDInfoLinkDisplay.uc) | HUDInfoLinkDisplay | HUD info-link display handler | REACHABLE-CODE |

## 5. Augmentations & Skills

| Class | Extends | Role | Reachability |
|---|---|---|---|
| [AugSkullGunLethal](CNN/Classes/AugSkullGunLethal.uc) | Augmentation | Lethal skull gun aug (in AiAugmentationManager defaults) | REACHABLE-CODE |
| [AugSkullGunNonLethal](CNN/Classes/AugSkullGunNonLethal.uc) | Augmentation | Non-lethal skull gun aug | REACHABLE-CODE |
| [CNNSkill](CNN/Classes/CNNSkill.uc) | Skill | Base custom skill class | REACHABLE-CODE |
| [AiSkillBionics](CNN/Classes/AiSkillBionics.uc) | CNNSkill | Bionics skill | REACHABLE-CODE |
| [AiSkillChinese](CNN/Classes/AiSkillChinese.uc) | CNNSkill | Chinese language skill | REACHABLE-CODE |
| [AiSkillFrench](CNN/Classes/AiSkillFrench.uc) | CNNSkill | French language skill | REACHABLE-CODE |
| [AiSkillComputer](CNN/Classes/AiSkillComputer.uc) | SkillComputer | Computer hacking skill variant | REACHABLE-CODE |
| [AiSkillPiloting](CNN/Classes/AiSkillPiloting.uc) | CNNSkill | Piloting skill | REACHABLE-CODE |
| [AiAugmentationManager](CNN/Classes/AiAugmentationManager.uc) | AugmentationManager | Aug manager (spawned by TantalusDenton) | REACHABLE-CODE |
| [AiSkillManager](CNN/Classes/AiSkillManager.uc) | SkillManager | Skill manager | REACHABLE-CODE |
| [ChineseSkillController](CNN/Classes/ChineseSkillController.uc) | Actor | Chinese skill state monitor (spawned by TantalusDenton) | REACHABLE-CODE |

## 6. Weapons / Ammo / Projectiles

| Class | Extends | Role | Reachability |
|---|---|---|---|
| [CNNWeaponAvatarBite](CNN/Classes/CNNWeaponAvatarBite.uc) | WeaponSword | Avatar melee bite | REACHABLE-CODE |
| [CNNWeaponCoilGun](CNN/Classes/CNNWeaponCoilGun.uc) | GaussGun.WeaponGaussGun | Custom coil gun | REACHABLE-CODE |
| [CNNWeaponUPSMelee](CNN/Classes/CNNWeaponUPSMelee.uc) | WeaponNPCMelee | UPS melee weapon | REACHABLE-CODE |
| [CNNUPSWeapon](CNN/Classes/CNNUPSWeapon.uc) | WeaponDogBite | UPS bite (used by CNNUPS) | REACHABLE-CODE |
| [WeaponMicrowaveGun](CNN/Classes/WeaponMicrowaveGun.uc) | DeusExWeapon | Microwave gun | REACHABLE-CODE |
| [WeaponSnowblind](CNN/Classes/WeaponSnowblind.uc) | DeusExWeapon | Snowblind grenade-like weapon | REACHABLE-CODE |
| [AmmoPlasma2](CNN/Classes/AmmoPlasma2.uc) | DeusExAmmo | Plasma ammunition variant | REACHABLE-CODE |
| [PlasmaBolt2](CNN/Classes/PlasmaBolt2.uc) | DeusExProjectile | Plasma bolt projectile | REACHABLE-CODE |

## 7. Decorations & Items

| Class | Extends | Role | Reachability |
|---|---|---|---|
| [CNNDeco](CNN/Classes/CNNDeco.uc) | DeusExDecoration | Base CNN decoration (abstract) | REACHABLE-CODE |
| [AIDeco](CNN/Classes/AIDeco.uc) | DeusExDecoration | Alternative decoration base | REACHABLE-CODE |
| [BassGuitar](CNN/Classes/BassGuitar.uc) | AIDeco | Bass guitar | REACHABLE-CODE |
| [Bassein](CNN/Classes/Bassein.uc) | AIDeco | Basin | REACHABLE-CODE |
| [ShopCart](CNN/Classes/ShopCart.uc) | AIDeco | Shopping cart | REACHABLE-CODE |
| [Pipe619](CNN/Classes/Pipe619.uc), [Pipe994](CNN/Classes/Pipe994.uc), [Pipe996](CNN/Classes/Pipe996.uc), [Pipe998](CNN/Classes/Pipe998.uc) | AIDeco | Pipe variants | REACHABLE-CODE |
| [ObserX](CNN/Classes/ObserX.uc) | AIDeco | Observer X | REACHABLE-CODE |
| [pallet](CNN/Classes/pallet.uc) | AIDeco | Pallet | REACHABLE-CODE |
| [wallfuse8](CNN/Classes/wallfuse8.uc) | AIDeco | Wall fuse | REACHABLE-CODE |
| [Candle1](CNN/Classes/Candle1.uc) | CNNDeco | Candle | REACHABLE-CODE |
| [IVUnit](CNN/Classes/IVUnit.uc) | CNNDeco | IV unit | REACHABLE-CODE |
| [Button1B](CNN/Classes/Button1B.uc) | DeusExDecoration | Button | REACHABLE-CODE |
| [KarkianEgg](CNN/Classes/KarkianEgg.uc) | DeusExDecoration | Karkian egg | REACHABLE-CODE |
| [GlassBottle](CNN/Classes/GlassBottle.uc) | DeusExDecoration | Glass bottle | REACHABLE-CODE |
| [HandDry](CNN/Classes/HandDry.uc) | DeusExDecoration | Hand dryer | REACHABLE-CODE |
| [ToiletPaper](CNN/Classes/ToiletPaper.uc) | DeusExDecoration | Toilet paper | REACHABLE-CODE |
| [TowelRack](CNN/Classes/TowelRack.uc) | DeusExDecoration | Towel rack | REACHABLE-CODE |
| [Sinks](CNN/Classes/Sinks.uc) | DeusExDecoration | Sink (abstract) | REACHABLE-CODE |
| [SinkSmall](CNN/Classes/SinkSmall.uc), [SinkMedium](CNN/Classes/SinkMedium.uc) | Sinks | Sink size variants | REACHABLE-CODE |
| [GrateWindow](CNN/Classes/GrateWindow.uc) | Decoration | Grate window (used by AllCnnResources `#forceexec`) | REACHABLE-CODE |
| [IlluminatorProtectionHalf](CNN/Classes/IlluminatorProtectionHalf.uc) | Decoration | Illuminator protection | REACHABLE-CODE |
| [Burger](CNN/Classes/Burger.uc), [Fries](CNN/Classes/Fries.uc), [NoodleCup](CNN/Classes/NoodleCup.uc) | DeusExPickup | Food items | REACHABLE-CODE |
| [CoffeeCup](CNN/Classes/CoffeeCup.uc) | DeusExPickup | Coffee cup (referenced in TantalusDenton) | REACHABLE-CODE |
| [RamenNoodles](CNN/Classes/RamenNoodles.uc) | SoyFood | Ramen noodles | REACHABLE-CODE |
| [VoiceTape](CNN/Classes/VoiceTape.uc) | InformationDevices | Voice recording | REACHABLE-CODE |
| [Magazine](CNN/Classes/Magazine.uc) | InformationDevices | Magazine | REACHABLE-CODE |
| [Folder](CNN/Classes/Folder.uc), [FolderOpen](CNN/Classes/FolderOpen.uc) | InformationDevices | Folder (closed/open) | REACHABLE-CODE |
| [ClipBoard](CNN/Classes/ClipBoard.uc) | InformationDevices | Clipboard | REACHABLE-CODE |
| [CoffeeMachine](CNN/Classes/CoffeeMachine.uc) | ElectronicDevices | Coffee machine | REACHABLE-CODE |
| [MyFireExtinguisher](CNN/Classes/MyFireExtinguisher.uc) | FireExtinguisher | Custom fire extinguisher | REACHABLE-CODE |

### Abstract decoration import templates (Object-extending stubs)

These exist as `class X extends Object` import declarations paired with their concrete `Barrel*`/`Box*`/`Item*` counterparts in section 8.

| Template | Concrete container/item |
|---|---|
| [DecoBarrel2](CNN/Classes/DecoBarrel2.uc), [DecoBarrel3](CNN/Classes/DecoBarrel3.uc), [DecoBarrelGas](CNN/Classes/DecoBarrelGas.uc), [DecoBarrelToxic](CNN/Classes/DecoBarrelToxic.uc) | Barrel2 / Barrel3 / BarrelGas / BarrelToxic |
| [DecoBoardBoxSmall](CNN/Classes/DecoBoardBoxSmall.uc) | BoardBoxSmall |
| [DecoCannister](CNN/Classes/DecoCannister.uc), [DecoChemicalCannister](CNN/Classes/DecoChemicalCannister.uc) | Cannister / ChemicalCannister |
| [DecoCautionBox](CNN/Classes/DecoCautionBox.uc), [DecoCrateExplosiveMed](CNN/Classes/DecoCrateExplosiveMed.uc) | CautionBox / CrateExplosiveMed |
| [DecoGasCan](CNN/Classes/DecoGasCan.uc) | GasCan |
| [DecoButton1B](CNN/Classes/DecoButton1B.uc), [DecoCandle1](CNN/Classes/DecoCandle1.uc), [DecoClipBoard](CNN/Classes/DecoClipBoard.uc), [DecoFolders](CNN/Classes/DecoFolders.uc), [DecoGlassBottle](CNN/Classes/DecoGlassBottle.uc), [DecoHandDry](CNN/Classes/DecoHandDry.uc), [DecoIV](CNN/Classes/DecoIV.uc), [DecoKarkianEgg](CNN/Classes/DecoKarkianEgg.uc), [DecoMagazine](CNN/Classes/DecoMagazine.uc), [DecoSinks](CNN/Classes/DecoSinks.uc), [DecoToiletPaper](CNN/Classes/DecoToiletPaper.uc), [DecoTowelRack](CNN/Classes/DecoTowelRack.uc), [DecoAmmoPlasma2](CNN/Classes/DecoAmmoPlasma2.uc) | Decoration import stubs (pair with concrete classes above) |

All REACHABLE-CODE — referenced via `#exec` directives at compile time.

## 8. Containers / Carcasses / Evidence

| Class | Extends | Role | Reachability |
|---|---|---|---|
| [Barrel2](CNN/Classes/Barrel2.uc), [Barrel3](CNN/Classes/Barrel3.uc), [BarrelGas](CNN/Classes/BarrelGas.uc), [BarrelToxic](CNN/Classes/BarrelToxic.uc) | Containers | Barrel containers | REACHABLE-CODE |
| [BoardBoxSmall](CNN/Classes/BoardBoxSmall.uc) | Containers | Small board box | REACHABLE-CODE |
| [Cannister](CNN/Classes/Cannister.uc), [ChemicalCannister](CNN/Classes/ChemicalCannister.uc) | Containers | Cannister variants | REACHABLE-CODE |
| [CautionBox](CNN/Classes/CautionBox.uc), [CrateExplosiveMed](CNN/Classes/CrateExplosiveMed.uc) | Containers | Hazard containers | REACHABLE-CODE |
| [GasCan](CNN/Classes/GasCan.uc) | Containers | Gas can | REACHABLE-CODE |
| [BodyBox](CNN/Classes/BodyBox.uc) | Containers | Body box — **148 hits** in `.con` files (OpheliaDocksAndL1 + OpheliaL2ArmMagdalene) | REACHABLE-CON |
| [CNNCarcass](CNN/Classes/CNNCarcass.uc) | DeusExCarcass | Base CNN corpse | REACHABLE-CODE |
| [CArmstrongAliveCarcass](CNN/Classes/CArmstrongAliveCarcass.uc), [CArmstrongDeadCarcass](CNN/Classes/CArmstrongDeadCarcass.uc) | (CNN)Carcass | Corp Armstrong corpses (alive/dead states) | REACHABLE-CODE |
| [MagdaleneCarcass](CNN/Classes/MagdaleneCarcass.uc) | CNNCarcass | Magdalene corpse | REACHABLE-CODE |
| [DrIsaacCarcass](CNN/Classes/DrIsaacCarcass.uc) | DeusExCarcass | Dr. Isaac corpse (used by Pagan) | REACHABLE-CODE |
| [CaptainValianteCarcass](CNN/Classes/CaptainValianteCarcass.uc) | DeusExCarcass | Captain Valiante corpse | REACHABLE-CODE |
| [MJ12TroopFMCarcass](CNN/Classes/MJ12TroopFMCarcass.uc) | TestFMCarcass | MJ12 Troop corpse | REACHABLE-CODE |
| [TestFMCarcass](CNN/Classes/TestFMCarcass.uc) | CopCarcass | Test FM corpse | REACHABLE-CODE |
| [UnknownParanormalShitCarcass](CNN/Classes/UnknownParanormalShitCarcass.uc) | DobermanCarcass | Unidentified creature corpse | REACHABLE-CODE |
| [AlienCarcassEvidence](CNN/Classes/AlienCarcassEvidence.uc), [BoneEvidence](CNN/Classes/BoneEvidence.uc), [BuddhaEvidence](CNN/Classes/BuddhaEvidence.uc), [CarEvidence](CNN/Classes/CarEvidence.uc), [JosephManderleyCarcassEvidence](CNN/Classes/JosephManderleyCarcassEvidence.uc), [LibertyEvidence](CNN/Classes/LibertyEvidence.uc), [MeadCarcassEvidence](CNN/Classes/MeadCarcassEvidence.uc), [PaulDentonCarcassEvidence](CNN/Classes/PaulDentonCarcassEvidence.uc), [NYLibertyTopEvidence](CNN/Classes/NYLibertyTopEvidence.uc), [SkullEvidence](CNN/Classes/SkullEvidence.uc) | BoxMedium / BoxSmall / CrateUnbreakableLarge / CarWrecked | Story-evidence pickup boxes | REACHABLE-CODE |

## 9. Triggers / Dispatchers / Movers

| Class | Extends | Role | Reachability |
|---|---|---|---|
| [CNNTrigger](CNN/Classes/CNNTrigger.uc) | Trigger | Base CNN trigger | REACHABLE-CODE |
| [CNNEventTrigger](CNN/Classes/CNNEventTrigger.uc) | Trigger | Event-based trigger | REACHABLE-CODE |
| [CNNDamageTrigger](CNN/Classes/CNNDamageTrigger.uc) | DamageTrigger | Damage trigger | REACHABLE-CODE |
| [CNNDetonationTrigger](CNN/Classes/CNNDetonationTrigger.uc) | CNNTrigger | Detonation trigger | REACHABLE-CODE |
| [CNNGravityTrigger](CNN/Classes/CNNGravityTrigger.uc) | CNNTrigger | Zero-gravity trigger | REACHABLE-CODE |
| [CNNSecurityCameraAlarmTrigger](CNN/Classes/CNNSecurityCameraAlarmTrigger.uc) | CNNTrigger | Security camera alarm — **4 hits** in `.con` files | REACHABLE-CON |
| [CNNSetBurningTrigger](CNN/Classes/CNNSetBurningTrigger.uc) | CNNTrigger | Fire/burning trigger | REACHABLE-CODE |
| [CNNSimpleActorSpawner](CNN/Classes/CNNSimpleActorSpawner.uc) | CNNTrigger | Actor spawner | REACHABLE-CODE |
| [CNNZoneTrigger](CNN/Classes/CNNZoneTrigger.uc) | CNNTrigger | Zone-based trigger | REACHABLE-CODE |
| [CNNUnhidePawnTrigger](CNN/Classes/CNNUnhidePawnTrigger.uc) | CNNTrigger | Reveals pawn | REACHABLE-CODE |
| [CNNScriptedPawnInWorldStateTrigger](CNN/Classes/CNNScriptedPawnInWorldStateTrigger.uc) | CNNTrigger | Pawn state check | REACHABLE-CODE |
| [DamageLaserTrigger](CNN/Classes/DamageLaserTrigger.uc) | CNNTrigger | Laser damage trigger | REACHABLE-CODE |
| [GreenLaserTrigger](CNN/Classes/GreenLaserTrigger.uc) | CNNTrigger | Green laser trigger | REACHABLE-CODE |
| [HolocommUnit](CNN/Classes/HolocommUnit.uc) | CNNTrigger | Holographic comm unit (spawns Holo NPCs) | REACHABLE-CODE |
| [MandatoryMovementTriger](CNN/Classes/MandatoryMovementTriger.uc) | CNNTrigger | Forced movement (filename has typo "Triger") | REACHABLE-CODE |
| [ToggleActorLifecycleTrigger](CNN/Classes/ToggleActorLifecycleTrigger.uc) | CNNTrigger | Toggle visibility/collision | REACHABLE-CODE |
| [SpawnTrigger](CNN/Classes/SpawnTrigger.uc) | CNNTrigger | Generic spawn trigger | REACHABLE-CODE |
| [DestroyTrigger](CNN/Classes/DestroyTrigger.uc) | CNNTrigger | Destroys actors | REACHABLE-CODE |
| [CNNPlayerChineseSkillTrigger](CNN/Classes/CNNPlayerChineseSkillTrigger.uc) | Trigger | Chinese-skill condition | REACHABLE-CODE |
| [CNNPlayerFrenchSkillTrigger](CNN/Classes/CNNPlayerFrenchSkillTrigger.uc) | Trigger | French-skill condition | REACHABLE-CODE |
| [UnlockDoorsTrigger](CNN/Classes/UnlockDoorsTrigger.uc) | Trigger | Door unlocker | REACHABLE-CODE |
| [LaserSecurityController](CNN/Classes/LaserSecurityController.uc) | Trigger | Laser security grid controller | REACHABLE-CODE |
| [CNNSimpleTrigger](CNN/Classes/CNNSimpleTrigger.uc) | Triggers | Simple trigger base | REACHABLE-CODE |
| [CnnConversTrigger](CNN/Classes/CnnConversTrigger.uc) | CNNSimpleTrigger | Conversation trigger | REACHABLE-CODE |
| [CnnDispatcher](CNN/Classes/CnnDispatcher.uc) | CNNSimpleTrigger | Event dispatcher | REACHABLE-CODE |
| [CnnDispatcher32](CNN/Classes/CnnDispatcher32.uc) | CNNSimpleTrigger | 32-action dispatcher — found in 1 `.dx` map (06_OpheliaL1) | REACHABLE-MAP |
| [ConfuseDeviceTrigger](CNN/Classes/ConfuseDeviceTrigger.uc) | CNNSimpleTrigger | Confusion/disruption | REACHABLE-CODE |
| [FlipFlagTrigger](CNN/Classes/FlipFlagTrigger.uc) | CNNSimpleTrigger | Flag toggle | REACHABLE-CODE |
| [PostBeginTrigger](CNN/Classes/PostBeginTrigger.uc) | CNNSimpleTrigger | Triggers at level start | REACHABLE-CODE |
| [SetClickableTrigger](CNN/Classes/SetClickableTrigger.uc) | CNNSimpleTrigger | Toggles clickable | REACHABLE-CODE |
| [SetHideTrigger](CNN/Classes/SetHideTrigger.uc) | CNNSimpleTrigger | Hide actor | REACHABLE-CODE |
| [SetOrderTrigger](CNN/Classes/SetOrderTrigger.uc) | CNNSimpleTrigger | Set actor order | REACHABLE-CODE |
| [ToggleOtherTrigger](CNN/Classes/ToggleOtherTrigger.uc) | CNNSimpleTrigger | Toggle other actor | REACHABLE-CODE |
| [UpsSelfDestructTrigger](CNN/Classes/UpsSelfDestructTrigger.uc) | CNNSimpleTrigger | UPS self-destruct | REACHABLE-CODE |
| [UpsSetVisualEffectsTrigger](CNN/Classes/UpsSetVisualEffectsTrigger.uc) | CNNSimpleTrigger | UPS visual effects toggle | REACHABLE-CODE |
| [DestroyTriggerExpectant](CNN/Classes/DestroyTriggerExpectant.uc) | CNNActor | Destroy trigger expectant variant | REACHABLE-CODE |
| [CNNEventDispatcher](CNN/Classes/CNNEventDispatcher.uc) | Dispatcher | CNN event dispatcher | REACHABLE-CODE |
| [LaserSecurityDispatcher](CNN/Classes/LaserSecurityDispatcher.uc) | Actor | Laser security dispatcher | REACHABLE-CODE |
| [CNNMover](CNN/Classes/CNNMover.uc) | DeusExMover | Custom mover | REACHABLE-CODE |
| [MoverMetal](CNN/Classes/MoverMetal.uc) | CNNMover | Metal mover variant | REACHABLE-CODE |
| [CNNEventTimer](CNN/Classes/CNNEventTimer.uc) | Keypoint | Event timer | REACHABLE-CODE |

## 10. HUD / Menus / UI

| Class | Extends | Role | Reachability |
|---|---|---|---|
| [ApocalypseInsideMenuMain](CNN/Classes/ApocalypseInsideMenuMain.uc) | MenuMain | Apocalypse Inside menu variant | REACHABLE-CODE |
| [ApocalypseInsideMenuSelectDifficulty](CNN/Classes/ApocalypseInsideMenuSelectDifficulty.uc) | MenuSelectDifficulty | Difficulty selection (called by [CNNMenuMainTest:12](CNN/Classes/CNNMenuMainTest.uc#L12)) | REACHABLE-CODE |
| [ApocalypseInsideMenuScreenNewGame](CNN/Classes/ApocalypseInsideMenuScreenNewGame.uc) | MenuScreenNewGame | New game screen | REACHABLE-CODE |
| [ApocalypseInsideMenuStartNewGame](CNN/Classes/ApocalypseInsideMenuStartNewGame.uc) | MenuUIMenuWindow | Start new game window | REACHABLE-CODE |
| [ColorThemeHUD_ApostleMod](CNN/Classes/ColorThemeHUD_ApostleMod.uc) | ColorThemeHUD | HUD color theme | REACHABLE-CODE |
| [IwHUDActiveItemBase](CNN/Classes/IwHUDActiveItemBase.uc) | HUDBaseWindow | Base active item/aug window | REACHABLE-CODE |
| [IwHUDActiveItem](CNN/Classes/IwHUDActiveItem.uc) | IwHUDActiveItemBase | Active item display | REACHABLE-CODE |
| [IwHUDActiveAug](CNN/Classes/IwHUDActiveAug.uc) | IwHUDActiveItemBase | Active aug display | REACHABLE-CODE |
| [IwHUDActiveItemsBorderBase](CNN/Classes/IwHUDActiveItemsBorderBase.uc) | HUDBaseWindow | Border base (abstract) | REACHABLE-CODE |
| [IwHUDActiveItemsBorder](CNN/Classes/IwHUDActiveItemsBorder.uc), [IwHUDActiveAugsBorder](CNN/Classes/IwHUDActiveAugsBorder.uc) | IwHUDActiveItemsBorderBase | Active items/augs border | REACHABLE-CODE |
| [IwHUDActiveItemsDisplay](CNN/Classes/IwHUDActiveItemsDisplay.uc) | HUDActiveItemsDisplay | Active items panel (spawned by CNNHUD) | REACHABLE-CODE |
| [IwHUDObjectBelt](CNN/Classes/IwHUDObjectBelt.uc) | HUDObjectBelt | Object inventory belt (spawned by CNNHUD) | REACHABLE-CODE |
| [IwHUDObjectSlot](CNN/Classes/IwHUDObjectSlot.uc) | HUDObjectSlot | Inventory slot widget | REACHABLE-CODE |
| [IwHUDHitDisplay](CNN/Classes/IwHUDHitDisplay.uc) | HUDHitDisplay | Hit damage indicator (spawned by CNNHUD) | REACHABLE-CODE |
| [AiDamageHUDDisplay](CNN/Classes/AiDamageHUDDisplay.uc) | DamageHUDDisplay | Damage display (spawned by CNNHUD) | REACHABLE-CODE |

## 11. Imports / Resources

| Class | Extends | Role | Reachability |
|---|---|---|---|
| [ImportConversations](CNN/Classes/ImportConversations.uc) | Object | `#exec CONVERSATION IMPORT` for 6 .con files (Phase 7 canonical) | ROOT |
| [ImportSounds](CNN/Classes/ImportSounds.uc) | Object | `#exec AUDIO IMPORT` for 4 named SFX | ROOT |
| [AllCnnResources](CNN/Classes/AllCnnResources.uc) | Object | `#forceexec MESH IMPORT` + `#forceexec TEXTURE IMPORT` (gratewindow, CLight, S_CNNTrig) | REACHABLE-CODE |
| [CNNTextures](CNN/Classes/CNNTextures.uc) | Object | Texture asset declarations | REACHABLE-CODE |
| [ApocalypseInsideText](CNN/Classes/ApocalypseInsideText.uc) | Object | Apocalypse Inside text strings | REACHABLE-CODE |
| [CNNTextImport](CNNText/Classes/CNNTextImport.uc) | Object | `#exec DEUSEXTEXT IMPORT` for 25 .txt files | ROOT |

## 12. Support / Helper / Misc

| Class | Extends | Role | Reachability |
|---|---|---|---|
| [CNNActor](CNN/Classes/CNNActor.uc) | Actor | Base custom actor | REACHABLE-CODE |
| [CNNRandomSounds](CNN/Classes/CNNRandomSounds.uc) | RandomSounds | Random sound player | REACHABLE-CODE |
| [ObjectsDestroyNotifier](CNN/Classes/ObjectsDestroyNotifier.uc) | Actor | Tracks destruction for quest completion | REACHABLE-CODE |
| [CNNSphereFragment](CNN/Classes/CNNSphereFragment.uc) | CNNActor | Sphere fragment particle | REACHABLE-CODE |
| [ApocalypseInsideFragment](CNN/Classes/ApocalypseInsideFragment.uc) | DeusExFragment | Fragment particle base | REACHABLE-CODE |
| [AiGlassFragment](CNN/Classes/AiGlassFragment.uc) | ApocalypseInsideFragment | Glass fragment — found in 2 `.dx` maps | REACHABLE-MAP |
| [AiMetalFragment](CNN/Classes/AiMetalFragment.uc) | ApocalypseInsideFragment | Metal fragment | REACHABLE-CODE |
| [AiSphereFragment](CNN/Classes/AiSphereFragment.uc) | CNNSphereFragment | Sphere fragment variant | REACHABLE-CODE |
| [PlasmaRing](CNN/Classes/PlasmaRing.uc) | ShockRing | Plasma shock ring | REACHABLE-CODE |
| [AiLaserEmitter](CNN/Classes/AiLaserEmitter.uc) | LaserEmitter | Alternative laser emitter | REACHABLE-CODE |
| [CNNLaserEmitter](CNN/Classes/CNNLaserEmitter.uc) | LaserEmitter | CNN laser emitter (spawned by Chapter05) | REACHABLE-CODE |
| [JJElecEmitter](CNN/Classes/JJElecEmitter.uc) | ElectricityEmitter | Electricity emitter | REACHABLE-CODE |
| [GlobeBall](CNN/Classes/GlobeBall.uc) | Basketball | Globe basketball — found in 5 `.dx` maps | REACHABLE-MAP |
| [MoonModel](CNN/Classes/MoonModel.uc) | Poolball | Moon model decoration | REACHABLE-CODE |
| [Ship1](CNN/Classes/Ship1.uc) | Vehicles | Ship vehicle | REACHABLE-CODE |
| [Ship1From3ds](CNN/Classes/Ship1From3ds.uc), [Ship2](CNN/Classes/Ship2.uc) | Actor | Ship variants (one converted from 3DS) | REACHABLE-CODE |
| [SciFiFighter](CNN/Classes/SciFiFighter.uc) | Vehicles | Sci-fi fighter | REACHABLE-CODE |
| [SFighter](CNN/Classes/SFighter.uc) | Actor | Generic sci-fi fighter | REACHABLE-CODE |
| [Mars](CNN/Classes/Mars.uc) | Earth | Mars planet model | REACHABLE-CODE |
| [WebAccessPoint](CNN/Classes/WebAccessPoint.uc) | ComputerPublic | Public web terminal | REACHABLE-CODE |
| [ZeroClient](CNN/Classes/ZeroClient.uc) | ComputerPersonal | Zero-client computer — found in 6 `.dx` maps | REACHABLE-MAP |
| [medicalBench](CNN/Classes/medicalBench.uc) | Seat | Medical bench | REACHABLE-CODE |
| [scart4598](CNN/Classes/scart4598.uc) | Object | Unknown (cryptic name — needs review) | FLAGGED |
| [CNNNetworkTerminalSecurityBase](CNN/Classes/CNNNetworkTerminalSecurityBase.uc) | NetworkTerminal | Security terminal base | REACHABLE-CODE |
| [CNNNetworkTerminalSecurity](CNN/Classes/CNNNetworkTerminalSecurity.uc) | CNNNetworkTerminalSecurityBase | Security terminal variant | REACHABLE-CODE |
| [IoTterminal](CNN/Classes/IoTterminal.uc) | ComputerSecurity | IoT terminal | REACHABLE-CODE |
| [CNNComputerSecurity](CNN/Classes/CNNComputerSecurity.uc) | ComputerSecurity | Custom security terminal | REACHABLE-CODE |
| [CNNDoorSignalLight](CNN/Classes/CNNDoorSignalLight.uc) | CageLight | Door signal light | REACHABLE-CODE |
| [EventCommand](CNN/Classes/EventCommand.uc) | Actor | Base event command | REACHABLE-CODE |
| [EventCommandToggleGravity](CNN/Classes/EventCommandToggleGravity.uc) | EventCommand | Gravity toggle | REACHABLE-CODE |
| [EventCommandTurnOnTriggerLight](CNN/Classes/EventCommandTurnOnTriggerLight.uc) | EventCommand | Light control | REACHABLE-CODE |
| [EventCommandUnlockElevatorDoors](CNN/Classes/EventCommandUnlockElevatorDoors.uc) | EventCommand | Door unlock | REACHABLE-CODE |

---

## Reachability summary

| Tag | Count | Notes |
|---|---|---|
| ROOT | 7 | CNNGameInfo, TantalusDenton, CNNRootWindow, CNNHUD, CNNMenuMainTest, ImportConversations, ImportSounds (+ CNNTextImport in CNNText) |
| REACHABLE-MAP | 4 | AiGlassFragment, CnnDispatcher32, GlobeBall, ZeroClient — found in `.dx` map name tables |
| REACHABLE-CON | 2 | BodyBox (148 hits), CNNSecurityCameraAlarmTrigger (4 hits) |
| REACHABLE-CODE | 253 | Reached via UC source: extends chain, `Class'X'` in defaultproperties, `Spawn(class'X')`, `#exec` directives |
| FLAGGED | 1 | [scart4598](CNN/Classes/scart4598.uc) — cryptic name; appears to be a one-off helper. Compile passes but worth a manual look. |
| **Total** | **267** | All accounted for. CNNCreditsWindowTest quarantined to `_Backups/Phase10_DeadClasses/` 2026-04-27 (zero refs anywhere). |

## Class-name prefix groupings

The codebase uses several prefix conventions that group related classes:

| Prefix | Count | Domain |
|---|---|---|
| `Ai*` | 16 classes | "Apocalypse Inside" era runtime systems — augmentation/skill managers, conversation playback ([AiSkillManager](CNN/Classes/AiSkillManager.uc), [AiAugmentationManager](CNN/Classes/AiAugmentationManager.uc), [AiConPlay](CNN/Classes/AiConPlay.uc), [AiSkillBionics](CNN/Classes/AiSkillBionics.uc), [AiSkillChinese](CNN/Classes/AiSkillChinese.uc), etc.). NOTE: `Ai*` is short for *Apocalypse Inside* (the parent mod CNN was forked from), not Artificial Intelligence. |
| `Apocalypse*` | 6 classes | UI menu chain (production New Game flow) + fragment/text base classes — `ApocalypseInsideMenuMain`, `ApocalypseInsideMenuSelectDifficulty`, `ApocalypseInsideMenuScreenNewGame`, `ApocalypseInsideMenuStartNewGame`, `ApocalypseInsideText`, `ApocalypseInsideFragment`. |
| `JJ*` | 1 class + 2 modified | Electric/laser effects — [JJElecEmitter](CNN/Classes/JJElecEmitter.uc) entirely; inline edits in [AiLaserEmitter.uc:25-31](CNN/Classes/AiLaserEmitter.uc#L25) and [CNNLaserEmitter.uc:25-29](CNN/Classes/CNNLaserEmitter.uc#L25). |
| `Iw*` | 10 classes | HUD widgets — [IwHUDObjectBelt](CNN/Classes/IwHUDObjectBelt.uc), [IwHUDActiveItem](CNN/Classes/IwHUDActiveItem.uc), [IwHUDHitDisplay](CNN/Classes/IwHUDHitDisplay.uc) and 7 siblings. |
| `My*` | 3 classes | Conversation handlers + a fire extinguisher: [MyConPlay](CNN/Classes/MyConPlay.uc), [MyConEventAnimation](CNN/Classes/MyConEventAnimation.uc), [MyFireExtinguisher](CNN/Classes/MyFireExtinguisher.uc). |
| `CNN*` | 52 classes | Project-wide shared namespace. |

These groupings give a quick way to scope review batches and reason about subsystem boundaries.

## Notable patterns

1. **Apocalypse Menu chain** — [CNNMenuMainTest:12](CNN/Classes/CNNMenuMainTest.uc#L12) → `ApocalypseInsideMenuSelectDifficulty` → ... is the production New Game flow. The Phase 5 audit initially flagged this as orphan because the `Class'CNN.X'` reference inside a `defaultproperties` tuple was missed by simple `extends`/`spawn` regex.

2. **`Object`-extending import templates (~27 classes)** — The `DecoX` stubs (DecoBarrel2, DecoBoardBoxSmall, etc.) extend `Object abstract` and pair with concrete container/item classes. They exist purely for `#exec MESH IMPORT` directives at compile time.

3. **Holo NPC family (5 classes)** — `UberAllesHolo`, `JCDoubleHolo`, `BobPageHolo`, `MJ12TroopHolo`, `PhilipMeadHolo` are all spawned by `HolocommUnit` for holographic conversation cutscenes.

4. **Carcass + Evidence pairing** — Most named NPCs have a paired carcass class. Story-relevant deaths additionally have an `*Evidence` box class pickable up by the player as quest items.

5. **Trigger taxonomy** — 37 trigger variants split across two parents (`CNNTrigger`: full-fat triggers; `CNNSimpleTrigger`: lightweight event-only). `CnnDispatcher32` is the most complex (32 separate `Action` slots).

6. **Skill system** — 6 custom skills, but only `AiSkillChinese` has a runtime monitor (`ChineseSkillController` spawned per-tick by `TantalusDenton`). The other skills are passive checks.

7. **Naming inconsistencies** (worth fixing eventually):
   - `CNNMisson01.uc` (typo: should be "Mission01")
   - `MandatoryMovementTriger.uc` (typo: should be "Trigger")
   - `pallet.uc` and `wallfuse8.uc` use lowercase class names (out of style)
   - `scart4598.uc` is cryptic — flagged for review

---

## Methodology

After Phase 5 caught **three reachability-analysis blind spots** by breaking the build, this atlas applies four dimensions:

1. **UC code references**:
   - `extends X` — direct inheritance
   - `Spawn(class'X')` / `class<X>(SomeRef)` — runtime instantiation
   - `Class'CNN.X'` inside `defaultproperties` tuples — `buttonDefaults(N)=(Invoke=Class'CNN.X')`, `MenuClass=Class'CNN.X'`, etc. (the pattern that originally hid the Apocalypse Menu chain)
   - `#exec` directives — `MESH IMPORT`, `TEXTURE IMPORT`, `AUDIO IMPORT`, `CONVERSATION IMPORT`, `DEUSEXTEXT IMPORT`

2. **`.dx` map name tables** — `grep -a "ClassName" Maps/*.dx` against the 11 maps. UE1 packages embed referenced class names as plain strings.

3. **`.con` conversation files** — same `grep -a` technique against the 6 files in `CNN/Conversations/`. Conversations store speaker/pawn class names as binary strings.

4. **Configuration files** — `CNN.ini` / `DefaultGame=` / player class / HUD class.

A class is REACHABLE if it appears in **any** of these dimensions starting from the ROOT set.

The current branch (`chore/repo-cleanup`) compiles cleanly and produces a working installer, which is the strongest possible confirmation that no class needed for the production build is missing.

---

*Generated 2026-04-25 on branch `chore/repo-cleanup`. Updated after Phase 8A (mesh ref consolidation) and authorship survey. Update when classes are added/removed or when reachability paths change.*
