# Почему запуск CNN такой сложный: сравнение с Burden of 80 Proof и Zodiac

*2026-10-22, анализ без изменений в репозитории. Пометки: **[проверено]** — видел сам в коде, в файле или
на странице источника; **[вывод]** — моё заключение, не проверено запуском.*

## Коротко

1. **B80P и Zodiac сегодня тоже не «просто работают».** Это моды 2006–2007 годов. Их установщики рассчитаны на
   CD/1112fm: они кладут файлы в папку игры и запускают переименованную копию `DeusEx.exe`. На текущем Steam они
   ломаются ровно там же, где CNN: мёртвый ярлык, «flashes and goes to desktop», «Failed to find Steam», ручной
   выбор рендерера, ручная правка INI. В комментариях 2025–2026 годов игроки чинят это сами: ставят лаунчер
   Kentie или Hanfling, правят ярлыки по гайдам, запускают сторонний установщик «Deus Ex Setup 2026». **[проверено]**,
   ссылки ниже.
2. Значит, разница не в том, что у них нет проблем, а в том, **кто эти проблемы решает**. У B80P и Zodiac их
   решает игрок (или сообщество, через Kentie). CNN пытается запуститься на *стоковой* установке для всех
   четырёх вариантов игры (Steam с DRM-стабом, GOG, CD, Kentie/Han/CU), и эта машинерия нужна именно для этого.
3. Сверх общих проблем у CNN есть **три зависимости, которых у B80P и Zodiac (насколько видно) нет**: DXOgg
   (музыка в .ogg), RenderExt (замена `Render.dll`) и D3D9Drv. Каждая — нативная DLL, а нативную DLL движок
   грузит из папки игры, не из папки мода. Отсюда почти всё, что CNN копирует *в чужие папки*.
4. Самые дешёвые упрощения: `OggPath=` в CNN.ini (перестать копировать 12 .ogg в `Music\Ogg` игры) и не копировать
   `DXOgg.u` в System игры. Самое крупное — отказаться от RenderExt (`Render=Render.Render`); это заодно снимает
   открытый вопрос лицензии: автор RenderExt неизвестен.

---

## 1. Что CNN делает при установке и запуске

### 1.1 Цепочка

| Шаг | Где в коде | Что делает |
|---|---|---|
| Сборка дистрибутива | `cnn.bat :package` | Кладёт в `CodenameNebula\` карты, текстуры, 12 .ogg в `Music\Ogg`, пакеты в `System\` (в том числе `DXOgg.dll/.u`, `D3D9Drv.dll/.int`, `RenderExt.dll/.int`), `PlayCodenameNebula.bat`, `PlayCNNSteam.bat`, `FixRenderer.bat`, `tools\steam_launch.ps1`, `tools\fix_renderer.ps1`, `CNNInstallUtil.exe` (self-contained .NET single-file, ~32 МБ) |
| Установщик | `cnn.bat :installer` (генерирует .iss) | Inno Setup: `DefaultDirName={sd}\Games\DeusEx\CodenameNebula`, `UsePreviousAppDir=no`, папку Deus Ex **не определяет**. Создаёт ярлыки (в том числе «Steam» — всегда), запускает `CNNInstallUtil.exe`; деинсталлятор читает `CNNGameFiles.txt` и удаляет то, что утилита добавила в папки игры, сверяя SHA1 |
| Настройка | `CNNInstallUtil/.../InstallUtil.cs` `Install()` | `CreateCNNIni` (из `DeusEx.ini` игрока), `CreateCNNUserIni`, `CopyMusicFiles`, `CopyRenderExt`, `DetectAndPrepareLauncher`, `CreateShortcuts` (ещё раз, через PowerShell), `SaveGameFiles` |
| Dev-установка | `cnn.bat :install` + `tools/generate_cnn_ini.ps1` | Второй, независимый генератор CNN.ini (PowerShell) |
| Запуск | `PlayCodenameNebula.bat` (пишется утилитой) | Прямой запуск `"<игра>\System\<exe>" INI="…\CNN.ini" USERINI="…\CNNUser.ini"` или, для Steam-стаба, `tools/steam_launch.ps1` → `steam://rungameid/6910//INI=%22…%22 USERINI=%22…%22` |
| Ремонт | `FixRenderer.bat` → `tools/fix_renderer.ps1` | Переписывает рендерер на D3D9/OpenGL и цвет на 32 бит; режим `-Windowed` |

