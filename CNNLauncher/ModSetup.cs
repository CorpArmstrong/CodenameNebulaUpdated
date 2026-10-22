using System;
using System.Collections.Generic;
using System.IO;
using System.Runtime.InteropServices;
using System.Text;

namespace CNNLauncher
{
    // Prepares Codename Nebula on this game copy: CNN.ini and CNNUser.ini from
    // the player's own DeusEx.ini/User.ini, the native DLLs the engine loads
    // from the game's System, and the list the uninstaller uses to remove
    // exactly what was added there. Run by the installer (--setup) and by Repair.
    public class ModSetup
    {
        private readonly GameFolder game;
        private readonly string currentPath;
        private readonly StringBuilder log = new StringBuilder();

        // What this adds to the game's own folders (native DLLs in System; older
        // versions also Music\Ogg), written to CodenameNebula\System\CNNGameFiles.txt
        // for the uninstaller, which otherwise only removes the mod folder. Only
        // what wasn't there before is listed, so a player's own D3D9Drv.dll or
        // DXOgg stays; entries from an earlier install are kept. Each file carries
        // the SHA1 of what we put there: the uninstaller leaves a file something
        // else has replaced since.
        private const string GameFilesList = "CNNGameFiles.txt";
        private readonly Dictionary<string, string> addedFiles =
            new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
        private readonly List<string> addedDirs = new List<string>();

        // Minimum viewport CNN is designed for. The vanilla Default.ini ships
        // 640x480 @ 16-bit, which modern GPUs no longer expose as a fullscreen
        // display mode.
        private const int MinViewportX = 800;
        private const int MinViewportY = 600;

        public ModSetup(GameFolder game)
        {
            this.game = game;
            currentPath = game.ModRoot;
        }

        public string Log => log.ToString();

        // HD texture Paths= lines for the settings window (NewVision / HDTP, if installed)
        public string[] FindHDPaths()
        {
            return DetectHDTextures(game.GameRoot);
        }

        private void Report(string format, params object[] args)
        {
            log.AppendLine(args.Length > 0 ? string.Format(format, args) : format);
        }

        // Returns false when the game folder is not usable; the reason is in Log
        public bool Run()
        {
            string pathToModSystem = game.ModSystem;
            string pathToSystem = game.GameSystem;
            Report("Codename Nebula setup, {0}", DateTime.Now);
            Report("Game: {0}", game.GameRoot);

            if (!Directory.Exists(pathToSystem))
            {
                Report("Error: {0} doesn't exist -- the mod must be installed as <Deus Ex>\\CodenameNebula.", pathToSystem);
                return false;
            }
            Directory.CreateDirectory(pathToModSystem);

            LoadGameFiles(pathToModSystem);
            CreateCNNIni(pathToSystem, pathToModSystem);
            CreateCNNUserIni(pathToSystem, pathToModSystem);
            CopyNativeFiles(pathToSystem, pathToModSystem);
            RemoveOldMusicCopies();
            PrepareCdExe(pathToSystem);
            SaveGameFiles(pathToModSystem);
            Report("DeusEx.exe: {0}", GameFolder.Describe(game.DeusExKind));
            Report("Start: {0}", GameStarter.Summary(GameStarter.Plan(game)));
            File.WriteAllText(Path.Combine(pathToModSystem, "CNNSetup.log"), Log);
            return true;
        }

