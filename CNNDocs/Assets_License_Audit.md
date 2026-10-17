# Аудит сторонних ресурсов и разрешений (перед релизом v1.5.0)

Проведён 09.10.2026 по сборке `Build/CodenameNebula_v1.5.0.exe` (198,3 МБ, master `3b83afc`);
дополнен 17.10.2026 (master `3f50d68`): места использования перепроверены по таблицам импорта
всех карт (`tools/pkg_probe.js`), по музыкальным менеджерам `DXOggMusicManager` и по расставленным
актёрам. Это не юридическое заключение, а опись: что лежит в установщике, откуда оно, указано ли
в титрах (`CNN/Text/credits/CNNCredits.txt`) и что сделать до публикации.

**Контекст лицензии.** Мод распространяется под CC BY-NC-SA 3.0 (`CNNInstaller/InfoLicense.txt`).
Чужие ресурсы этой лицензией не покрываются: на каждый нужен либо явный разрешающий статус
(свободная лицензия, разрешение автора), либо его надо убрать. Сторонние ресурсы стоит
перечислить в титрах и в README с пометкой, что они остаются под условиями своих авторов.

«Не используется» = нет ни одной ссылки ни в картах, ни в `CNN.u`, файл просто лежит в установщике.
Стоковые пакеты Deus Ex (`CoreTex*`, `Airfield`, `HK_*`, `MoverSFX`, `Ambient` и т. д.) не перечислены —
их поставляет сама игра.

## 1. Убрать или заменить до релиза (высокий риск)

| Ресурс | Где используется | Происхождение | Что делать |
|---|---|---|---|
| `CNN/Sounds/XFilesTheme.wav` (в `CNN.u`, звук `CNN.Stuff.XFilesTheme`) | **L1**, комната отдыха (бильярд, пинбол, модель Луны, доктор Джонсон с котом, камера `RecRoomCam`): кнопка `Button0` (2713, −1092) шлёт событие `Xfiles`, оно включает `AmbientSoundTriggered1` | Тема «Секретных материалов» (Mark Snow / 20th Century Fox) | Заменить своим или свободным звуком; разрешение получить нереально |
| `Music/Ogg/X_FilesThemePianoStringsVersion(HD).ogg` | **не используется** | Кавер той же темы | Удалить из установщика |
| `CNN/Sounds/ChesterScream.wav` (звук `CNN.Moon.ChesterScream`) | **Луна**: `CNNRandomSounds1`, слот `Sounds[6]` из набора случайных звуков | Судя по имени — крик Честера Беннингтона из записи Linkin Park (Warner) | Заменить; если это запись не из альбома, а записанная командой — уточнить и оставить |
| ~~`CNN/Sounds/dsdoropn.wav` (звук `DoorOpen1`)~~ | **удалён** | Коммит `1fa100e`: «Added DOOM 1 door sound» (id Software / ZeniMax) | **Сделано** (`62d7418`): двери L1 и доков звучат `MoverSFX.door.Pneumatic1Open`/`Pneumatic1Close`, файл и импорт удалены, ссылок в картах и `CNN.u` нет |
| `Textures/GenFX.utx` | **L1**, одна текстура: `GenFX.new2` | Пакет из **Unreal 1** (Epic, файл датирован 17.05.1998). В Deus Ex его нет: ни одна оригинальная карта на него не ссылается; копия `genfx.utx` в `Textures/` установленной игры — посторонняя (все стоковые файлы там из установки Steam) | Заменить одну текстуру на L1 стоковой текстурой DX в UnrealEd и убрать пакет из установщика |
| `Textures/TITAN.utx` | **Луна** (1 текстура: `ClenRcktCpsle_A`), **доки** (9: `slo_rckt_a`, `ClenRcktEngne_A/B/C`, `starslesser03` и др.), **L1** (2: `ClenRcktCpsle_A/B`) | Имена `ClenRcktCkpit_*`, `slo_rckt_*`, группа `Silo` — похоже на текстуры ракетной шахты из Unreal / UT | Уточнить у Tantalus (коммит `4d00140`); если это Epic — заменить, как GenFX |
| Текстуры «STALKERProject files by Lurker» (в титрах) | по именам текстур в картах **не найдены** | Если это текстуры из самой игры S.T.A.L.K.E.R. (GSC), это рип ассетов игры | Уточнить, что именно и где; если не используются — убрать из титров |

## 2. Музыка: где какой трек играет