### 1.2 Что CNN кладёт **вне** своей папки **[проверено, `InstallUtil.cs`]**

| Файл | Куда | Зачем | Источник проблемы |
|---|---|---|---|
| `RenderExt.dll`, `RenderExt.int` | `<игра>\System` (с перезаписью) | `CNN.ini: Render=RenderExt.RenderExt`. Пакет без .u: движок грузит DLL через `LoadLibrary`, а `Paths=` на это не влияет | Коммит `04a5ab9` (v1.3.9), память `feedback_cd_version`: без копии — `Can't find file for package 'RenderExt'` |
| `DXOgg.dll` | `<игра>\System` (с перезаписью) | Нативный проигрыватель .ogg (`DXOggMusicManager`) | То же правило для DLL |
| `DXOgg.u` | `<игра>\System` (с перезаписью) | — | **Судя по всему, лишнее:** .u находится через `Paths=..\CodenameNebula\System\*.u` [вывод] |
| `D3D9Drv.dll`, `D3D9Drv.int` | `<игра>\System`, только если их там нет | Рабочий рендерер на Win10/11. В стоковом Steam/CD есть только Glide/D3D7/OpenGL/Soft | `1af2586` (v1.4.4), CLAUDE.md «Failed resetting mode» |
| 12 × `.ogg` | `<игра>\Music\Ogg` (с перезаписью; папки создаются) | DXOgg ищет файлы в `..\Music\Ogg\` относительно рабочей папки | Строки `DXOgg.dll`: `..\Music\Ogg\`, `Core.System`, `OggPath` **[проверено]** |
| `CodenameNebula.exe` | `<игра>\System` (только для ~254 КБ exe) | Переименованная копия 1112fm/CD: обход CD-проверки | `04a5ab9`, `feedback_cd_version` |
| Ярлыки | Рабочий стол, меню «Пуск» | Создаются дважды: в Inno `[Icons]` и в `CreateShortcuts` через PowerShell | — |

Распознавание exe по размеру **[проверено, `InstallUtil.cs:30-32, 207-246`]**: больше 300 000 байт — Kentie/Han;
меньше 100 000 — Steam DRM-стаб (64 000 байт, сборка 2025-09-27), запуск через `steam://`; до 200 000 — обёртка
CU; иначе — 1112fm/CD с переименованием.

### 1.3 Почему каждая часть существует

- **Генерация CNN.ini из DeusEx.ini игрока** — чтобы унаследовать рендерер, разрешение и звук, а мёртвые значения
  (Glide, D3DDrv, 16 бит, 640×480) заменить. Коммиты `6a2a30c`, `12c4abf`, `1af2586`. Zodiac со статическим INI
  упирается в то же самое: на GOG у игроков тормозило меню из-за неподходящего рендерера, и лечили это вручную
  удалением `DeusEx.ini` (см. 2.2).
- **Переименованный exe** — CD-защита (`04a5ab9`). Так же делали Zodiac и B80P (см. ниже), только у них
  переименование безусловное.
- **`steam://`** — DRM-стаб Steam с 2025-09 запускается только самим Steam (`42c9c59`). Игроки B80P и Zodiac
  получают на этом месте мёртвый ярлык.
