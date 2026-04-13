using System;
using System.IO;
using System.Runtime.InteropServices;

namespace CNNInstallUtil
{
    class InstallUtil
    {
        private readonly string currentPath = Directory.GetCurrentDirectory();

        public void Install()
        {
            string pathToModSystem = Path.Combine(currentPath, "System");
            string pathToSystem = Path.Combine(Directory.GetParent(currentPath).ToString(), "System");

            var modSystemInfo = new DirectoryInfo(pathToModSystem);
            var originalSystemInfo = new DirectoryInfo(pathToSystem);

            if (!modSystemInfo.Exists)
            {
                Console.WriteLine("Error: directory {0} doesn't exist! Creating directory!", pathToModSystem);
                Directory.CreateDirectory(pathToModSystem);
            }

            if (!originalSystemInfo.Exists)
            {
                Console.WriteLine("Error: directory {0} doesn't exist!", pathToSystem);
                return;
            }

            CreateCNNIni(pathToSystem, pathToModSystem);
            CreateCNNUserIni(pathToSystem, pathToModSystem);
            CopyMusicFiles(pathToSystem, pathToModSystem);
            CreateLauncher(pathToSystem, pathToModSystem);
            CreateShortcuts(pathToSystem, pathToModSystem);

            Console.WriteLine("\nInstallation complete! You can launch Codename Nebula from the desktop shortcut.");
        }

        private void CreateCNNIni(string pathToSystem, string pathToModSystem)
        {
            var originalDeusExIni = new FileInfo(Path.Combine(pathToSystem, "DeusEx.ini"));

            if (originalDeusExIni.Exists)
            {
                File.Copy(originalDeusExIni.FullName, Path.Combine(pathToModSystem, "CNN.ini"), true);
                InjectIniProperties(Path.Combine(pathToModSystem, "CNN.ini"));
                Console.WriteLine("CNN.ini file created!");
            }
            else
            {
                Console.WriteLine("Warning: DeusEx.ini not found, creating template CNN.ini");
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
                Console.WriteLine("CNNUser.ini generated from player's User.ini (keybindings inherited).");
            }
            else
            {
                Console.WriteLine("Warning: User.ini not found, skipping CNNUser.ini.");
            }
        }

        private void CreateLauncher(string pathToSystem, string pathToModSystem)
        {
            // No exe renaming — use DeusEx.exe directly with INI= parameters
            // Same approach as GMDX and The Nameless Mod
            // Preserves Steam overlay and play time tracking
            string deusExExe = Path.Combine(pathToSystem, "DeusEx.exe");

            if (File.Exists(deusExExe))
            {
                long size = new FileInfo(deusExExe).Length;
                string exeType = size > 300000 ? "third-party launcher (Kentie/Han)"
                               : size > 200000 ? "original 1112fm"
                               : "Community Update wrapper";
                Console.WriteLine("Detected DeusEx.exe: {0} ({1} bytes).", exeType, size);
            }
            else
            {
                Console.WriteLine("Warning: DeusEx.exe not found in {0}!", pathToSystem);
                Console.WriteLine("  CNN requires a Deus Ex installation (Steam, GOG, or retail).");
            }
        }

        private void CreateShortcuts(string pathToSystem, string pathToModSystem)
        {
            string iconPath = Path.Combine(currentPath, "cnnico.ico");

            // Create a .bat launcher — uses DeusEx.exe directly with INI= parameters
            // Works on Steam (with overlay), GOG, and vanilla installs
            string batPath = Path.Combine(currentPath, "PlayCodenameNebula.bat");
            File.WriteAllText(batPath, string.Format(
                "@echo off\r\n" +
                "cd /d \"{0}\"\r\n" +
                ":: Launch Codename Nebula via DeusEx.exe with custom INI files\r\n" +
                ":: Steam overlay and play time tracking work because we use the original exe\r\n" +
                "\"{1}\" INI=\"{2}\" USERINI=\"{3}\"\r\n",
                pathToSystem,
                Path.Combine(pathToSystem, "DeusEx.exe"),
                Path.Combine(pathToModSystem, "CNN.ini"),
                Path.Combine(pathToModSystem, "CNNUser.ini")));
            Console.WriteLine("Created PlayCodenameNebula.bat launcher.");

            // Create .lnk shortcuts on Desktop and Start Menu via PowerShell
            // (handles OneDrive/Cyrillic/Unicode paths that .NET trimmed builds can't)
            CreateShortcutViaPowerShell(
                "[Environment]::GetFolderPath('Desktop')",
                "Codename Nebula.lnk", batPath, currentPath, iconPath);
            Console.WriteLine("Created desktop shortcut.");

            CreateShortcutViaPowerShell(
                "Join-Path ([Environment]::GetFolderPath('Programs')) 'Codename Nebula'",
                "Play Codename Nebula.lnk", batPath, currentPath, iconPath);
            Console.WriteLine("Created Start Menu shortcut.");
        }


