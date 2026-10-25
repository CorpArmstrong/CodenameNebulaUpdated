# Нестоковые текстуры: учёт и замена стоковыми (25.10.2026)

Цель — чтобы мод опирался на сторонние файлы как можно меньше: всё, что не своё и не из Deus Ex, либо
заменить стоковой текстурой, похожей настолько, насколько возможно, либо записать, откуда оно и на каком
основании используется.

## Как получено

- **Что игра реально грузит** — `tools/cnn_objdump.ps1` по всем 9 картам с INI игрока (без HD-путей
  Revision): 261 загружаемая текстура не из стоковых пакетов Deus Ex GOTY.
- **Кто на неё ссылается** — разбор карт (`pkg_probe.js`): поверхности BSP уровня, брашей мусоров и
  свойства актёров. На что карты не ссылаются, то грузят классы (меши, HUD, иконки).
- **Похожие стоковые** — `tools/tex_lookalike.js`: декодирует все 4271 стоковую текстуру и 446 текстур мода
  и сравнивает цвет, гистограмму яркости, плотность и направления границ, крупную раскладку и размер.
  Это отбор кандидатов, а не решение: окончательный выбор — глазами.
- **Замена** — `tools/pkg_reimport.js`: переадресация импорта в карте. Если новое имя длиннее слота,
  таблица импортов переписывается в конец файла (проверено на Луне: грузится, 0 новых проблем).

## Сводка по пакетам

| Пакет | Грузится / всего | Как попадает в игру | Происхождение | Заменимо стоковым? |
|---|---|---|---|---|
| `Ophelia.utx` | 28 / 36 | карты: **767 поверхностей** L1, L2 и концовок + 18 у мусоров | Tantalus, 05.02.2017 «Added new textures»; **источник не известен** (поиск по именам `FloorTech05d`, `u_casing01`, `mp_b_carb02`, `u_wall06` ничего не нашёл) | Технически да (правка импортов), но это облик всей станции; близких научно-фантастических панелей в стоке мало |
| `LosAngelesTex.utx` | 6 / 6 | карты: L2, Hijacking, Transcend, Mutiny | фото и экраны (небо ЛА, Hollywood, «City on the Hill», спутник, экран аватара); источник не известен | Нет — уникальные изображения; нужен источник/лицензия или своя замена |
| `ArtPieces.utx` | 3 / 6 | карты: Луна (`AdaLovelace`), доки (`monalisa`), Mutiny (`last-supper`) | репродукции картин XIX века и старше — сами картины в общественном достоянии | Не нужно, если снимки репродукций свободные |
| `CNNTextures.utx` | 2 / 4 | карты: меню (`cnn-title`), L1 (`OpheliaIW`) | свои (команда) | Не нужно |
| `CNN.u` | 130 / 162 | 14 — карты, остальное — классы | смешано, см. ниже | Частично |
| `PFADTex.utx` + `PFAD.u` | 77 / 139 + 4 / 4 | классы PFAD (шоколадки, напитки) | мод PFAD (Prototype), в титрах | Нет: скины своих мешей. Отдельно: настоящие бренды (Bounty, Bueno, Snickers, Pepsi, Red Bull, Monster) |
| `GaussGun.u` | 10 / 10 | классы оружия | Bowen Wong (+ Y\|yukichigai), в титрах | Нет: скины своего меша |
| `DXRVNewVehicles.u` | 1 / 77 | танк в доках | Deadalus08, в титрах | Нет |
| `AiInfoPortraits.utx` | по имени | инфолинки Janus и Ada | Apocalypse Inside (родительский мод) | Не нужно |

## Сделано

- `CNN.MoonStone` **пиксель в пиксель** совпадает со стоковой `Moon.Earth.Moonscape7`: Луна теперь берёт
  стоковую (1 поверхность). Проверено мостом: грузится `Moon.Earth.Moonscape7`, `CNN.MoonStone` не грузится
  ни на одной карте; в `CNN.u` её ещё импортирует `CNNTextures.uc` — строку можно убрать.
- Ранее (`chore/drop-titan-genfx`): `TITAN.utx` и `GenFX.utx` заменены стоковыми и не поставляются.

## Текстуры, на которые ссылаются карты (кроме Ophelia)