- **Steam-ярлык** — оверлей и учёт времени (`6a2a30c`, `5c25902`).
- **FixRenderer** — в игровом диалоге «Rendering Device…» есть мёртвый D3DDrv (`6e4d354`).
- **HD-автодетект** (NewVision/HDTP) — функция, а не обход (`2dd70bd`).

---

## 2. Burden of 80 Proof и Zodiac

### 2.1 Burden of 80 Proof

- **Автор:** `scottc` (Scoptic, scoptic.com), а не Blade. Blade_Sword на ModDB только комментатор. Вышел
  в 2007 году, последняя версия 2.0 (2007-05-04). **[проверено]** [ModDB][b80p]
- **Дистрибутив:** один исполняемый установщик `burdenof80proof2.0.exe`, 40,6 МБ, плюс «untested» набор файлов
  для Mac. **[проверено]** [ModDB файл][b80p-file]
- **Запуск:** ярлык в меню «Пуск». Exe мода — переименованная копия `DeusEx.exe` (Burden.exe). Это вывод из поста
  2009 года: игрок починил B80P и TNM тем, что скопировал обычный exe и переименовал его в имя мода. Тот же
  механизм, что `CodenameNebula.exe` у CNN. Запущенный из другого места мод пишет «Nope you cannot start it here».
  **[проверено — посты; имя Burden.exe — вывод]** [GameFAQs][gf-b80p], [ModDB комментарии][b80p-file]
- **Steam:** проблемы были всегда. В 2009 году: «it uses a modified DeusEx.exe which only works through the Steam
  program». В 2018-м: «It doesnt create a shortcut icon». **4 октября 2026**: установлен в папку Deus Ex, запуск из
  «Пуска», «just flashes and goes to desktop». Тогда же на ModDB советуют для Steam
  [Deus Ex Setup 2026][dxsetup2026] — он ставит Kentie DeusExe v8.1 вместо `DeusEx.exe`, D3D10/D3D11 и правит
  DeusEx.ini. **[проверено]** [Steam-гайд][story-guide], [ModDB][b80p-file]
- **Музыка, DLL, рендерер:** судя по описанию («old-schooly music»), музыка в .umx (трекерная). Нативных DLL
  и своего рендерера не найдено. **[вывод — установщик не скачивал]**
- Загрузчик кампаний Vanilla Madder B80P не поддерживает. **[проверено]** [Steam-гайд][story-guide]

### 2.2 Zodiac

- **Автор:** SteveTack, 2006 год. `Zodiac_Full_Version.zip`, 61,65 МБ: «Windows installer and Read Me»; нужна
  версия 1.109+. **[проверено]** [ModDB][zod-file]
- **Задумка автора:** «completely automatic installer and uninstaller and is launched with its own icon», без
  отдельного загрузчика модов. **[проверено]** [Zodiac FAQ][zod-faq]
- **Что ставится:** путь по умолчанию — `C:\DeusEx`; `Zodiac.ini`/`ZodiacUser.ini` кладутся **в `DeusEx\System`
  игры**; цель ярлыка — `Zodiac.exe`. **[проверено]** [GOG][gog-zod], [ModDB комментарии][zod]
- **Steam:** сентябрь 2026 — «Definitely won't work on the Steam GOTY version. the installer won't even install the
  zodiac.exe but it adds the shortcut which is dead». Обходы сообщества **[проверено]**:
  - вручную сделать ярлык `DeusEx.exe INI=Zodiac.ini USERINI=ZodiacUser.ini` (так сейчас делает CNN);
    [Steam-гайд][story-guide], [GOG][gog-zod]
  - Kentie: перенести мод в `Deus Ex\Zodiac`, создать `zodiac.ini` из DeusEx.ini, вручную прописать
    `DefaultGame=Zodiac.MyGameInfo`, launch options `-localdata USERINI=… INI=…` и галочка «data directories»;
    [Steam-тред][steam-zod]
  - у Kentie INI нужно копировать в `Documents\Deus Ex\System`, иначе мод открывает главное меню и дальше
    не идёт. [ModDB комментарии][zod]
  - на GOG/Win11 — скопировать всю игру в `C:\DeusEx` и ставить туда, «чтобы мод не испортил» основную
    установку. [ModDB комментарии][zod]