        // A CD copy's DeusEx.exe asks for the disc; a renamed copy of the same exe
        // does not. Made from the player's own 1112fm/CD exe (GOG gets a harmless
        // copy too -- they can't be told apart), with its own .int so the window
        // is titled "Codename Nebula". Both names are CNN's own, so always listed.
        private void PrepareCdExe(string pathToSystem)
        {
            string exe = Path.Combine(pathToSystem, GameFolder.CdExeName);
            string intFile = Path.Combine(pathToSystem, "CodenameNebula.int");
            if (game.DeusExKind != ExeKind.Original)
                return;
            File.Copy(game.DeusExExe, exe, true);
            addedFiles[exe] = Sha1(exe);
            File.WriteAllText(intFile, "[General]\r\nStart=Codename Nebula (Starting)\r\nExit=Codename Nebula (Exiting)\r\n" +
                                       "Run=Codename Nebula (Running)\r\nProduct=Codename Nebula\r\n", Encoding.ASCII);
            addedFiles[intFile] = Sha1(intFile);
            Report("Created {0} (a copy of DeusEx.exe that needs no CD).", GameFolder.CdExeName);
        }

        // ---- display mode -------------------------------------------------------
        // Real current display mode in physical pixels. GetSystemMetrics is not
        // usable here: in a process that isn't DPI-aware it reports virtualized
        // values (e.g. 1707x1067 on a 2560x1600 panel at 150% scaling) -- and
        // writing a resolution that isn't an actual display mode is precisely
        // what makes the engine fail its mode set.
        private const int ENUM_CURRENT_SETTINGS = -1;

        [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
        internal struct DEVMODE
        {
            [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 32)] public string dmDeviceName;
            public short dmSpecVersion, dmDriverVersion, dmSize, dmDriverExtra;
            public int dmFields;
            public int dmPositionX, dmPositionY;
            public int dmDisplayOrientation, dmDisplayFixedOutput;
            public short dmColor, dmDuplex, dmYResolution, dmTTOption, dmCollate;
            [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 32)] public string dmFormName;
            public short dmLogPixels;
            public int dmBitsPerPel, dmPelsWidth, dmPelsHeight;
            public int dmDisplayFlags, dmDisplayFrequency;
            public int dmICMMethod, dmICMIntent, dmMediaType, dmDitherType;
            public int dmReserved1, dmReserved2, dmPanningWidth, dmPanningHeight;
        }

        [DllImport("user32.dll", CharSet = CharSet.Unicode)]
        internal static extern bool EnumDisplaySettings(string deviceName, int modeNum, ref DEVMODE devMode);

        private static int desktopW;
        private static int desktopH;

        internal static int DesktopWidth
        {
            get { if (desktopW == 0) GetDesktopResolution(out desktopW, out desktopH); return desktopW; }
        }

        internal static int DesktopHeight
        {
            get { if (desktopH == 0) GetDesktopResolution(out desktopW, out desktopH); return desktopH; }
        }

        private static void GetDesktopResolution(out int width, out int height)
        {
            // Conservative fallback: 1280x720 is a mode every GPU exposes.
            width = 1280;
            height = 720;

            var dm = new DEVMODE();
            dm.dmSize = (short)Marshal.SizeOf(typeof(DEVMODE));
            if (EnumDisplaySettings(null, ENUM_CURRENT_SETTINGS, ref dm) &&
                dm.dmPelsWidth >= MinViewportX && dm.dmPelsHeight >= MinViewportY)
            {
                width = dm.dmPelsWidth;
                height = dm.dmPelsHeight;
            }
        }
        private void CreateCNNIni(string pathToSystem, string pathToModSystem)
        {
            var originalDeusExIni = new FileInfo(Path.Combine(pathToSystem, "DeusEx.ini"));

            if (originalDeusExIni.Exists)
            {
                File.Copy(originalDeusExIni.FullName, Path.Combine(pathToModSystem, "CNN.ini"), true);
                InjectIniProperties(Path.Combine(pathToModSystem, "CNN.ini"));
                Report("CNN.ini file created!");
            }
            else
            {
                Report("Warning: DeusEx.ini not found, creating template CNN.ini");
                CreateTemplateCNNIniFile(pathToModSystem);
            }
        }