| Текстура | Где | Что это | Предложение |
|---|---|---|---|
| `CNN.rammstein3` | Луна, 1 поверхность | постер группы Rammstein | **заменить**: товарный знак и чужой арт; стоковые постеры (`NewYorkCity`, `HK_Signs`) или свой |
| `CNN.xmas_banner` | Луна, 1 | новогодний баннер 2048² | уточнить источник |
| `CNN.Aldrin_Apollo_1` | Луна, 1 | фото Олдрина (NASA) | NASA — общественное достояние; указать источник |
| `CNN.EarthEast/West`, `earthMapEast/West`, `MarsEast/West` | глобусы Земли и Марса (Луна, доки, L1, L2, Hijacking); `earthMapWest` ещё на 14 поверхностях L2 | карты планет | если NASA Blue Marble / MOLA — свободно; уточнить |
| `CNN.Skins.SciFiFighterTex0` | доки, 1 + истребитель | скин меша истребителя | вместе с мешем (`SciFiFighter`, автор не известен) |
| `CNN.Skins.Sink1Tex1` | меню, Луна | раковина | см. «Custom Decorations» ниже |
| `CNN.Skins.TantalusFace`, `MagdaleneFace1` | скины персонажей | свои | не нужно |
| `LosAngelesTex.*` (6) | L2, концовки | фото/экраны | источник; иначе — свои кадры или стоковые экраны (`DeusExDeco`, `CoreTexMisc`) |
| `ArtPieces.*` (3) | Луна, доки, Mutiny | картины | общественное достояние; источник снимков |
| `CNNTextures.*` (2) | меню, L1 | свои | не нужно |

## Текстуры CNN.u, которые грузят классы

| Группа | Сколько | Что | Происхождение |
|---|---|---|---|
| `UserInterface` (`NewHUDHitDisplay_*`, `UBHUD_*`) | 12 | HUD | Nihilum (FastGamerr, Creative Commons, разрешение в комментариях ModDB 2017) |
| `Skins` декораций (`Button1BTex1–24`, `ChemicalCannisterTex1–21`, `Magazine`, `TowelRack`, `HandDry`, `Sink`, `CoffeeMachine`, `Pipe*`, `ObserX`, `wallfuse8`, `bassein` …) | ~70 | «Custom Decorations» (шапка классов), 2017 | **не известно**, чей это набор — уточнить |
| `Skins` персонажей (`Tantalus*`, `Magdalene*`, `NSFJacket`, `paulsshirt`, `UberAllesHelmet`) | 12 | одежда и лица | свои; `TantalusBlack` — перекраска стоковой `JCDentonTex4` |
| `UI` (`TantalusMenu1–5`), `chester_credits`, `codenamenebula_credits` | 7 | меню и титры | свои; фото Честера — фотограф не указан |
| прочее (`Gen_Green`, `S_CNNTrig`, иконки кофе, `skilliconFrench`, `DecoTex.mea1–3`) | 7 | эффекты, иконки | свои / Apocalypse Inside |

## Ophelia.utx — кандидаты из стока

Самые используемые: `u_wall06` (252 поверхности), `Wall02b` (72), `Wall01c` (67), `u_ceiling01` (59),
`panels_ext` (48), `Wall02` (42), `GravityFloor` (31). Кандидаты — три ближайших по признакам из уровневых
пакетов; наглядно — в листе `lookalikes_maps.html` (генерируется `tex_lookalike.js html`).