        private void CreateShortcutViaPowerShell(string destFolderExpression, string lnkName, string targetPath, string workingDir, string iconPath)
        {
            string psScript = Path.Combine(Path.GetTempPath(), "cnn_shortcut.ps1");
            File.WriteAllText(psScript, string.Format(
                "$destDir = {0}\r\n" +
                "if (-not (Test-Path $destDir)) {{ New-Item -ItemType Directory -Path $destDir -Force | Out-Null }}\r\n" +
                "$lnkPath = Join-Path $destDir '{1}'\r\n" +
                "$ws = New-Object -COM WScript.Shell\r\n" +
                "$s = $ws.CreateShortcut($lnkPath)\r\n" +
                "$s.TargetPath = '{2}'\r\n" +
                "$s.WorkingDirectory = '{3}'\r\n" +
                "$s.IconLocation = '{4},0'\r\n" +
                "$s.Save()\r\n",
                destFolderExpression,
                lnkName,
                targetPath.Replace("'", "''"),
                workingDir.Replace("'", "''"),
                iconPath.Replace("'", "''")),
                System.Text.Encoding.UTF8);

            var psi = new System.Diagnostics.ProcessStartInfo
            {
                FileName = "powershell",
                Arguments = "-ExecutionPolicy Bypass -File \"" + psScript + "\"",
                UseShellExecute = false,
                CreateNoWindow = true
            };

            try
            {
                var proc = System.Diagnostics.Process.Start(psi);
                proc.WaitForExit(10000);
                File.Delete(psScript);
            }
            catch (Exception ex)
            {
                Console.WriteLine("Warning: Could not create shortcut: " + ex.Message);
            }
        }

        private void CopyViaPowerShell(string sourceFile, string destFolderExpression, string destFileName)
        {
            string psScript = Path.Combine(Path.GetTempPath(), "cnn_copy.ps1");
            File.WriteAllText(psScript, string.Format(
                "$destDir = {0}\r\n" +
                "if (-not (Test-Path $destDir)) {{ New-Item -ItemType Directory -Path $destDir -Force | Out-Null }}\r\n" +
                "Copy-Item '{1}' (Join-Path $destDir '{2}') -Force\r\n",
                destFolderExpression, sourceFile.Replace("'", "''"), destFileName),
                System.Text.Encoding.UTF8);

            var psi = new System.Diagnostics.ProcessStartInfo
            {
                FileName = "powershell",
                Arguments = "-ExecutionPolicy Bypass -File \"" + psScript + "\"",
                UseShellExecute = false,
                CreateNoWindow = true
            };

            try
            {
                var proc = System.Diagnostics.Process.Start(psi);
                proc.WaitForExit(10000);
                File.Delete(psScript);
            }
            catch (Exception ex)
            {
                Console.WriteLine("Warning: Copy failed: " + ex.Message);
            }
        }