        private void CreateCNNUserIni(string pathToSystem, string pathToModSystem)
        {
            var originalUserIni = new FileInfo(Path.Combine(pathToSystem, "User.ini"));
            string outputPath = Path.Combine(pathToModSystem, "CNNUser.ini");

            if (originalUserIni.Exists)
            {
                // Copy User.ini and patch player class to CNN's TantalusDenton
                var lines = File.ReadAllLines(originalUserIni.FullName);
                for (int i = 0; i < lines.Length; i++)
                {
                    if (lines[i].StartsWith("Class="))
                        lines[i] = "Class=CNN.TantalusDenton";
                }
                File.WriteAllLines(outputPath, lines);
                Report("CNNUser.ini generated from player's User.ini (keybindings inherited).");
            }
            else
            {
                Report("Warning: User.ini not found, skipping CNNUser.ini.");
            }
        }



        private void CreateTemplateCNNIniFile(string pathToModSystem)
        {
            using (var writer = new StreamWriter(Path.Combine(pathToModSystem, "CNN.ini")))
            {
                string templateFile = new System.Text.StringBuilder()
                    .AppendLine("[FirstRun]")
                    .AppendLine("FirstRun=1100")
                    .AppendLine()
                    .AppendLine("[URL]")
                    .AppendLine("Class=CNN.TantalusDenton")
                    .AppendLine()
                    .AppendLine("[Engine.Engine]")
                    .AppendLine("GameRenderDevice=D3D9Drv.D3D9RenderDevice")
                    .AppendLine("RenderDevice=D3D9Drv.D3D9RenderDevice")
                    .AppendLine("WindowedRenderDevice=D3D9Drv.D3D9RenderDevice")
                    .AppendLine("DefaultGame=CNN.CNNGameInfo")
                    .AppendLine()
                    // Explicit 32-bit + desktop resolution: the engine's own
                    // fallback is 640x480 @ 16-bit, which no longer resolves to
                    // a valid fullscreen display mode on Windows 10/11.
                    .AppendLine("[WinDrv.WindowsClient]")
                    .AppendLine("WindowedViewportX=" + DesktopWidth)
                    .AppendLine("WindowedViewportY=" + DesktopHeight)
                    .AppendLine("WindowedColorBits=32")
                    .AppendLine("FullscreenViewportX=" + DesktopWidth)
                    .AppendLine("FullscreenViewportY=" + DesktopHeight)
                    .AppendLine("FullscreenColorBits=32")
                    .AppendLine()
                    .AppendLine("[Core.System]")
                    .AppendLine("SavePath=" + Path.Combine(currentPath, "Save"))
                    .AppendLine("Paths=" + Path.Combine(currentPath, "Maps\\*.dx"))
                    .AppendLine("Paths=" + Path.Combine(currentPath, "System\\*.u"))
                    .AppendLine("Paths=" + Path.Combine(currentPath, "Textures\\*.utx"))
                    .AppendLine("Paths=" + Path.Combine(currentPath, "Music\\*.umx"))
                    .AppendLine("OggPath=" + Path.Combine(currentPath, "Music\\Ogg\\"))
                    .ToString();

                writer.Write(templateFile);
            }
        }

