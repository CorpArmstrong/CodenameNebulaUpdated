# Codename Nebula на Mac: установка в «бутылку» и разработка (27.10.2026)

Анализ, ничего не сделано. Две задачи: (1) игрок на Mac ставит и запускает мод в Wine-обёртке;
(2) разработка мода продолжается на Mac.

## 1. Что сейчас с Wine на Mac

- **Whisky** закрыт в апреле 2025 (без новых версий Wine, без исправлений для игр). Под него
  инструкции писать не стоит.
- **CrossOver 27** (июнь 2026) — только Apple Silicon и macOS Sonoma+. 32-битных бутылок больше
  нет: 32-битные программы (Deus Ex, ucc, UnrealEd) запускаются в 64-битной бутылке через WoW64.
  На Intel-маках остаётся CrossOver 26.
- **Kegworks/Sikarugir** (бывший Wineskin) — бесплатные обёртки, сложнее в настройке.
- **Rosetta 2:** macOS 27 — последняя версия с полной Rosetta; с macOS 28 (осень 2027) Apple
  оставит только часть «для старых игр». Покрывает ли она то, на что опирается Wine, Apple не
  сказала. Это главный долгосрочный риск для всего пути через Wine.
- Сам Deus Ex под CrossOver работает: у CodeWeavers есть рейтинг и инструкция для GOG-версии
  с модом Revision (macOS 15, CrossOver 25). Revision через Steam там не работает, база — да.

## 2. Где установка CNN споткнётся в бутылке

| Шаг | Что происходит | Риск |
|-----|----------------|------|
| Inno Setup (`CodenameNebula_v1.5.0.exe`) | Обычная Windows-программа, в Wine работает | Низкий. Поиск игры по реестру сработает, если игра ставилась внутрь той же бутылки (GOG-установщик, Windows-Steam); иначе игрок выбирает папку, проверка `System\DeusEx.exe` та же |
| `CNNLauncher.exe --setup` ([Run] установщика) | Нужен .NET Framework 4.x. В бутылке обычно есть wine-mono (замена .NET 4.x); WinForms-приложение нашего размера на нём, скорее всего, работает | **Главный.** Не проверено. Если `--setup` упадёт, мод установлен, но `CNN.ini` не создан — игра не запустится. Ставить настоящий .NET 4.7.2 через winetricks долго и ненадёжно (зависает, конфликтует с wine-mono; советуют dotnet48) |
| Запуск, Steam-версия | Лаунчер открывает `steam://rungameid/6910//…` | Под Wine ссылка уйдёт в macOS (`winebrowser`) — в мак-Steam Deus Ex нет. Нужен Windows-Steam в той же бутылке. **На Mac рекомендовать GOG-версию** |
| Запуск, GOG | Лаунчер запускает `DeusEx.exe` напрямую | Низкий |
| Рендер | D3D9 → D3DMetal/DXVK/wined3d | Низкий для D3D9; OpenGL на Mac исторически плохой |
| `DXOgg.dll`, пути с пробелами | Обычная нативная DLL | Низкий |

### Как убрать зависимость от .NET при установке

1. **Перенести `ModSetup` в Inno Setup** (секция `[Code]`, Pascal). Генерация `CNN.ini`/`CNNUser.ini`
   из `DeusEx.ini` — это работа со строками; в `ModSetup.cs` ~640 строк, из них логики INI —
   меньше половины. Inno под Wine работает сам, так что установка перестанет зависеть от .NET.
   Лаунчер остаётся удобством (Play/Settings/Repair) и для Windows ничего не меняется.
   Минус: та же логика в двух местах (Repair в лаунчере), либо Repair вызывает установщик.
2. **Запасной путь:** если `--setup` вернул ошибку, установщик кладёт статический `CNN.ini`
   (в репозитории он есть как fallback) и ярлык прямо на `DeusEx.exe INI=… USERINI=…`.
   Дёшево, но настройки рендера игрока не наследуются.
