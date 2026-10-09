# Аудит сторонних ресурсов и разрешений (перед релизом v1.5.0)

Проведён 09.10.2026 по сборке `Build/CodenameNebula_v1.5.0.exe` (198,3 МБ, master `3b83afc`).
Это не юридическое заключение, а опись: что лежит в установщике, откуда оно, указано ли в
титрах (`CNN/Text/credits/CNNCredits.txt`) и что сделать до публикации.

**Контекст лицензии.** Мод распространяется под CC BY-NC-SA 3.0 (`CNNInstaller/InfoLicense.txt`).
Чужие ресурсы этой лицензией не покрываются: на каждый нужен либо явный разрешающий статус
(свободная лицензия, разрешение автора), либо его надо убрать. Сторонние ресурсы стоит
перечислить в титрах и в README с пометкой, что они остаются под условиями своих авторов.

Использование проверено по таблицам имён карт (`Maps/*.dx`) и `CNN.u`, по `#exec`-импортам и
по `.uc`. «Не используется» = нет ни одной ссылки, файл просто лежит в установщике.

## 1. Убрать или заменить до релиза (высокий риск)

| Ресурс | Где | Используется | Происхождение | Что делать |
|---|---|---|---|---|
| `CNN/Sounds/XFilesTheme.wav` (в `CNN.u`, звук `XFilesTheme`) | L1 (`06_OpheliaL1.dx`) | да | Тема «Секретных материалов» (Mark Snow / 20th Century Fox) | Заменить своим или свободным звуком; разрешение получить нереально |
| `Music/Ogg/X_FilesThemePianoStringsVersion(HD).ogg` | — | **нет** | Кавер той же темы | Удалить из установщика |
| `CNN/Sounds/ChesterScream.wav` (звук `ChesterScream`) | интро на Луне (`05_MoonIntro.dx`) | да | Судя по имени — крик Честера Беннингтона из записи Linkin Park (Warner) | Заменить; если это запись не из альбома, а записанная командой — уточнить и оставить |
| `CNN/Sounds/dsdoropn.wav` (звук `DoorOpen1`) | `CNN.u` | да | Коммит `1fa100e`: «Added DOOM 1 door sound» (id Software / ZeniMax) | Заменить звуком двери из Deus Ex (`MoverSFX`) |
| `Textures/GenFX.utx` | L1 | да | Имя стокового пакета Unreal / UT (Epic); в Deus Ex его нет. Проверить содержимое | Если это пакет Epic — заменить текстуры на L1 стоковыми DX (в UnrealEd) |
| Текстуры «STALKERProject files by Lurker» (в титрах) | — | см. п. 3 | Если это текстуры из самой игры S.T.A.L.K.E.R. (GSC), это рип ассетов игры | Уточнить, что именно и где; рип чужой игры не лицензируется |

## 2. Не используется, но лежит в установщике — удалить (~170 МБ)

Уже найдено в `Installer_Audit.md`; теперь есть и лицензионная причина удалить: эти файлы
поставляются без указания авторов.

| Файл | Почему важно |
|---|---|
| `Music/Ogg/Royalty_Free_Music_*` (3 трека), `Epic_North_Music_…`, `Arabic_Hybrid_Sci_Fi_Music_…`, `Humankind_Battle`, `Anthemn_Battle`, `The_Intangible_Lost_In_Andromeda` | «Royalty free» обычно требует указания автора и не разрешает перераспространение файлов как есть |
| `Music/Ogg/Stellardrone_I_Dont_Belong_Here.ogg` | Stellardrone публикуется под CC BY — без указания автора нарушение |
| `Music/Terrified.umx` | Происхождение неизвестно |
| `Textures/AITex.utx` (94 МБ), `Textures/X3tex.utx` (32 МБ) | Свои (Apocalypse Inside), но не нужны |
| `RootSystemFiles/` | Мусор сборки |

После удаления — прогон мостом по всем картам (поиск `Failed to load` / `Can't find` в логе).

## 3. Нужно разрешение или хотя бы упоминание автора