Музыку проигрывает `DXOggMusicManager` (пакет DXOgg); у каждой карты свой набор треков.

| Карта | Фон (`AmbientOggFile`) | Прочее | Автор |
|---|---|---|---|
| Главное меню (`CNNentry`) | `Solar_Smoke_Post_Silence _07_The_Spark.ogg` | `Anthem.ogg` (бой, разговор, финал, смерть) | The Spark — **Solar Smoke** (в титрах); Anthem — **свой трек** |
| `Entryv2` | `Anthem.ogg` | `Anthem.ogg` во всех слотах | **свой трек** |
| Луна (`05_MoonIntro`) | `WhoAmI.ogg` | `Area51_Leaving.ogg` (финальный трек) | WhoAmI — **уточнить**; Area51_Leaving — **свой трек** |
| Доки | `Mysterious_SciFi_Music_THE_LAST_FRONTIER.ogg` | `f_demo_with_bass.ogg` (бой) | The Last Frontier — **Luke West** (в титрах); f_demo_with_bass — **свой трек** |
| L1 | `Ambient_2_for_Deus_Ex.ogg` | `win_xp_is_life.ogg` (бой) | оба — **свои треки** |
| L2, Hijacking, Transcend | `HijackingTheSpaceStationAmbient.ogg` | `MagdaleneTheme_battle.ogg` (бой), `HijackingTheSpaceStationConvo.ogg` (разговоры) | **уточнить** (вероятно, команда) |
| Conspiracy, Hijacking, Transcend (второй менеджер) | `MagdaleneAndTantalus.ogg` | — | **свой трек** |
| Mutiny | `Solar_Smoke_Post_Silence _07_The_Spark.ogg` | — | **Solar Smoke** (в титрах) |

Свои треки команды (подтвердил автор мода 17.10.2026): `win_xp_is_life`, `Area51_Leaving`, `Anthem`,
`f_demo_with_bass`, `Ambient_2_for_Deus_Ex`, `MagdaleneAndTantalus`. Риска нет; в титрах их можно
указать как музыку команды.

`MusicEvent0` на Луне (тег `PlayHorror`) трек не задаёт — просто останавливает музыку.

## 3. Не используется, но лежит в установщике — удалить (~170 МБ)

Уже найдено в `Installer_Audit.md`; теперь есть и лицензионная причина удалить: эти файлы
поставляются без указания авторов. Перепроверено 17.10.2026: ссылок нет ни в одной карте и ни в `CNN.u`.

| Файл | Почему важно |
|---|---|
| `Music/Ogg/Royalty_Free_Music_*` (3 трека), `Epic_North_Music_…`, `Arabic_Hybrid_Sci_Fi_Music_…`, `Humankind_Battle`, `Anthemn_Battle`, `The_Intangible_Lost_In_Andromeda` | «Royalty free» обычно требует указания автора и не разрешает перераспространение файлов как есть |
| `Music/Ogg/Stellardrone_I_Dont_Belong_Here.ogg` | Stellardrone публикуется под CC BY — без указания автора нарушение |
| `Music/Ogg/X_FilesThemePianoStringsVersion(HD).ogg` | кавер темы X-Files |
| `Music/Terrified.umx` | Происхождение неизвестно |
| `CNN/Sounds/AirBreath.wav` | в `ImportSounds.uc` не импортируется (в установщик не попадает, но лежит в исходниках) |
| `Textures/AITex.utx` (94 МБ), `Textures/X3tex.utx` (32 МБ) | Свои (Apocalypse Inside), но не нужны |
| `RootSystemFiles/` | Мусор сборки |

После удаления — прогон мостом по всем картам (поиск `Failed to load` / `Can't find` в логе).

## 4. Нужно разрешение или хотя бы упоминание автора