        private void InjectIniProperties(string pathToFile)
        {
            // Generate CNN.ini from player's DeusEx.ini:
            // - Preserve player's renderer, resolution, audio, keybinds, detail settings
            // - Patch only CNN-specific values (player class, game mode, paths, save path)
            // - Auto-detect HD textures (NewVision/HDTP) from Revision, GMDX, or standalone
            var lines = new System.Collections.Generic.List<string>(File.ReadAllLines(pathToFile));
            var result = new System.Collections.Generic.List<string>();

            string modRoot = @"..\CodenameNebula";
            string deusExRoot = game.GameRoot;
            bool inCoreSystem = false;
            bool pathsInjected = false;
            bool seenSuppressBlock = false;

            // The player's INI can name a render device that cannot work on
            // modern Windows. A never-configured retail/CD install inherits the
            // game's Default.ini verbatim: GlideDrv (3dfx, DLL not shipped) or
            // D3DDrv — the 1999 D3D7 device, which dies with
            //   "Failed resetting mode"  History: HandleBigChange <- UD3DRenderDevice::Lock
            // on Windows 10/11. Copying that into CNN.ini clones the breakage,
            // so map any such device onto a renderer that actually works.
            string modSystem = Path.GetDirectoryName(pathToFile) ?? "";
            string safeRenderer = File.Exists(Path.Combine(modSystem, "D3D9Drv.dll"))
                ? "D3D9Drv.D3D9RenderDevice"
                : "OpenGlDrv.OpenGLRenderDevice";
            string replacedFrom = null;

            // Auto-detect HD textures
            var hdPaths = DetectHDTextures(deusExRoot);

            // Build paths: HD first (loading priority), then CNN, then base game
            var allPaths = new System.Collections.Generic.List<string>();
            allPaths.AddRange(hdPaths);
            allPaths.AddRange(new[]
            {
                "Paths=" + modRoot + @"\Maps\*.dx",
                "Paths=" + modRoot + @"\System\*.u",
                "Paths=" + modRoot + @"\Textures\*.utx",
                "Paths=" + modRoot + @"\Music\*.umx",
                // DXOgg reads the tracks from here, not the game's ..\Music\Ogg\
                "OggPath=" + modRoot + @"\Music\Ogg\",
                @"Paths=..\Music\*.umx",
                @"Paths=..\Sounds\*.uax",
                @"Paths=..\Textures\*.utx",
                @"Paths=..\Maps\*.dx",
                @"Paths=..\System\*.u"
            });
            string[] cnnPaths = allPaths.ToArray();

            for (int i = 0; i < lines.Count; i++)
            {
                string line = lines[i];

                // Track section transitions
                if (line.StartsWith("["))
                {
                    if (inCoreSystem && !pathsInjected)
                    {
                        result.AddRange(cnnPaths);
                        pathsInjected = true;
                    }
                    inCoreSystem = line.StartsWith("[Core.System]");
                    seenSuppressBlock = false;
                }

                // [URL] patches
                if (line.StartsWith("Class="))           { result.Add("Class=CNN.TantalusDenton");    continue; }
                if (line.StartsWith("Map="))             { result.Add("Map=Index.dx");                continue; }
                if (line.StartsWith("LocalMap="))        { result.Add("LocalMap=DX.dx");              continue; }
                if (line.StartsWith("MapExt="))          { result.Add("MapExt=dx");                   continue; }
                if (line.StartsWith("SaveExt="))         { result.Add("SaveExt=dxs");                 continue; }

                // [Engine.Engine] patches
                if (line.StartsWith("DefaultGame="))     { result.Add("DefaultGame=CNN.CNNGameInfo");  continue; }
                if (line.StartsWith("Render=") && !line.StartsWith("RenderDevice"))
                {
                    result.Add("Render=RenderExt.RenderExt");
                    continue;
                }

                // Replace unusable render devices (see safeRenderer above)
                if (line.StartsWith("GameRenderDevice=") || line.StartsWith("RenderDevice=") ||
                    line.StartsWith("WindowedRenderDevice="))
                {
                    string key = line.Substring(0, line.IndexOf('=') + 1);
                    string device = line.Substring(key.Length).Trim();
                    if (IsUnusableRenderer(device))
                    {
                        if (line.StartsWith("GameRenderDevice="))
                            replacedFrom = device.Length > 0 ? device : "(empty)";
                        result.Add(key + safeRenderer);
                        continue;
                    }
                }

                // [WinDrv.WindowsClient] patches. Windows 10/11 expose no
                // 16-bit fullscreen modes — a 16-bit request is the other half
                // of "Failed resetting mode", independent of the renderer.
                // A never-launched game has FirstRun=0: the engine would open its
                // first-time wizard, which on current PCs certifies only Software
                // Rendering and overwrites our renderer. 1100 is what it writes after.
                if (line.StartsWith("FirstRun="))            { result.Add("FirstRun=1100");          continue; }
                if (line.StartsWith("WindowedColorBits="))   { result.Add("WindowedColorBits=32");   continue; }
                if (line.StartsWith("FullscreenColorBits=")) { result.Add("FullscreenColorBits=32"); continue; }

                if (line.StartsWith("WindowedViewportX=") || line.StartsWith("FullscreenViewportX="))
                { result.Add(PatchViewport(line, DesktopWidth, MinViewportX));  continue; }
                if (line.StartsWith("WindowedViewportY=") || line.StartsWith("FullscreenViewportY="))
                { result.Add(PatchViewport(line, DesktopHeight, MinViewportY)); continue; }

                // [Core.System] section: replace Paths=, patch SavePath=
                if (inCoreSystem)
                {
                    if (line.StartsWith("SavePath="))
                    {
                        result.Add("SavePath=" + modRoot + @"\Save");
                        continue;
                    }
                    if (line.StartsWith("Paths="))       continue; // skip existing, we inject our own
                    if (line.StartsWith("OggPath="))     continue; // ours goes with the Paths=
                    if (line.StartsWith("; HD Textures")) continue; // skip old HD comments

                    if (line.StartsWith("Suppress="))
                    {
                        seenSuppressBlock = true;
                        result.Add(line);
                        continue;
                    }
                    // After Suppress block ends, inject CNN paths
                    if (seenSuppressBlock && !pathsInjected && line.Trim() != "")
                    {
                        result.AddRange(cnnPaths);
                        pathsInjected = true;
                    }
                }

                // Patch CacheSizeMegs
                if (line.StartsWith("CacheSizeMegs="))   { result.Add("CacheSizeMegs=256");           continue; }

                // Skip EditPackages= lines (not needed for playing)
                if (line.StartsWith("EditPackages="))    continue;

                // Keep everything else (renderer, resolution, audio, keybinds, etc.)
                result.Add(line);
            }

            if (!pathsInjected)
            {
                result.Add("[Core.System]");
                result.AddRange(cnnPaths);
            }

            File.WriteAllLines(pathToFile, result.ToArray());

            // Log what was inherited
            string renderer = result.Find(x => x.StartsWith("GameRenderDevice="));
            if (renderer != null)
            {
                string device = renderer.Substring("GameRenderDevice=".Length);
                if (replacedFrom != null)
                    Report("  Renderer: {0} (replaced {1} — unusable on modern Windows)", device, replacedFrom);
                else
                    Report("  Renderer: {0} (inherited from player)", device);
            }
        }