| Ресурс | Где | Автор / источник | В титрах | Что сделать |
|---|---|---|---|---|
| `System/GaussGun.u` (15 МБ) — основа `CNNWeaponCoilGun` | L1, `CNN.u` | Gauss Gun от **Bowen Wong**; правки **yukichigai** (`// Modified -- Y|yukichigai`) | **нет** | Найти readme Bowen (условия использования); добавить в титры Bowen Wong и yukichigai |
| `CNN/Classes/WeaponSnowblind.uc` (Snowblind EMP Disruptor) | `CNN.u` | Пометка «Modified — yukichigai»; исходное оружие, вероятно, тоже чужое | **нет** | Уточнить источник; добавить в титры |
| `System/DXRVNewVehicles.u` (49 МБ) | доки | «NewVehicles by **Deadalus08**» | да | Есть ли явное разрешение? Ссылка на страницу мода |
| `System/PFAD.u`, `Textures/PFADTex.utx` | доки, Луна, L1 | «Custom Consumables by **Prototype**» (PFAD) | да («Prototype candybars») | Проверить условия PFAD; в именах есть чужие бренды (Monster, Jolt, Snickers) — низкий риск |
| `System/DXOgg.dll`, `DXOgg.u` | все карты (музыка) | «DXOgg Ogg Extension for Deus Ex», © 2005–2009, автор не указан в файле | **нет** | Найти автора/readme, добавить в титры |
| `System/D3D9Drv.dll` | рендерер по умолчанию | Вероятно, D3D9-рендерер **Chris Dohnal** (cwdohnal.com: только «Copyright 2002-2010 Chris Dohnal», условий нет) | **нет** | Проверить readme/исходники в его архиве; добавить в титры |
| `CNN/System/RenderExt.dll` | расширение рендера | Вероятно, Render Extension от **Han** (подтвердить) | **нет** | Подтвердить автора, добавить в титры |
| HUD: `UBHUD_*`, `NewHUDHitDisplay_*` (в `CNN.u`) | весь HUD | **Nihilum HUD** из Deus Ex: Nihilum SDK (**FastGamerr**); `UBHUD_` = UNATCO Born, откуда его взял Nihilum. Разрешение — см. ниже | **нет** | Добавить в титры и README строку про Nihilum |
| Модель истребителя: `SFighter`, `SciFi_Fighter_AK5-diffuse`, `SFShipHigh`, `ObserX` | `CNN.u` | Похоже на модель с CGTrader / TurboSquid | **нет** | Найти источник и лицензию (у стоковых моделей часто запрещено перераспространение «как файла», в игре — обычно можно) |
| Sci-fi текстуры Milosh-Andrich (deviantart, Sci-fi pack 01 / 03) | вероятно `Ophelia.utx` | Milosh-Andrich | да | Проверить условия на странице паков |
| Музыка: «The Spark» (Solar Smoke), «The Last Frontier» (Luke West) | `06_Mutiny`, меню; доки | указаны | да | Проверить лицензии (обычно «бесплатно с указанием автора») |
| Музыка без авторов в титрах: `Ambient_2_for_Deus_Ex`, `Anthem` (меню), `Area51_Leaving` (Луна), `WhoAmI` (Луна), `HijackingTheSpaceStationAmbient/Convo`, `MagdaleneTheme_battle` (L2, концовки) | карты | неизвестно (возможно, Project X-3 или команда) | частично | Уточнить; `Area51_Leaving` — не ремикс ли саундтрека Deus Ex? |
| `Textures/TITAN.utx` | Луна, доки, L1 | Имена `ClenRcktCkpit_*`, `slo_rckt_*`, группа `Silo` — похоже на текстуры ракетной шахты из Unreal / UT | **нет** | Уточнить у Tantalus (коммит `4d00140`); если это Epic — как GenFX |
| `Textures/LosAngelesTex.utx` | L2, концовки | Фото (Hollywood, «CityOnTheHill», «lasky» и др.), коммит `a4600d8` Tantalus | **нет** | Уточнить источники фото |
| `Textures/ArtPieces.utx` | Луна, доки, Mutiny | Классические картины (Мона Лиза, Тайная вечеря, Вашингтон пересекает Делавэр, Ада Лавлейс, Коссак) + `RaidPhoto` | — | Картины — общественное достояние; проверить `RaidPhoto` |
| Текстуры `rammstein`, `chester`, `chester_credits` (в `CNN.u`) | `CNN.u`, титры | Логотип группы; фото Честера Беннингтона в титрах «In memory of» | **нет** | Низкий риск; у фото есть фотограф — по возможности указать или заменить |
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

## 4. Свои ресурсы (риска нет)

`CNN.u` (собственный код и модели команды), `CNNText.u`, аудиопакеты `CNNAudioChapter05/06`
(озвучка — команда и указанные в титрах актёры), `Ophelia.utx`, `CNNTextures.utx`,
`AiInfoPortraits.utx`, `X3.utx` (Apocalypse Inside / Project X-3), заглушки `ApocalypseInside*.u`,
модели в `CNN/Models` на основе стоковых моделей Deus Ex (SDK разрешает моды), фото NASA
(`Aldrin_Apollo`, карты Земли и Марса — общественное достояние). **Подтвердить:** Project X-3 —
это команда CNN/Apocalypse Inside (тогда `X3.utx`/`AITex` свои).

## 5. Порядок действий

1. Заменить X-Files, крик Честера, звук двери DOOM; удалить неиспользуемую музыку и пакеты.
2. Выяснить происхождение GenFX, TITAN, STALKER-текстур; при необходимости заменить в UnrealEd.
3. Написать авторам (Bowen Wong, yukichigai, Deadalus08, Prototype,
   Chris Dohnal, Han, автор DXOgg) — или найти их readme с условиями.
4. Дополнить титры и README разделом «Third-party content» со ссылками и лицензиями.