- **Музыка:** саундтрек Orak, отдельно раздавался в MP3 для прослушивания. В игре он, скорее всего, в .umx:
  UE1/Galaxy не умеет MP3 без расширения. **[вывод]** [Zodiac site][zod-site]
- Нативных DLL и своего рендерера не найдено. **[вывод]**

### 2.3 Как сейчас «работают» старые моды на Steam

Ни B80P, ни Zodiac не обновлялись после изменений Steam. Работают они у тех, кто уже поставил **Kentie DeusExe
или Hanfling Launch**: те заменяют стаб в `System\DeusEx.exe` настоящим движковым exe. Отсюда ощущение «у них
всё работает»: после Kentie проблему DRM-стаба для игрока снимает Kentie, а не мод. На машине разработчика
`System\deusex.exe` — Kentie (402 432 байта), поэтому направление `steam://` тут годами не проверялось.
**[проверено — файл; обобщение — вывод]**

«Failed to find Steam» встречается на форумах как минимум с 2020 года (лечили копированием `steam.dll` в System),
а «modified DeusEx.exe which only works through the Steam program» — с ~2009-го. Значит, Steam-exe с привязкой
к клиенту существовал и до сборки 2025-09-27. **[проверено — посты; связь со сборкой 2025 — вывод]**
[Steam-тред 2020][steam-fts], [GameFAQs][gf-b80p]

---

## 3. Сравнение

| Аспект | CNN | B80P | Zodiac | Следствие |
|---|---|---|---|---|
| Год, рассчитан на | 2026; Steam-стаб, GOG, CD, Kentie/Han/CU | 2007; CD/1112fm | 2006; CD/1112fm (1.109+) | CNN поддерживает варианты игры, которых в 2006–07 не было |
| Установщик | Inno + CNNInstallUtil (.NET, ~32 МБ) | Свой установщик .exe | Установщик в .zip | Все трое ставятся установщиком; у CNN вторая стадия — утилита |
| Куда ставится | `<игра>\CodenameNebula` (путь выбирает игрок, автодетекта нет) | В папку Deus Ex | По умолчанию `C:\DeusEx`, INI — в `System` игры | Zodiac/B80P мусорят в System игры сильнее CNN; отсюда конфликты модов (GameFAQs, «ReadFile beyond EOF») |
| Exe | `DeusEx.exe` + `INI=`; копия `CodenameNebula.exe` только для 1112fm/CD; `steam://` для стаба | Переименованная копия (Burden.exe) [вывод] | Переименованная копия `Zodiac.exe` | Переименованная копия Steam-стаба не запускается: у B80P/Zodiac мёртвый ярлык, CNN это обходит |
| INI | Генерируется из DeusEx.ini игрока, мёртвые значения правятся | Статический [вывод] | Статический; на Steam/Kentie игрок правит руками | CNN автоматизирует то, что у Zodiac описано в гайдах |
| Рендерер | Свой `Render=RenderExt`; D3D9Drv в комплекте; FixRenderer | Стоковый [вывод] | Стоковый; игроки вручную меняют OpenGL→D3D | RenderExt и D3D9Drv — две DLL в System игры |
| Музыка | .ogg через DXOgg (DLL + .ogg в `Music\Ogg` игры) | .umx [вывод] | .umx [вывод] | **Главная лишняя сложность CNN, по выбору дизайна** |
| Нативные DLL | RenderExt, DXOgg, D3D9Drv | Не найдено | Не найдено | DLL нельзя держать в папке мода, если запускается exe из `<игра>\System` |
| Steam-оверлей | Отдельный ярлык через `steam://` | Нет | Нет (только через launch options) | Функция, которой у них нет |
| Steam-стаб 2025 | Обнаружен, обходится `steam://` | Ломается (2026-10) | Ломается (2026-09) | |
| Деинсталляция вне папки | Список SHA1 в `CNNGameFiles.txt` | Неизвестно | Неизвестно | Своя бухгалтерия вместо встроенной в Inno |
| Объём | 9 карт, 125 МБ, 4 концовки, озвучка | 6 карт, ~40 МБ | 6 миссий, ~62 МБ | |