        // Render devices that are either absent from a modern install or cannot
        // set a display mode on Windows 10/11. Note "D3DDrv." does not match
        // "D3D9Drv." — only the legacy 1999 device is rejected.
        private static bool IsUnusableRenderer(string device)
        {
            if (string.IsNullOrWhiteSpace(device) || device.Equals("None", StringComparison.OrdinalIgnoreCase))
                return true;

            foreach (string legacy in new[] { "GlideDrv.", "D3DDrv.", "SoftDrv.", "MeTaLDrv.", "MetalDrv.", "SGLDrv." })
            {
                if (device.StartsWith(legacy, StringComparison.OrdinalIgnoreCase))
                    return true;
            }
            return false;
        }

        // Keep the player's resolution unless it is below CNN's minimum (the
        // vanilla 640x480 default), in which case use the desktop resolution.
        private static string PatchViewport(string line, int desktop, int minimum)
        {
            int eq = line.IndexOf('=');
            string key = line.Substring(0, eq + 1);
            int value;
            if (int.TryParse(line.Substring(eq + 1).Trim(), out value) && value >= minimum)
                return line;
            return key + desktop;
        }

        private string[] DetectHDTextures(string deusExRoot)
        {
            var paths = new System.Collections.Generic.List<string>();
            if (string.IsNullOrEmpty(deusExRoot) || !Directory.Exists(deusExRoot))
                return paths.ToArray();

            string nvPath = null;
            string hdSource = null;
            string hdtpTexPath = null;
            string hdtpSysPath = null;

            // NewVision detection (priority order)
            var nvSearchPaths = new[]
            {
                new { Path = Path.Combine(deusExRoot, @"Revision\NewVision\Textures"), Source = "Revision" },
                new { Path = Path.Combine(deusExRoot, @"GMDXv9\NewVision\Textures"),   Source = "GMDX v9" },
                new { Path = Path.Combine(deusExRoot, @"GMDX\NewVision\Textures"),     Source = "GMDX v10" },
                new { Path = Path.Combine(deusExRoot, @"New Vision\Textures"),          Source = "Standalone" },
                new { Path = Path.Combine(deusExRoot, @"NewVision\Textures"),           Source = "Standalone" }
            };
            foreach (var nv in nvSearchPaths)
            {
                if (File.Exists(Path.Combine(nv.Path, "CoreTexMetal.utx")))
                {
                    nvPath = nv.Path;
                    hdSource = nv.Source;
                    break;
                }
            }

            // HDTP detection (priority order)
            var hdtpSearchPaths = new[]
            {
                Path.Combine(deusExRoot, @"Revision\HDTP"),
                Path.Combine(deusExRoot, @"GMDXv9\HDTP"),
                Path.Combine(deusExRoot, @"GMDX\HDTP"),
                Path.Combine(deusExRoot, "HDTP")
            };
            foreach (string hp in hdtpSearchPaths)
            {
                if (File.Exists(Path.Combine(hp, @"System\HDTPCharacters.u")))
                {
                    hdtpSysPath = Path.Combine(hp, "System");
                    hdtpTexPath = Path.Combine(hp, "Textures");
                    break;
                }
            }
            // HDTP in base folders
            if (hdtpSysPath == null && File.Exists(Path.Combine(deusExRoot, @"System\HDTPCharacters.u")))
            {
                hdtpSysPath = Path.Combine(deusExRoot, "System");
                hdtpTexPath = Path.Combine(deusExRoot, "Textures");
            }

            // Build HD paths (before CNN paths for loading priority)
            if (nvPath != null || hdtpSysPath != null)
                paths.Add("; HD Textures (auto-detected)");

            if (nvPath != null)
            {
                paths.Add("Paths=" + nvPath + @"\*.utx");
                Report("  NewVision: FOUND [{0}] -> {1}", hdSource, nvPath);
            }
            if (hdtpTexPath != null)
            {
                paths.Add("Paths=" + hdtpTexPath + @"\*.utx");
                Report("  HDTP Textures: FOUND -> {0}", hdtpTexPath);
            }
            if (hdtpSysPath != null)
            {
                paths.Add("Paths=" + hdtpSysPath + @"\*.u");
                Report("  HDTP Models: FOUND -> {0}", hdtpSysPath);
            }
            if (nvPath == null && hdtpSysPath == null)
                Report("  HD textures: not found (optional)");

            return paths.ToArray();
        }

