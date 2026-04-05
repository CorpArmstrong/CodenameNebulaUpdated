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

            if (originalUserIni.Exists)
            {
                File.Copy(originalUserIni.FullName, Path.Combine(pathToModSystem, "CNNUser.ini"), true);
                Console.WriteLine("CNNUser.ini file created!");
            }
            else
            {
                Console.WriteLine("Warning: User.ini not found, skipping CNNUser.ini.");
            }
        }

        private void CreateLauncher(string pathToSystem, string pathToModSystem)
        {
            string cnnExePath = Path.Combine(pathToSystem, "CodenameNebula.exe");

            // Prefer original 1112fm exe (not the Community Update wrapper)
            string originalExe = Path.Combine(pathToSystem, "DeusEx 1112fm (Original EXE).exe");
            if (!File.Exists(originalExe))
            {
                originalExe = Path.Combine(pathToSystem, "DeusEx.exe");
            }

            if (File.Exists(originalExe))
            {
                File.Copy(originalExe, cnnExePath, true);
                Console.WriteLine("Created CodenameNebula.exe (Steam bypass launcher).");
            }
            else
            {
                Console.WriteLine("Error: Could not find DeusEx.exe to create launcher!");
            }
        }

        private void CreateShortcuts(string pathToSystem, string pathToModSystem)
        {
            string iconPath = Path.Combine(currentPath, "cnnico.ico");

            // Create a .bat launcher in the mod folder — this reliably handles paths with spaces
            string batPath = Path.Combine(currentPath, "PlayCodenameNebula.bat");
            File.WriteAllText(batPath, string.Format(
                "@echo off\r\n" +
                "cd /d \"{0}\"\r\n" +
                "\"{1}\" INI=\"{2}\" USERINI=\"{3}\"\r\n",
                pathToSystem,
                Path.Combine(pathToSystem, "CodenameNebula.exe"),
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
            var iniKeyValues = new System.Collections.Generic.List<string>(File.ReadAllLines(pathToFile));
            int index = iniKeyValues.FindIndex(x => x.StartsWith("Class="));

            if (index >= 0)
            {
                iniKeyValues[index] = "Class=CNN.TantalusDenton";
                index = -1;
            }

            index = iniKeyValues.FindIndex(x => x.StartsWith("DefaultGame="));
            if (index >= 0)
            {
                iniKeyValues[index] = "DefaultGame=CNN.CNNGameInfo";
                index = -1;
            }

            // Set renderer to OpenGL (compatible with original 1112fm exe)
            index = iniKeyValues.FindIndex(x => x.StartsWith("GameRenderDevice="));
            if (index >= 0)
                iniKeyValues[index] = "GameRenderDevice=D3D9Drv.D3D9RenderDevice";

            index = iniKeyValues.FindIndex(x => x.StartsWith("RenderDevice="));
            if (index >= 0)
                iniKeyValues[index] = "RenderDevice=D3D9Drv.D3D9RenderDevice";

            int propertiesIdx = iniKeyValues.FindIndex(x => x.StartsWith("[Core.System]"));
            if (propertiesIdx >= 0)
            {
                iniKeyValues.Insert(++propertiesIdx, "SavePath=" + Path.Combine(currentPath, "Save"));
                iniKeyValues.Insert(++propertiesIdx, "Paths=" + Path.Combine(currentPath, "Maps\\*.dx"));
                iniKeyValues.Insert(++propertiesIdx, "Paths=" + Path.Combine(currentPath, "System\\*.u"));
                iniKeyValues.Insert(++propertiesIdx, "Paths=" + Path.Combine(currentPath, "Textures\\*.utx"));
                iniKeyValues.Insert(++propertiesIdx, "Paths=" + Path.Combine(currentPath, "Music\\*.umx"));
            }

            File.WriteAllLines(pathToFile, iniKeyValues.ToArray());
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

            // Copy D3D9 renderer to game System (best compatible renderer for modern Windows)
            foreach (string d3d9File in new[] { "D3D9Drv.dll", "D3D9Drv.int" })
            {
                string src = Path.Combine(pathToModSystem, d3d9File);
                if (File.Exists(src))
                {
                    File.Copy(src, Path.Combine(pathToSystem, d3d9File), true);
                    Console.WriteLine("Copied {0} to System.", d3d9File);
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