| Текстура | Размер | Карты | Где | Ближайшие стоковые (по признакам) |
|---|---|---|---|---|
| `Ophelia.Foliage.GravityFloor` | 256x256 | доки, L1, L2 | 31 BSP | `Airfield.Tiles.AF_CrewFloor_A`, `CoreTexStone.Stone.un_stonsign_c`, `CoreTexStone.Stone.ClenGrenSlate_A` |
| `Ophelia.Metal.FloorTech01` | 256x256 | L2, Hijacking, Transcend | 3 BSP | `FreeClinic.Tiles.FC_MainFloor`, `Airfield.Tiles.AF_CrewFloor_A`, `CoreTexMetal.Metal.ShipBeigMetal_A` |
| `Ophelia.Metal.FloorTech01b` | 256x256 | L2, Hijacking, Transcend | 6 BSP | `CoreTexMisc.BW_LG_SatPic_B`, `NewYorkCity.Brick.WareHousBlock1` |
| `Ophelia.Metal.FloorTech01c` | 256x256 | L2, Hijacking, Transcend | 3 BSP | `CoreTexMisc.BW_LG_SatPic_B`, `NewYorkCity.Brick.WareHousBlock1` |
| `Ophelia.Metal.FloorTech02` | 256x256 | L2, Hijacking, Transcend | 3 BSP | `OceanLab.Metal.ol_wall_11`, `V_Com_Center.Wall_Objects.ClenCommPanel_F`, `HK_MJ12Lab.Metal.HK_strwal_04` |
| `Ophelia.Metal.FloorTech02c` | 256x256 | L2, Hijacking, Transcend | 3 BSP | `OceanLab.Metal.ol_wall_11`, `Supertanker.Metal.Crane_wall`, `HK_MJ12Lab.Metal.HK_strwal_04` |
| `Ophelia.Metal.FloorTech03` | 256x256 | L1 | 3 BSP | `Airfield.Tiles.AF_CrewFloor_A`, `CoreTexStone.Stone.un_stonsign_c`, `CoreTexStone.Stone.ClenGrenSlate_A` |
| `Ophelia.Metal.FloorTech04` | 256x256 | L2, Hijacking, Transcend | 12 BSP | `V_Com_Center.Wall_Objects.ClenCommPanel_F`, `Paris.Stone.CatacomWall_G2`, `UNATCO.Stone.un_statbrickBS` |
| `Ophelia.Metal.FloorTech05` | 256x256 | L2, Hijacking, Transcend | 24 BSP | `CoreTexConcrete.Concrete.ClenGrayCemnt_C`, `MolePeople.Brick.Nsubwaltop`, `CoreTexStone.Stone.tan_grey` |
| `Ophelia.Metal.FloorTech05b` | 256x256 | L2, Hijacking, Transcend | 12 BSP | `CoreTexTextile.Textile.WavePatnCarpt`, `CoreTexMetal.Metal.ShipNamePlate_B`, `CoreTexMetal.Metal.ShipNamePlate_D` |
| `Ophelia.Metal.FloorTech05c` | 256x256 | L2, Hijacking, Transcend | 15 BSP | `BatteryPark.Metal.BP_BPmap`, `CoreTexMisc.BW_SatPic_B01`, `CoreTexMisc.Metal.toaster` |
| `Ophelia.Metal.FloorTech05d` | 256x256 | L1 | 3 BSP | `MolePeople.Brick.Nsubwaltop`, `CoreTexConcrete.Concrete.ClenGrayCemnt_C`, `CoreTexConcrete.Concrete.SmthGrayCemnt_A` |
| `Ophelia.Metal.FloorTech05e` | 256x256 | L1, L2, Hijacking, Transcend | 7 BSP | `CoreTexMisc.Glass.BW_LG_SatPic`, `Supertanker.Metal.ST_wall02` |
| `Ophelia.Metal.FloorTech07` | 256x256 | L2, Hijacking, Transcend | 3 BSP | `V_Com_Center.Wall_Objects.DrtyCmandWall_B`, `UNATCO.Stone.un_DirtyWall_A`, `CoreTexMetal.Metal.Galvanzd_C` |
| `Ophelia.Metal.guts` | 1024x1024 | L1, L2, Hijacking, Transcend | 15 BSP | `CoreTexConcrete.Concrete.ClenBlakStret_A`, `CoreTexMetal.Metal.HangrMetlWall_D`, `Rocket.Metal.ClenGrenWall_A` |
| `Ophelia.Metal.panels_ext` | 1024x1024 | L2, Hijacking, Transcend | 48 BSP | `CoreTexConcrete.Concrete.un_heli_cncrt_a`, `UNATCO.Stone.un_statwlkwy_d`, `Airfield.Metal.AF_interwall_C` |
| `Ophelia.Metal.pod_door` | 512x512 | L2, Hijacking, Transcend | 24 BSP, 18 мувер | `Rocket.Metal.ClenGrenFloor_A`, `area51textures.Metal.area51clnder_a`, `Airfield.Metal.747windosec_A` |
| `Ophelia.Metal.rustmetal1` | 512x512 | L1 | 1 BSP | `FreeClinic.Tiles.FC_MainFloor`, `Supertanker.Metal.STBeigMetal_A`, `CoreTexMetal.Metal.ShipBeigMetal_A` |
| `Ophelia.Metal.u_beam01` | 256x256 | L2, Hijacking, Transcend | 18 BSP | `UNATCO.Metal.Uob_GrenCheckr`, `CoreTexMetal.Metal.DrtyIronWOriv_B`, `CoreTexConcrete.Concrete.DrtyCastCemnt_A` |
| `Ophelia.Metal.Wall01c` | 256x256 | L1, L2, Hijacking, Transcend | 67 BSP | `NewYorkCity.Brick.WareHousBlock1`, `NewYorkCity.Wall_Objects.BarWall_B`, `NewYorkCity.Brick.WareHousBloc1A` |
| `Ophelia.Metal.Wall02` | 256x256 | L2, Hijacking, Transcend | 42 BSP | `Supertanker.Metal.STBeigMetal_B`, `CoreTexConcrete.Concrete.SmthGrayCemnt_B`, `UNATCO.Stone.un_statwlkwy_d` |
| `Ophelia.Metal.Wall02b` | 256x256 | L2, Hijacking, Transcend | 72 BSP | `Supertanker.Metal.STBeigMetal_B`, `Catacombs.Stone.pa_pitwall`, `HK_Helibase.Concrete.HelibaseWall_C` |
| `Ophelia.Metal.Wall02c` | 256x256 | L1, L2, Hijacking, Transcend | 20 BSP | `Airfield.Tiles.AF_CrewFloor_A`, `Catacombs.Stone.pa_pitwall`, `CoreTexStucco.Stucco.ClenGreyDrWal01` |
| `Ophelia.mp_b_carb02` | 512x512 | L2, Hijacking, Transcend | 3 BSP | `CoreTexSky.Sky.ClenCloudBank_B`, `CoreTexMisc.Metal.cargo01b`, `CoreTexMisc.Metal.ElevatorShaft_C` |
| `Ophelia.u_casing01` | 512x256 | L2, Hijacking, Transcend | 12 BSP | `Dockyard.Concrete.warewall01`, `HK_VersaLife.Metal.drawers01`, `subway.Concrete.sub_beam_a` |
| `Ophelia.u_casing02` | 256x256 | L2, Hijacking, Transcend | 6 BSP | `V_Com_Center.Wall_Objects.ClenCommPanel_F`, `BatteryPark.Textile.mattress1`, `OceanLab.Metal.ol_wall_11` |
| `Ophelia.u_ceiling01` | 512x512 | L1, L2, Hijacking, Transcend | 59 BSP | `Catacombs.Stone.Paris_Wall_01`, `Catacombs.Stone.Paris_Wall_03`, `CoreTexMetal.Metal.ShipsCeiln_B` |
| `Ophelia.u_wall06` | 256x512 | L2, Hijacking, Transcend | 252 BSP | `NewYorkCity.Brick.NSF_WallTrim_B`, `CoreTexMetal.Metal.MetalStepEdge_A`, `BatteryPark.Sky.BPskyboxBldg_7` |