3. **Ничего не менять, проверить wine-mono.** Если лаунчер работает на wine-mono, хватит
   раздела «Mac/Linux» в README.

Рекомендация: сначала п. 3 (проверка), по результату — п. 2 или п. 1.

### Как проверить без Mac

- **Wine в WSL2 на этом ПК** — тот же код Wine, что в CrossOver (без D3DMetal). Проверяет
  установщик, wine-mono, `--setup`, генерацию INI, запуск GOG-подобной копии (стоковая копия
  `D:\Games\DXClean` + exe 1112fm). Покрывает почти всё, кроме мак-специфики.
- **Steam Deck / Linux (Proton)** — та же проверка даёт и их.
- На Mac: пробная версия CrossOver (14 дней), GOG-версия игры.

Старый план портативного `.zip` с `setup.sh` (память `project_portable_zip_pending`) писался под
`CNNInstallUtil`; если установщик заработает под Wine, `.zip` нужен только для Steam Deck и
ручной установки.

## 3. Разработка на Mac

| Вариант | Что работает | Чего стоит |
|---------|--------------|------------|
| **A. Mac как терминал, Windows-ПК собирает** | Всё как сейчас: git + VS Code/Rider на Mac для `.uc`, C#, документов; сборка и тесты по SSH (`cnn compile`, мост) или через удалённый рабочий стол (Windows App/Parsec) для игры и UnrealEd. Claude Code умеет работать в SSH-сессии | Нужен включённый Windows-ПК. Ничего не переносить |
| **B. Windows 11 ARM в виртуалке** (Parallels; VMware Fusion бесплатно) | Весь нынешний набор без изменений: `cnn.bat`, PowerShell, Inno, Steam с DRM-exe, UnrealEd, ConEdit. x86-программы идут через эмулятор Windows (Prism), не через Rosetta — риск macOS 28 их не касается | Лицензия Windows, подписка Parallels, 60+ ГБ. UnrealEd/ConEdit в эмуляции надо проверить |
| **C. Всё под Wine/CrossOver** | `ucc.exe`, Inno (`iscc`), Node-скрипты, `dotnet build` лаунчера (net472 собирается на macOS через NuGet-пакет `Microsoft.NETFramework.ReferenceAssemblies`) | `cnn.bat` — через `wine cmd`; PowerShell-инструменты (реестр, процессы, снимки окна) на мак-`pwsh` не работают. **ucc:** обход переполнения кучи в `ConSys.dll` (`tools/ucc_safeheap.ps1`) опирается на отладочную кучу Windows — под Wine куча другая, `CONVERSATION IMPORT` может падать. UnrealEd под Wine — с проблемами вьюпортов, ConEdit (VB6) — через `vb6run`. Зависит от Rosetta |

Рекомендация: **A** — сразу и бесплатно для работы с кодом; **B** — если Mac станет основной
машиной; **C** — не стоит, слишком много самодельных обходов и долгосрочный риск Rosetta.

## Источники

- CrossOver 27: https://www.codeweavers.com/blog/mjohnson/2026/6/11/whats-in-and-whats-out-for-crossover-27 ,
  https://appleinsider.com/articles/26/06/11/crossover-a-windows-to-mac-gaming-tool-goes-apple-silicon-only
- Rosetta: https://www.macrumors.com/2026/02/16/macos-tahoe-26-4-rosetta-2-warnings/ ,
  https://developer.apple.com/forums/thread/830692
- Whisky: https://appleinsider.com/articles/25/04/16/whisky-development-ends-on-macos-to-help-wine-flourish
- Deus Ex + Revision в CrossOver: https://www.codeweavers.com/compatibility/crossover/tips/deus-ex-game-of-the-year-edition/installing-and-running-deus-ex-and-the-revision-mod-crossover-25-update
- .NET 4.7.2 в Wine: https://list.winehq.org/pipermail/wine-bugs/2019-May/516023.html ,
  https://forum.winehq.org/viewtopic.php?p=135089