| Ресурс | Где используется | Автор / источник | В титрах | Что сделать |
|---|---|---|---|---|
| `System/GaussGun.u` (15 МБ) | На нём построен `CNNWeaponCoilGun` (койлган Магдалины): Луна (2), L2, Hijacking, Transcend; патроны `GaussGun.AmmoGauss` на **L1** | Gauss Gun от **Bowen Wong** (пришёл, вероятно, через Nihilum SDK); правки **yukichigai** (`// Modified -- Y|yukichigai`) | **нет** | Найти readme Bowen (условия использования); добавить в титры Bowen Wong и yukichigai |
| `CNN/Classes/WeaponSnowblind.uc` (Snowblind EMP Disruptor) | на картах не стоит; упоминается в коде L2 (проверка оружия Магдалины) | Пометка «Modified — yukichigai»; исходное оружие, вероятно, тоже чужое | **нет** | Уточнить источник; добавить в титры |
| `System/DXRVNewVehicles.u` (49 МБ) | только **доки**: один танк `BigTank` (масштаб 10) | «NewVehicles by **Deadalus08**» | да | Есть ли явное разрешение? Ссылка на страницу мода. Пакет весит 49 МБ ради одной модели — можно подумать о замене |
| `System/PFAD.u`, `Textures/PFADTex.utx` | Луна (3: `DeathDoorCandy`, `HellsFire`, `DevilMayCry4`), доки (2: `ParanormalActivity`, `Pepsi`), **L1 (60 видов батончиков и напитков)** | «Custom Consumables by **Prototype**» (PFAD) | да («Prototype candybars») | Проверить условия PFAD; в именах есть чужие бренды (Monster, Jolt, Snickers, Pepsi, Red Bull) — низкий риск |
| `System/DXOgg.dll`, `DXOgg.u` | все карты (музыка, см. п. 2) | «DXOgg Ogg Extension for Deus Ex», © 2005–2009, автор не указан в файле | **нет** | Найти автора/readme, добавить в титры |
| `System/D3D9Drv.dll` | рендерер по умолчанию | Вероятно, D3D9-рендерер **Chris Dohnal** (cwdohnal.com: только «Copyright 2002-2010 Chris Dohnal», условий нет) | **нет** | Проверить readme/исходники в его архиве; добавить в титры |
| `CNN/System/RenderExt.dll` | расширение рендера | Вероятно, Render Extension от **Han** (подтвердить) | **нет** | Подтвердить автора, добавить в титры |
| HUD: `UBHUD_*`, `NewHUDHitDisplay_*` (в `CNN.u`) | весь HUD | **Nihilum HUD** из Deus Ex: Nihilum SDK (**FastGamerr**); `UBHUD_` = UNATCO Born, откуда его взял Nihilum. Разрешение — см. ниже | **нет** | Добавить в титры и README строку про Nihilum |
| Модели кораблей — см. п. 5 | Луна, доки | частично неизвестно | **нет** | см. п. 5 |
| Sci-fi текстуры Milosh-Andrich (deviantart, Sci-fi pack 01 / 03) | вероятно, `Ophelia.utx`: доки, L1, L2, Hijacking, Transcend | Milosh-Andrich | да | Проверить условия на странице паков |
| Музыка: «The Spark» (Solar Smoke), «The Last Frontier» (Luke West) | меню и Mutiny; доки (см. п. 2) | указаны | да | Проверить лицензии (обычно «бесплатно с указанием автора») |
| Музыка без подтверждённого автора: `WhoAmI` (Луна), `HijackingTheSpaceStationAmbient/Convo`, `MagdaleneTheme_battle` (L2 и концовки) | см. п. 2 | неизвестно (возможно, команда) | нет | Уточнить; если свои — отметить, как остальные треки команды |
| `Textures/LosAngelesTex.utx` | L2, Hijacking, Mutiny, Transcend | Фото (Hollywood, «CityOnTheHill», «lasky» и др.), коммит `a4600d8` Tantalus | **нет** | Уточнить источники фото |
| `Textures/ArtPieces.utx` | Луна (`AdaLovelace`), доки (`monalisa`), Mutiny | Классические картины (Мона Лиза, Тайная вечеря, Вашингтон пересекает Делавэр, Ада Лавлейс, Коссак) + `RaidPhoto` | — | Картины — общественное достояние; проверить `RaidPhoto` |
| Текстуры `rammstein`, `chester`, `chester_credits` (в `CNN.u`) | титры | Логотип группы; фото Честера Беннингтона в титрах «In memory of» | **нет** | Низкий риск; у фото есть фотограф — по возможности указать или заменить |
| Аплодисменты (Yannick Lemieux, CC BY 3.0) | — | указаны | да | В порядке |
| HDTP, New Vision (в титрах как «Mods used») | — | **не поставляются**: `TantalusDenton` грузит HDTP через `DynamicLoadObject`, только если он установлен | да | В порядке; формулировку в титрах можно уточнить («поддерживается, если установлен») |
| Precipitation mod (в титрах) | — | в коде CNN не найден | да | Проверить, остался ли он на картах; если нет — убрать из титров |