Автоматический подбор для этих панелей слабый: в стоке Deus Ex мало научно-фантастических стен такого
вида. Если Ophelia окажется сторонним пакетом без разрешения, лучше подбирать вручную по группам
(стены, пол, потолок, двери) из `area51textures`, `HK_MJ12Lab`, `MJ12_lab`, `OceanLab`, `Moon`,
`V_Com_Center`, `Hangar18`, а при смене размера проверять раскладку на поверхностях.

## Открытые вопросы (к автору / Tantalus)

1. **Ophelia.utx** — откуда текстуры (имена `FloorTech*`, `u_wall06`, `u_casing*`, `mp_b_carb02` похожи на
   внутренние имена чужой игры или набора)? От этого зависит, менять ли облик станции.
2. **LosAngelesTex** — источники фото (`lasky`, `hollywood`, `CityOnTheHill`, `LastSupperSalon`).
3. **Custom Decorations** (`Button1B`, `ChemicalCannister`, `Magazine`, `TowelRack`, `HandDry`, `Sink`, `Pipe*`,
   `ObserX`, `wallfuse8`, `bassein`) — чей набор.
4. `xmas_banner`, глобусы Земли и Марса, снимки картин — источник.
5. `rammstein3` — заменить (предложение).
6. Бренды в наборе PFAD (Bounty, Bueno, Snickers, Pepsi, Red Bull, Monster) — оставить как есть
   (так их выпустил автор PFAD) или убрать эти предметы с карт.
