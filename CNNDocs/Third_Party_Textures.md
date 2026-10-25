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
| ~~`Ophelia.utx`~~ | 28 / 36 | было: карты, 767 поверхностей L1, L2 и концовок + 18 у мусоров | Tantalus, 2017; часть, возможно, из Unity Asset Store | **Заменён** 25.10.2026: CC0, свои и сток, см. ниже; не поставляется |
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

## Ophelia.utx заменён (25.10.2026)

Часть текстур, возможно, из Unity Asset Store (автор не уверен), а лицензия Asset Store не позволяет
поставлять файлы так, чтобы их можно было извлечь — а .utx открывается в любом UnrealEd. Решение автора:
характерные панели — свободные CC0 или нарисованные нами, простые стены и пол — стоковые Deus Ex.

- **Свои текстуры** — `CNN.Station.*` в `CNN.u`, собирает их `tools/station_textures.js` (источник —
  «Zortch World Textures», mutantleg, CC0; разметка опасности и плиты пола нарисованы кодом) в размер
  заменяемой текстуры, чтобы раскладка на поверхностях не менялась.
- **Стоковые** — 256×256, как исходные, кроме `Galvanzd`, `Galvanzd_C`, `un_DirtyVent_A` (128 — ложатся
  вдвое мельче).
- **Карты** — `tools/pkg_reimport.js` на доках, L1, L2, Hijacking, Transcend: импорты переадресованы,
  недостающие имена и группы добавлены. Проверка мостом без `Ophelia.utx` в установке: 0 новых проблем,
  пакет не грузится.

| Текстура Ophelia | Поверхностей | Чем стала | Откуда |
|---|---|---|---|
| `u_wall06` 256×512 | 252 | `CNN.Station.u_wall06` | Zortch `tile186`, левая половина |
| `Metal.Wall02b` | 72 | `V_Com_Center.Wall_Objects.ClenCommPanel_F` | сток |
| `Metal.Wall01c` | 67 | `CNN.Station.Wall01c` | нарисована (жёлтая с полосами) |
| `u_ceiling01` 512 | 59 | `CNN.Station.u_ceiling01` | Zortch `tile509` |
| `Metal.panels_ext` 1024 | 48 | `CNN.Station.panels_ext` | Zortch `tile232`, 2×2 |
| `Metal.Wall02` | 42 | `HK_MJ12Lab.Metal.HK_strwal_04` | сток |
| `Foliage.GravityFloor` | 31 | `CNN.Station.GravityFloor` | нарисована (светлые плиты с круглой серединой) |
| `Metal.FloorTech05` | 24 | `Airfield.Tiles.AF_CrewFloor_A` | сток |
| `Metal.pod_door` 512 | 24 + 18 мувер | `CNN.Station.pod_door` | Zortch `tile327` |
| `Metal.Wall02c` | 20 | `CNN.Station.Wall02c` | Zortch `tile150`, высветлена |
| `Metal.u_beam01` | 18 | `UNATCO.Metal.Uob_GrenCheckr` | сток |
| `Metal.guts` 1024 | 15 | `CNN.Station.guts` | Zortch `tile510`, 2×2 |
| `Metal.FloorTech05c` | 15 | `UNATCO.Metal.un_DirtyVent_A` | сток (128) |
| `Metal.FloorTech04` | 12 | `V_Com_Center.Wall_Objects.ClenCncrtWall_C` | сток |
| `Metal.FloorTech05b` | 12 | `CNN.Station.FloorTech05b` | нарисована (красно-белые полосы) |
| `u_casing01` 512×256 | 12 | `CNN.Station.u_casing01` | Zortch `tile30`, средняя полоса |
| `Metal.FloorTech05e` | 7 | `SubBase.Metal.SB_PipeWall_A` | сток |
| `Metal.FloorTech01b` | 6 | `CNN.Station.FloorTech01b` | нарисована (круг в полосах) |
| `u_casing02` | 6 | `Supertanker.Metal.Crane_wall` | сток |
| `Metal.FloorTech01` | 3 | `CoreTexMetal.Metal.Galvanzd` | сток (128) |
| `Metal.FloorTech01c` | 3 | `CNN.Station.FloorTech01c` | нарисована (кольцо в полосах) |
| `Metal.FloorTech02` | 3 | `V_Com_Center.Wall_Objects.ClenCommPanel_F` | сток |
| `Metal.FloorTech02c` | 3 | `Supertanker.Metal.Crane_wall` | сток |
| `Metal.FloorTech03` | 3 | `CNN.Station.GravityFloor` | была копией `GravityFloor` |
| `Metal.FloorTech05d` | 3 | `Airfield.Tiles.AF_CrewFloor_A` | сток |
| `Metal.FloorTech07` | 3 | `CoreTexMetal.Metal.Galvanzd_C` | сток (128) |
| `mp_b_carb02` 512 | 3 | `CNN.Station.mp_b_carb02` | Zortch `tile339` |
| `Metal.rustmetal1` 512 | 1 | `CNN.Station.rustmetal1` | Zortch `tile514` |

Подвесные экраны L1 без картинки (раньше — постер «Секретных материалов» и другие изображения; поверхности
были без текстуры и показывали `DefaultTexture`) получили нарисованные заставки в размер их разметки:
`CNN.Station.ScreenRecRoom` 512×512 (зона отдыха, у кнопки `Xfiles`: летающая тарелка над лесом),
`ScreenMedical` 512×512 (медотсек: кардиограмма), `ScreenSecurity` 1024×512 (у камеры наблюдения: четыре
камеры); маленькая полупрозрачная панель — стоковый `V_Com_Center.Glass.ClenBlueLight_A`.
Остальные такие поверхности (L1, Hijacking, Transcend, Mutiny) взяли текстуру своего браша —
`tools/bsp_retexture.js`.

Не использовались ни на одной карте и исчезают без замены: `FloorTech02b`, `FloorTech04b`, `FloorTech06`,
`FloorTech08`, `FloorTiles`, `Wall01`, `Wall01b`, `Wall03`.

## Открытые вопросы (к автору / Tantalus)

1. ~~Ophelia.utx~~ — заменён (см. выше).
2. **LosAngelesTex** — источники фото (`lasky`, `hollywood`, `CityOnTheHill`, `LastSupperSalon`).
3. **Custom Decorations** (`Button1B`, `ChemicalCannister`, `Magazine`, `TowelRack`, `HandDry`, `Sink`, `Pipe*`,
   `ObserX`, `wallfuse8`, `bassein`) — чей набор.
4. `xmas_banner`, глобусы Земли и Марса, снимки картин — источник.
5. `rammstein3` — заменить (предложение).
7. `CNNTextures.OpheliaIW` (1024×512, подвесной экран L1 у (2, −431, 196)) — снимок командного зала; если `IW`
   значит Deus Ex: Invisible War, это кадр из чужой игры — уточнить и при необходимости нарисовать свой.
6. Бренды в наборе PFAD (Bounty, Bueno, Snickers, Pepsi, Red Bull, Monster) — оставить как есть
   (так их выпустил автор PFAD) или убрать эти предметы с карт.
