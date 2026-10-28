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
`CNN.Station.ScreenRecRoom` 512×512 (зона отдыха, у кнопки `Xfiles`: снимок «летающей тарелки» ВВС США —
общественное достояние, Wikimedia Commons `File:Flying_Saucer.webp`), `ScreenMedical` 512×512 (медотсек:
кардиограмма), `ScreenSecurity` 1024×512 (у камеры наблюдения: четыре камеры), `ScreenConsole` 64×64
(экран консоли; поверхность полупрозрачная, то есть аддитивная, поэтому экран светлый — тёмный фон
просвечивал бы стеной).
`CNNTextures.OpheliaIW` (снимок командного зала, возможно из Invisible War) заменён схемой станции
`CNN.Station.ScreenStation`; надпись меню `CNNTextures.cnn-title` перенесена в `CNN.UI.CNNTitle`, и
`CNNTextures.utx` больше не поставляется (остаётся в репозитории для отладочной `Entryv2`).
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
5. ~~`rammstein3`~~ — заменён портретом экипажа Apollo 11 (28.10.2026).
7. ~~`CNNTextures.OpheliaIW`~~ — заменён своей схемой станции (см. выше).
6. Бренды в наборе PFAD (Bounty, Bueno, Snickers, Pepsi, Red Bull, Monster) — оставить как есть
   (так их выпустил автор PFAD) или убрать эти предметы с карт.

## Поиск источников (28.10.2026)

Текстуры выгружены в PNG и просмотрены; поиск — текстовый (обратный поиск по картинке не делался:
он требует загрузки файла на сторонний сервис).

| Текстура | Что на ней на самом деле | Вывод |
|---|---|---|
| `CNN.xmas_banner` | рекламный баннер «Mise en Abyme — Coming to Kickstarter Q1 2015 — ApostleMod» поверх снимка Apollo 11 | **свой**: ApostleMod — студия самой команды (Apocalypse Inside), Mise en Abyme — её «облачные компьютеры» из сюжета AI; фото Apollo 11 — NASA, общественное достояние |
| `CNN.rammstein3` | кадр из клипа Rammstein «Amerika» (2004, реж. Jörn Heitmann): группа в скафандрах на «Луне» | **заменён** 28.10.2026: `CNN.Photos.Apollo11Crew` (портрет экипажа Apollo 11, NASA, общественное достояние) |
| `LosAngelesTex.lasky` | фото панорамы даунтауна Лос-Анджелеса, затемнено, звёздное небо поверх | **заменён** 28.10.2026: `CNN.Photos.LASkyline` (`Downtown Los Angeles skyline.jpg`, Serouj, общественное достояние), ночь — `tools/photo_textures.js`; `lasky` обнуляется в `LosAngelesTex.utx` при упаковке |
| `LosAngelesTex.hollywood` | ночной любительский снимок надписи Hollywood, 512² с артефактами сжатия | источник не найден; заменить свободным снимком или нарисовать |
| `LosAngelesTex.CityOnTheHill`, `LastSupperSalon` | вывески, сделанные командой (свой текст) на фото досок | текст свой; доски — типовые фото дерева, источник не найден, риск низкий |
| `LosAngelesTex.satelliteflip`, `avatar-screen` | тонированные снимки сцен самой Deus Ex | производные стоковой Deus Ex — в рамках SDK |
| `ArtPieces.RaidPhoto` | групповой рендер стоковых персонажей Deus Ex | производная Deus Ex |
| `ArtPieces.WashDelaware`, `kossaks`, `monalisa`, `AdaLovelace`, `last-supper` | Лойце, Репин, Леонардо, портрет Ады Лавлейс (Шалон) | картины — общественное достояние |
| `CNN.earthMapWest/East` | развёртка Земли день/ночь с облаками | по виду Blue Marble + City Lights (NASA, общественное достояние); готовая склейка не найдена |
| `CNN.MarsWest/East` | цветная карта Марса | по виду мозаика Viking (NASA/USGS, общественное достояние) |
| «Custom Decorations» | ≈23 класса (`Barrel2`, `ChemicalCannister`, `HandDry`, `TowelRack`, `KarkianEgg`…), добавлены Tantalus 05.07.2017 (`0e72341`) | автор в интернете не находится; вопрос остаётся к Tantalus |
| `SciFiFighter` | «free sci-fi fighter» (`070773a`, 15.04.2017, CorpArmstrong) | **найден**: «Free Sci Fi Fighter», GrafxBOX / CGPitbull, Sketchfab `dca1c832ee574e2fa2cdaa06515f66a9`, CC Attribution. 2570 треугольников — ровно как в `SciFiFighter_d.3d`; в исходной `Free_S.jpg` слой Photoshop `SciFi_Fighter_AK5-diffuse` (2013). Наша текстура — перекраска. В титрах и README с 28.10 |

### Кандидаты на замену (Wikimedia Commons, 28.10.2026)