        // Copies into the game's folders, noting what was not there before
        private void CopyIntoGame(string src, string dest, bool overwrite)
        {
            bool existed = File.Exists(dest);
            File.Copy(src, dest, overwrite);
            if (!existed || addedFiles.ContainsKey(dest))
                addedFiles[dest] = Sha1(dest);
        }

        private static string Sha1(string file)
        {
            using (var sha = System.Security.Cryptography.SHA1.Create())
            using (var stream = File.OpenRead(file))
                return BitConverter.ToString(sha.ComputeHash(stream)).Replace("-", "").ToLowerInvariant();
        }

        private void LoadGameFiles(string pathToModSystem)
        {
            string list = Path.Combine(pathToModSystem, GameFilesList);
            if (!File.Exists(list))
                return;
            foreach (string line in File.ReadAllLines(list))
            {
                if (line.StartsWith("dir "))
                    addedDirs.Add(line.Substring(4));
                else if (line.StartsWith("file ") && line.Length > 46)
                    addedFiles[line.Substring(46)] = line.Substring(5, 40);
            }
        }

        // "file <sha1> <path>" lines, then "dir <path>" (deepest first) -- the
        // uninstaller removes a folder only once it is empty
        private void SaveGameFiles(string pathToModSystem)
        {
            var lines = new List<string>();
            foreach (var f in addedFiles)
                if (File.Exists(f.Key))
                    lines.Add("file " + f.Value + " " + f.Key);
            addedDirs.Sort((a, b) => b.Length.CompareTo(a.Length));
            foreach (string d in addedDirs)
                lines.Add("dir " + d);
            File.WriteAllLines(Path.Combine(pathToModSystem, GameFilesList), lines.ToArray());
            Report("Noted {0} files and {1} folders added to the game for the uninstaller.", addedFiles.Count, addedDirs.Count);
        }