        private void CreateTemplateCNNIniFile(string pathToModSystem)
        {
            using (var writer = new StreamWriter(Path.Combine(pathToModSystem, "CNN.ini")))
            {
                string templateFile = new System.Text.StringBuilder()
                    .AppendLine("[URL]")
                    .AppendLine("Class=CNN.TantalusDenton")
                    .AppendLine()
                    .AppendLine("[Engine.Engine]")
                    .AppendLine("GameRenderDevice=D3D9Drv.D3D9RenderDevice")
                    .AppendLine("DefaultGame=CNN.CNNGameInfo")
                    .AppendLine()
                    .AppendLine("[Core.System]")
                    .AppendLine("SavePath=" + Path.Combine(currentPath, "Save"))
                    .AppendLine("Paths=" + Path.Combine(currentPath, "Maps\\*.dx"))
                    .AppendLine("Paths=" + Path.Combine(currentPath, "System\\*.u"))
                    .AppendLine("Paths=" + Path.Combine(currentPath, "Textures\\*.utx"))
                    .AppendLine("Paths=" + Path.Combine(currentPath, "Music\\*.umx"))
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
            string deusExRoot = Directory.GetParent(currentPath)?.FullName ?? "";
            bool inCoreSystem = false;
            bool pathsInjected = false;
            bool seenSuppressBlock = false;

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

                // [Core.System] section: replace Paths=, patch SavePath=
                if (inCoreSystem)
                {
                    if (line.StartsWith("SavePath="))
                    {
                        result.Add("SavePath=" + modRoot + @"\Save");
                        continue;
                    }
                    if (line.StartsWith("Paths="))       continue; // skip existing, we inject our own
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
                Console.WriteLine("  Renderer: {0} (inherited from player)", renderer.Substring("GameRenderDevice=".Length));
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
                Console.WriteLine("  NewVision: FOUND [{0}] -> {1}", hdSource, nvPath);
            }
            if (hdtpTexPath != null)
            {
                paths.Add("Paths=" + hdtpTexPath + @"\*.utx");
                Console.WriteLine("  HDTP Textures: FOUND -> {0}", hdtpTexPath);
            }
            if (hdtpSysPath != null)
            {
                paths.Add("Paths=" + hdtpSysPath + @"\*.u");
                Console.WriteLine("  HDTP Models: FOUND -> {0}", hdtpSysPath);
            }
            if (nvPath == null && hdtpSysPath == null)
                Console.WriteLine("  HD textures: not found (optional)");

            return paths.ToArray();
        }

        private void CopyMusicFiles(string pathToSystem, string pathToModSystem)
        {
            string pathToMusic = Path.Combine(Directory.GetParent(currentPath).ToString(), "Music");
            string pathToOggMusic = Path.Combine(pathToMusic, "Ogg");
            string pathToModOggMusic = Path.Combine(currentPath, "Music", "Ogg");

            if (!Directory.Exists(pathToMusic))
                Directory.CreateDirectory(pathToMusic);

            if (!Directory.Exists(pathToOggMusic))
                Directory.CreateDirectory(pathToOggMusic);

            // Copy D3D9 renderer as fallback (in case player has no modern renderer)
            foreach (string d3d9File in new[] { "D3D9Drv.dll", "D3D9Drv.int" })
            {
                string src = Path.Combine(pathToModSystem, d3d9File);
                string dest = Path.Combine(pathToSystem, d3d9File);
                if (File.Exists(src) && !File.Exists(dest))
                {
                    File.Copy(src, dest, false);
                    Console.WriteLine("Installed {0} to System (D3D9 fallback renderer).", d3d9File);
                }
            }

            // Copy DXOgg.dll to game System (needed for OGG playback)
            string dxOggDll = Path.Combine(pathToModSystem, "DXOgg.dll");
            if (File.Exists(dxOggDll))
            {
                File.Copy(dxOggDll, Path.Combine(pathToSystem, "DXOgg.dll"), true);
                Console.WriteLine("Copied DXOgg.dll to System.");
            }

            // Copy DXOgg.u to game System
            string dxOggU = Path.Combine(pathToModSystem, "DXOgg.u");
            if (File.Exists(dxOggU))
            {
                File.Copy(dxOggU, Path.Combine(pathToSystem, "DXOgg.u"), true);
                Console.WriteLine("Copied DXOgg.u to System.");
            }

            // Copy OGG music files
            if (Directory.Exists(pathToModOggMusic))
            {
                foreach (FileInfo oggFile in new DirectoryInfo(pathToModOggMusic).GetFiles())
                {
                    Console.WriteLine("Copying music: {0}", oggFile.Name);
                    File.Copy(oggFile.FullName, Path.Combine(pathToOggMusic, oggFile.Name), true);
                }
                Console.WriteLine("Done copying OGG music.");
            }
        }
    }
}