| Заменяет | Снимок | Лицензия |
|---|---|---|
| `LosAngelesTex.lasky` (выбран другой, см. выше) | `Downtown Los Angeles skyline from Toy District.jpg` (Eric Polk, 3775×1438, с земли, как исходная) | CC BY-SA 4.0 — указать автора, текстура тоже CC BY-SA |
| — запасной | `Downtown Los Angeles skyline.jpg` (Serouj, 1274×752, с Гриффита, дымка) | общественное достояние |
| `LosAngelesTex.hollywood` | `Hollywood Sign at Night (8965649621).jpg` (Atomic Taco, 5184×2916, почти тот же ракурс) | CC BY-SA 2.0; надпись Hollywood — товарный знак Hollywood Chamber of Commerce (была и в исходной) |
| `CNN.rammstein3` | `Apollo XI - Prime Crew Portrait (S69-31740).jpg` — экипаж в скафандрах без шлемов на фоне Луны | NASA, общественное достояние |
| — вариант с намёком на клип | `Two crew men of the Apollo 13 lunar landing mission simulate lunar surface Extravehicular Activity.jpg` — тренировка в павильоне с макетом модуля и флагом | NASA, общественное достояние |

### Итог 28.10.2026 (вечер)

- `LosAngelesTex.hollywood` → `CNN.Photos.Hollywood`: «Hollywood Sign at Night (8965649621).jpg», Atomic Taco,
  CC BY-SA 2.0 (текстура тоже CC BY-SA 2.0), в титрах и README; `hollywood` обнуляется в `LosAngelesTex.utx`.
- `CNN.chester_credits` → `CNN.Photos.ChesterBennington`: «Chester Bennington 2011 (suran2007) 3 - Flickr.jpg»,
  suran2007, CC BY 2.0, в титрах и README; `chester.bmp` (не использовался) и `chester_credits.bmp` удалены.
- `Ship1` — модель JJoe (Evgeniy Bortnik, команда, в титрах).
- Milosh--Andrich: паки 01 и 03 лежат в его папке DeviantArt «TEXTURE Free for all» («Textures packs free for
  all»); в титрах исправлены ссылки (старые вели на 404).
- «Custom Decorations» (23 класса `Deco*`, добавлены Tantalus 05.07.2017, `0e72341`): в интернете не найдены —
  проверены ModDB, DXEditingTools (Blade_Sword), S.T.A.L.K.E.R. PROJECT (Lurker), упоминания Nihilum. Вопрос к
  Tantalus.
- Доски на вывесках `CityOnTheHill` и `LastSupperSalon`: текстовым поиском источник не определить (типовые фото
  старого дерева); обратный поиск по картинке не делался. Риск низкий.

## Что стороннего осталось (25.10.2026, после пересборки)

Установщик `Build/CodenameNebula_v1.5.0.exe` — 95,3 МБ (было 98,9 МБ 22.10), папка поставки — 250 МБ.
Целиком сторонние пакеты в ней — около 104 МБ (42 %), из них ≈53 МБ игра не грузит вовсе.

| Что | В поставке | Автор / источник | Статус |
|---|---|---|---|
| `DXRVNewVehicles.u` — танк в доках (1 меш и 1 текстура из 15 и 77) | 46,8 МБ, из них ≈46 мёртвые | Deadalus08 | в титрах; облегчить пересборкой |
| `LosAngelesTex.utx` — 6 фото и экранов (L2, концовки) | 23,5 МБ | не известен | **главный открытый вопрос** |
| `GaussGun.u` — койлган Магдалины (10 текстур, 3 меша, звуки, код) | 14,5 МБ | Bowen Wong, правки Y\|yukichigai (через Nihilum) | в титрах |
| `ArtPieces.utx` — 3 картины (Луна, доки, Mutiny) | 13,0 МБ, ≈7 мёртвые | картины — общественное достояние; снимки — не известно | низкий риск |
| `PFAD.u` + `PFADTex.utx` — 81 текстура и меши батончиков и напитков | 5,7 МБ | Prototype | в титрах; настоящие бренды на обёртках |
| `DXOgg.dll/.u`, `D3D9Drv.dll` | 0,5 МБ | Jim (TNM); Chris Dohnal | в титрах |
| В `CNN.u`: HUD (12 текстур) и модели Nihilum | — | FastGamerr, CC; разрешение 2017 | в титрах |
| В `CNN.u`: «Custom Decorations» — ≈80 скинов и их меши (кнопки, канистры, журналы, раковины, трубы…) | — | не известно | открытый вопрос |
| В `CNN.u`: модели `SciFiFighter`, `Ship1` | — | «free sci-fi fighter», не известно | открытый вопрос |
| В `CNN.u`: `rammstein3`, `xmas_banner`, фото Честера в титрах | — | чужие изображения | `rammstein3` — заменить; остальное уточнить |
| В `CNN.u`: Олдрин, Земля, Марс | — | NASA, общественное достояние | в порядке |
| В `CNN.u`: 9 текстур станции из Zortch; снимок «тарелки» | — | CC0; общественное достояние (ВВС США) | в титрах |
| Код `WeaponSnowblind` | — | заготовка из Shifter (Y\|yukichigai) | в титрах |
| Музыка: «The Spark» (Solar Smoke), «The Last Frontier» (Luke West) | 2 трека из 12 | указаны | проверено 28.10: обе на Bandcamp под **CC BY-NC-ND 4.0** (некоммерческое, с автором, без переделки — подходит); в титрах с лицензией; остальные 10 — команды |
| Звук аплодисментов | — | Yannick Lemieux, CC BY 3.0 | в титрах |