        // Native DLLs go to the game's System: the engine LoadLibrary's them
        // from the exe's folder and ignores Paths= (RenderExt for
        // Render=RenderExt.RenderExt, DXOgg for the music, D3D9Drv as the
        // renderer). Nothing else leaves the mod folder: DXOgg.u is found via
        // Paths=, the .ogg tracks via OggPath= in CNN.ini.
        private void CopyNativeFiles(string pathToSystem, string pathToModSystem)
        {
            // The D3D9 .dll and .int go as a pair: a player's own D3D9 stays whole.
            if (!File.Exists(Path.Combine(pathToSystem, "D3D9Drv.dll")))
                foreach (string f in new[] { "D3D9Drv.dll", "D3D9Drv.int" })
                    CopyIntoGameIfFree(Path.Combine(pathToModSystem, f), Path.Combine(pathToSystem, f));

            foreach (string f in new[] { "DXOgg.dll", "RenderExt.dll", "RenderExt.int" })
                CopyIntoGameIfFree(Path.Combine(pathToModSystem, f), Path.Combine(pathToSystem, f));
        }

        // Puts a file into the game's System unless something else owns that
        // name there: a file the player or another mod put there stays as is.
        private void CopyIntoGameIfFree(string src, string dest)
        {
            string name = Path.GetFileName(dest);
            if (!File.Exists(src))
            {
                Report("Warning: {0} not found in mod System folder.", name);
                return;
            }
            if (File.Exists(dest) && !addedFiles.ContainsKey(dest))
            {
                if (Sha1(dest) == Sha1(src))
                    Report("{0} is already in System (the same file).", name);
                else
                    Report("Kept the {0} already in System (not installed by CNN).", name);
                return;
            }
            CopyIntoGame(src, dest, true);
            Report("Copied {0} to System.", name);
        }

        // Earlier versions copied the .ogg tracks into the game's Music\Ogg.
        // A copy byte-identical to the mod's own track can only be CNN's.
        private void RemoveOldMusicCopies()
        {
            string gameOgg = Path.Combine(game.GameRoot, "Music", "Ogg");
            string modOgg = Path.Combine(currentPath, "Music", "Ogg");
            if (!Directory.Exists(gameOgg) || !Directory.Exists(modOgg))
                return;

            int removed = 0;
            foreach (FileInfo track in new DirectoryInfo(modOgg).GetFiles("*.ogg"))
            {
                string old = Path.Combine(gameOgg, track.Name);
                if (File.Exists(old) && new FileInfo(old).Length == track.Length && Sha1(old) == Sha1(track.FullName))
                {
                    File.Delete(old);
                    addedFiles.Remove(old);
                    removed++;
                }
            }
            if (removed > 0)
                Report("Removed {0} old copies of CNN music from the game's Music\\Ogg (now played from the mod folder).", removed);
        }
    }
}