---

## 4. Что можно упростить — по убыванию пользы/цены

| № | Шаг | Трудоёмкость / риск | Что уйдёт | Как проверить |
|---|---|---|---|---|
| 1 | **`OggPath=` в `[Core.System]` CNN.ini** — на папку мода. Лучше абсолютный путь с `\` на конце: утилита и так генерирует INI, а рабочая папка при запуске через `steam://` неизвестна [вывод]. В `CopyMusicFiles` убрать копирование .ogg и создание `Music`/`Music\Ogg` | S / низкий | 12 файлов и 2 папки в игре, их учёт при удалении, коллизии имён с .ogg других модов. Уровень загрузки: ключ `OggPath` в DXOgg.dll есть **[проверено]**, чтение и склейку с именем не проверял | Лог: `DXOgg: Error - Either could not find or could not open Ogg File` (память `feedback_deusex_engine`), bridge ASSETCHECK. Запуск прямой и через `steam://` |
| 2 | **Не копировать `DXOgg.u`** в System игры | S / низкий | 1 файл | ASSETCHECK; убедиться, что в `Paths=` есть `..\CodenameNebula\System\*.u` (есть в `InjectIniProperties`) |
| 3 | **Не перезаписывать чужие `DXOgg.dll`/`RenderExt.dll`**: сейчас `CopyIntoGame(..., true)` затирает версию другого мода, а деинсталлятор её не восстанавливает (файл был до CNN и в список не попадает) | S / низкий | Тихую порчу соседнего мода в базовой папке | Код-ревью `InstallUtil.cs:744-794` |
| 4 | **Отказаться от RenderExt** (`Render=Render.Render`) | M / средний | 2 DLL в System игры, отказ `Can't find file for package 'RenderExt'` на CD, открытый вопрос лицензии (автор неизвестен, `ThirdParty_Credits_Draft.md`). Скриптов CNN, которые его используют, нет **[проверено, grep]**. По замеру 2026-08-26 на L2 RenderExt рисовал серые клинья, стоковый Render — правильно (память `feedback_deusex_engine`) | Визуальный проход по 9 картам, особенно WarpZone/зеркала (у RenderExt свои `HandleMirrorWarp`/`HandleWarpPortal`/`MaxFrameRecursion`), и сравнение FPS. Решение за автором: раньше RenderExt решили оставить |
| 5 | **Определять способ запуска при каждом запуске, а не при установке**: один `PlayCodenameNebula.bat`/`.ps1` смотрит размер `DeusEx.exe` в момент старта (стаб → `steam://`, иначе прямой запуск) | S–M / низкий | Поломку при обновлении exe после установки. Именно так случилось в 2025-09: установки CNN с прямым bat умерли молча. Ещё уходит поломка, если игрок поставит Kentie позже | Подменить exe (стаб ↔ 1112fm) без переустановки |
| 6 | **Убрать дубли ярлыков**: их создают и Inno `[Icons]`, и `CreateShortcuts` через PowerShell. Inno-ярлык «Steam» создаётся даже на CD/GOG, хотя утилита его там нарочно пропускает. На Steam-стабе оба ярлыка делают одно и то же | S / низкий | Путаницу у игрока, обход PowerShell для Unicode-путей | Чистая установка: какие `.lnk` появились |
| 7 | **Один генератор CNN.ini вместо двух**: `generate_cnn_ini.ps1` (`cnn install`) и `InstallUtil.cs` расходятся. PS1 всегда ставит родное разрешение, C# оставляет разрешение игрока от 800×600; разная логика `safeRenderer` | M / низкий | Расхождение dev и релиза: баг, найденный на `cnn test`, может не воспроизвестись у игрока | `cnn install` запускает собранный `CNNInstallUtil.exe` в temp-копии |
| 8 | **Автодетект папки Deus Ex в Inno**: `DefaultDirName={code:…}` по реестру (Steam: `HKLM\…\Uninstall\Steam App 6910\InstallLocation`; GOG; CD), который `cnn.bat` уже умеет читать | S–M / низкий | Ошибку «поставил не туда»: при `{sd}\Games\DeusEx\CodenameNebula` и `UsePreviousAppDir=no` игрок обязан найти папку Steam сам, а `..\System` от неверной папки молча не существует | Установка на чистый Steam/GOG |
| 9 | **Заменить CNNInstallUtil на Pascal Script в Inno** | L / средний | 32 МБ .NET-exe, свою SHA1-бухгалтерию (у Inno есть флаги `onlyifdoesntexist`/`uninsneveruninstall` и встроенный учёт файлов, поставленных в `{app}\..\System`), PowerShell-ярлыки. Проверка размера exe (`FileSize`) и построчная правка INI (`LoadStringsFromFile`/`SaveStringsToFile`) в Pascal делаются; `SetIniString` не годится: в UE1-INI повторяются ключи `Paths=` [вывод] | Полная матрица чистых установок (Steam-стаб, GOG, CD, Kentie) |
| 10 | **Музыку в .umx** — как, вероятно, у B80P/Zodiac. Убрало бы DXOgg совсем. Трекерные модули UE1 оркестровую запись хранят только как длинный сэмпл: размер и качество хуже [вывод] | L / высокий | DXOgg.dll, `DXOggMusicManager` | Только если важно «ноль DLL» |
| 11 | **Проверить `steam.dll` рядом со стабом** (форумный фикс 2020 года). Возможно, стаб тогда стартует напрямую, и `INI=` доходит без `steam://` | S на проверку / неизвестен | Возможно, `steam://`. Но копировать бинарник Valve — тоже машинерия, а DRM-обёртки обычно перезапускают процесс через Steam и могут потерять аргументы [вывод] | Чистая копия депо (`download_depot 6910 6911 8456979172979270170`) |
| 12 | **OpenGL вместо поставки D3D9Drv**, когда D3D9 нет | M / средний | 2 файла в System игры. Плюс: со стоковым OpenGL работает Steam-оверлей (память `feedback_renderer_overlay`). Минус: качество и баги OpenGL 1112fm | Визуальный проход |

