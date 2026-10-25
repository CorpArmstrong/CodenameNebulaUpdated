# Раздел о сторонних материалах (22.10.2026)

Основа — `Assets_License_Audit.md` и проверка мостом (что реально грузится в игре).

## Внесено в титры (`CNN/Text/credits/CNNCredits.txt`)

- Убраны «STALKERProject files by Lurker» и «Precipitation mod»: строки были только в самих титрах, ни
  на картах, ни среди загружаемых объектов таких материалов нет.
- «Mods used» заменён блоком «Third-party content»: Nihilum (FastGamerr, строка про Creative Commons,
  UNATCO Born и Revision 2011), Gauss Gun (Bowen Wong, правки Y|yukichigai), Shifter (Y|yukichigai),
  PFAD (Prototype), New Vehicles (Deadalus08), DXOgg (Jim, The Nameless Mod), D3D9 (Chris Dohnal),
  RenderExt, аплодисменты (Yannick Lemieux, CC BY 3.0); HDTP и New Vision — «Supported if installed».
- Музыка: «Win XP is shit» → «Win XP is life» (как файл); Project X-3 → «Tantalus X-3 Project»; добавлены
  треки Tantalus: Anthem, Magdalene Theme (Battle), Who Am I, Hijacking The Space Station, Area 51
  Leaving, Ambient 2 for Deus Ex. «Finger F**k» = `f_demo_with_bass.ogg` (подтверждено).
- `XFilesTheme.wav` и `ChesterScream.wav` теперь синтезированы `tools/synth_sounds.js` — упоминания не
  требуют.

## Что установлено поиском

- **DXOgg** — из The Nameless Mod (Off Topic Productions); в сообщениях `DXOgg.dll` «Report this to
  jim». В более новой сборке из Revision: «Copyright (C) Jim 2005-2009, 2013-2017 Bjorn». У CNN —
  исходная сборка Jim 2005–2009.
- **Snowblind EMP Disruptor** — ресурсы целиком стоковые (меши и иконки мультитула, стоковые звуки),
  код ~80 строк. «Modified -- Y|yukichigai» — шапка, которую Shifter ставит во все свои изменённые классы:
  класс сделан из исходника Shifter как заготовки. Отсюда строка «Weapon code partly based on Shifter».
- **PFAD** и **New Vehicles** — авторство записано в исходниках внутри пакетов («by Prototype»,
  «NewVehicles by Deadalus08»).
- **RenderExt** — с 25.10.2026 только для редактора, игра на стоковом рендере; из титров убран. Автор —
  Sebastian Kaufel (hanfling), «Deus Ex Editor Fix» 2014–2015 (`CNN/System/deusexedfix.txt`).

## README / страница мода

> Codename Nebula is distributed under CC BY-NC-SA 3.0. Third-party content listed in the credits
> remains under the terms of its authors. Assets from Deus Ex: Nihilum are used in accordance with the
> Creative Commons license.

## Открыто

1. ~~Автор RenderExt~~ — hanfling (см. выше).
2. Фото Честера в титрах (`chester_credits`) — фотограф.
3. В титры не попадает, но решить до релиза: ~~TITAN.utx и GenFX.utx~~ (заменены стоковыми 25.10.2026);
   LosAngelesTex — источники фото; модели `Ship1`, `SciFiFighter`.

Примечание о RenderExtended (moddb.com/mods/renderextended, автор LoadLineCalibration, вышел 15.05.2026): это
другой модуль — `RenderExtended.dll`, класс `RenderExtended.RenderExtended`. У CNN `RenderExt.dll`
(`RenderExt.RenderExt`), в репозитории с 2020 года (`1e17e4d`), то есть он старше и к RenderExtended
отношения не имеет. RenderExtended мог бы стать заменой (чинит пропадающие меши, поднимает лимиты), но это
отдельное решение и отдельная проверка.