### Deus Ex: Nihilum (DXN)

Из комментариев на странице мода (moddb.com/mods/codename-nebula, 13–15.08.2017): Tantalus_Denton
пишет, что Apocalypse Inside / CNN использует из Nihilum SDK **HUD, карту Белого дома, несколько
моделей и Gauss gun** «под CC-лицензией, как описано в README Nihilum». FastGamerr (автор DXN)
подтвердил и предложил формулировку для README:

> Assets from Deus Ex: Nihilum are used in accordance with the Creative Commons license.

Он же согласился, что под CC попадает только взятое из Nihilum, а не собственная музыка команды.
Статья «Codename Nebula is 3 years old!» (30.03.2017) тоже называет Nihilum SDK «released under
creative commons». Точный вариант CC (BY / BY-NC-SA) — в README самого SDK; в репозитории его нет.
Сам Nihilum содержит материалы UNATCO Born (с разрешения fender2k1) и Revision 2011 — это стоит
упомянуть в той же строке. Gauss gun, вероятно, пришёл через Nihilum SDK (исходный автор — Bowen Wong).

## 5. Модели кораблей и техники

| Модель (класс в `CNN.u`) | Где стоит | Источник | Что сделать |
|---|---|---|---|
| `Ship1` (меш `CNN/Models/ship1_a.3d`) | **Луна** — 3 (`Ship1`, `Shipoutside`, `Spacecraft` — улетающий корабль); **доки** — 3 (`SpacecraftZ` — корабль из интро, ещё два). Текстура стоковая: `DeusExItems.Skins.ReflectionMapTex1` | В репозитории с первого коммита (`3590ccc`, 2016), откуда меш — неизвестно (имя совпадает с примером `ship1.3ds` из конвертера obj2de) | Уточнить источник меша |
| `SciFiFighter` (текстура `SFShipHigh`) | **доки** — 1, уменьшенный (масштаб 0.3) | Коммит `070773a` (2017): «free sci-fi fighter» | Найти источник и лицензию «free» модели |
| `ObserX` | **Луна** — 1 | Из Apocalypse Inside | Свой, если ObserX — модель команды; уточнить |
| `BigTank` (`DXRVNewVehicles`) | **доки** — 1 | Deadalus08 (см. п. 4) | см. п. 4 |
| `SFighter` (AK5, текстура `SciFi_Fighter_AK5-diffuse` при сборке не находится), `Ship2`, `Ship1From3ds` | **на картах не стоят** | AK5 похож на модель с CGTrader / TurboSquid | Можно удалить классы и меши |

На **L1** кораблей нет.

## 6. Свои ресурсы (риска нет)

`CNN.u` (собственный код и модели команды), `CNNText.u`, аудиопакеты `CNNAudioChapter05/06`
(озвучка — команда и указанные в титрах актёры), `Ophelia.utx` (кроме текстур Milosh-Andrich, п. 4),
`CNNTextures.utx` (L1, меню), `AiInfoPortraits.utx`, `X3.utx` (Apocalypse Inside / Project X-3),
заглушки `ApocalypseInside*.u`, оружие `WeaponMicrowaveGun` (L1, из Apocalypse Inside),
модели в `CNN/Models` на основе стоковых моделей Deus Ex (SDK разрешает моды), фото NASA
(`Aldrin_Apollo`, карты Земли `earthMapEast/West` на L1, Марс — общественное достояние),
треки команды из п. 2. **Подтвердить:** Project X-3 — это команда CNN/Apocalypse Inside (тогда
`X3.utx`/`AITex` свои).

## 7. Порядок действий

1. Заменить X-Files (L1, комната отдыха) и крик Честера (Луна); удалить неиспользуемую музыку и пакеты (п. 3).
2. Заменить единственную текстуру `GenFX.new2` на L1; выяснить происхождение TITAN и STALKER-текстур.
3. Уточнить авторов `WhoAmI`, `HijackingTheSpaceStation*`, `MagdaleneTheme_battle`, меша `Ship1` и `SciFiFighter`.
4. Написать авторам (Bowen Wong, yukichigai, Deadalus08, Prototype,
   Chris Dohnal, Han, автор DXOgg) — или найти их readme с условиями.
5. Дополнить титры и README разделом «Third-party content» со ссылками и лицензиями
   и строкой про музыку команды.