**Чего не трогать:** генерацию CNN.ini из DeusEx.ini (это автоматизация ровно того, что игроки Zodiac делают по
гайдам), FixRenderer, обход Steam-стаба через `steam://` и переименование для CD. Всё это ответы на реальные
поломки, которые B80P и Zodiac не решают, а отдают игроку.

**Можно ли обойтись статическим CNN.ini и одними `Paths=`?** Только если требовать от игрока заранее
настроенную игру (Kentie, рабочий рендерер) — то есть принять модель B80P/Zodiac. Относительные `Paths=` уже
работают при папке `<игра>\CodenameNebula`. Генерацию оправдывают разрешение, 16-битный цвет и мёртвые
рендереры. Пункты 1–3 и 5–8 упрощают установку и без отказа от генерации.

---

## Источники

- [b80p]: https://www.moddb.com/mods/burden-of-80-proof — автор scottc, 2007, v2.0, установщик .exe
- [b80p-file]: https://www.moddb.com/mods/burden-of-80-proof/downloads/burden-of-80-proof-20 — `burdenof80proof2.0.exe`; комментарии 2018 и 2026 о ярлыке, «cannot start it here», Steam
- [gf-b80p]: https://gamefaqs.gamespot.com/boards/250533-deus-ex/50500536 — Steam «modified DeusEx.exe», моды копируют exe, обход переименованием (Burden, TNM)
- https://gamefaqs.gamespot.com/boards/250533-deus-ex/41483554 — B80P «ReadFile beyond EOF» рядом с Zodiac/HDTP в той же папке
- [story-guide]: https://steamcommunity.com/sharedfiles/filedetails/?id=2382743089 — Mrpoke «Deus Ex Story Mods»: Zodiac через ярлык `INI=`, B80P не в Vanilla Madder, комментарий 2026-10-04
- [zod]: https://www.moddb.com/mods/zodiac — SteveTack, 2006; комментарии 2019–2026 (Kentie, INI в Documents, мёртвый ярлык на Steam GOTY)
- [zod-file]: https://www.moddb.com/mods/zodiac/downloads/zodiac-full-version — `Zodiac_Full_Version.zip`, 1.109+
- [zod-faq]: https://gamespy-archives.quaddicted.com/sites/www.planetdeusex.com/zodiac/faq.html — «completely automatic installer…»
- [zod-site]: https://gamespy-archives.quaddicted.com/sites/www.planetdeusex.com/zodiac/ — саундтрек в MP3
- [gog-zod]: https://gog.com/forum/deus_ex_series/cant_play_zodiac_mod — `Zodiac.ini`/`ZodiacUser.ini` в `DeusEx\System`, ярлык `INI=`, проблема с рендерером
- [steam-zod]: https://steamcommunity.com/app/6910/discussions/0/2626094856504856332 — Zodiac через Kentie, `-localdata`, ручной `DefaultGame=`
- [steam-fts]: https://steamcommunity.com/app/6910/discussions/0/1743392703801733978 — «Failed to find Steam» (2020), фикс через `steam.dll`, совет Kentie/Hanfling
- [dxsetup2026]: https://github.com/StayOutOfTheLadiesRestroom/Deus-Ex-Setup-2026 — сторонний установщик Kentie + D3D10/11 + правки INI, его советуют для B80P в 2026
- https://kentie.net/article/dxguide/ — Kentie DeusExe: «replacement executable», совместим со Steam GOTY
- Репозиторий: `CNNInstallUtil/CNNInstallUtil/InstallUtil.cs`, `cnn.bat` (`:package` `:installer` `:install` `:test`), `tools/steam_launch.ps1`, `tools/generate_cnn_ini.ps1`, `tools/fix_renderer.ps1`, `CodenameNebula/*.bat`, `CNN/System/DXOgg.dll` и `RenderExt.dll` (строки), `git log` с 2026-04

[b80p]: https://www.moddb.com/mods/burden-of-80-proof
[b80p-file]: https://www.moddb.com/mods/burden-of-80-proof/downloads/burden-of-80-proof-20
[gf-b80p]: https://gamefaqs.gamespot.com/boards/250533-deus-ex/50500536
[story-guide]: https://steamcommunity.com/sharedfiles/filedetails/?id=2382743089
[zod]: https://www.moddb.com/mods/zodiac
[zod-file]: https://www.moddb.com/mods/zodiac/downloads/zodiac-full-version
[zod-faq]: https://gamespy-archives.quaddicted.com/sites/www.planetdeusex.com/zodiac/faq.html
[zod-site]: https://gamespy-archives.quaddicted.com/sites/www.planetdeusex.com/zodiac/
[gog-zod]: https://gog.com/forum/deus_ex_series/cant_play_zodiac_mod
[steam-zod]: https://steamcommunity.com/app/6910/discussions/0/2626094856504856332
[steam-fts]: https://steamcommunity.com/app/6910/discussions/0/1743392703801733978
[dxsetup2026]: https://github.com/StayOutOfTheLadiesRestroom/Deus-Ex-Setup-2026
