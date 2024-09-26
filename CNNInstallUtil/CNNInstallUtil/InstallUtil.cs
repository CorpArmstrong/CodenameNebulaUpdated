using System;
using System.Collections.Generic;
using System.Text;
using System.IO;

namespace CNNInstallUtil
{
    class InstallUtil
    {
        private readonly string currentPath = Directory.GetCurrentDirectory();

        public void Install()
        {
            string pathToModSystem = Path.Combine(currentPath, "System");
            string pathToSystem = Path.Combine(Directory.GetParent(Environment.CurrentDirectory).ToString(), "System");

            var modSystemInfo = new DirectoryInfo(pathToModSystem);
            var originalSystemInfo = new DirectoryInfo(pathToSystem);

            var originalDeusExIni = new FileInfo(Path.Combine(pathToSystem, "DeusEx.ini"));
            var originalDeusExUserIni = new FileInfo(Path.Combine(pathToSystem, "User.ini"));

            if (!modSystemInfo.Exists)
            {
                Console.WriteLine("Error: directory {0} doesn't exists!\nCreating directory!", pathToModSystem);
                Directory.CreateDirectory(pathToModSystem); // unauthorized exception?
            }

            if (originalSystemInfo.Exists)
            {
                if (originalDeusExIni.Exists)
                {
                    File.Copy(originalDeusExIni.FullName, Path.Combine(pathToModSystem, "CNN.ini"), true);
                    InjectIniProperties(Path.Combine(pathToModSystem, "CNN.ini"));
                    Console.WriteLine("CNN.ini file created!");
                }
                else
                {
                    Console.WriteLine("Error: file {0} doesn't exists!\nCreating template CNN.ini file!",
                        originalDeusExIni.FullName);
                    CreateTemplateCNNIniFile(pathToModSystem);
                }

                if (originalDeusExUserIni.Exists)
                {
                    File.Copy(originalDeusExUserIni.FullName, Path.Combine(pathToModSystem, "CNNUser.ini"), true);
                    Console.WriteLine("CNNUser.ini file created!");
                }
                else
                {
                    Console.WriteLine("Error: file {0} doesn't exists!\nSkipping copy file.",
                        originalDeusExUserIni.FullName);
                }

                CopyMusicFiles(pathToSystem, pathToModSystem);
            }
            else
            {
                Console.WriteLine("Error: directory {0} doesn't exists!", pathToSystem);
            }
        }

        private void CreateTemplateCNNIniFile(string pathToModSystem)
        {
            using (var writer = new StreamWriter(Path.Combine(pathToModSystem, "CNN.ini")))
            {
                string templateFile = new StringBuilder()
                    .AppendLine("[URL]")
                    .AppendLine("Class=CNN.TantalusDenton")
                    .AppendLine()
                    .AppendLine("[Engine.Engine]")
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
            var iniKeyValues = new List<string>(File.ReadAllLines(pathToFile));
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
            string pathToMusic = Path.Combine(Directory.GetParent(Environment.CurrentDirectory).ToString(), "Music");
            string pathToOggMusic = Path.Combine(pathToMusic, "Ogg");
            string pathToModOggMusic = Path.Combine(currentPath, "Music\\Ogg");

            var musicDirInfo = new DirectoryInfo(pathToMusic);
            var oggMusicDirInfo = new DirectoryInfo(pathToOggMusic);
            var oggMusicModDirInfo = new DirectoryInfo(pathToModOggMusic);

            if (!musicDirInfo.Exists)
            {
                Console.WriteLine("Error: directory {0} doesn't exists!\nCreating directory!", pathToMusic);
                Directory.CreateDirectory(pathToMusic); // unauthorized exception?
            }

            if (!oggMusicDirInfo.Exists)
            {
                Console.WriteLine("Error: directory {0} doesn't exists!\nCreating directory!", pathToOggMusic);
                Directory.CreateDirectory(pathToOggMusic); // unauthorized exception?
            }
            
            string [] fileEntries = Directory.GetFiles(pathToSystem);
            if (!fileEntries.Equals("DXOgg.dll"))
            {
                var dxOggDLLFile = new FileInfo(Path.Combine(pathToModSystem, "DXOgg.dll"));
                File.Copy(dxOggDLLFile.FullName, Path.Combine(pathToSystem, dxOggDLLFile.Name), true); 
            }

            if (!File.Exists("DXOgg.u"))
            {
                var dxOggFile = new FileInfo(Path.Combine(pathToModSystem, "DXOgg.u"));
                File.Copy(dxOggFile.FullName, Path.Combine(pathToSystem, dxOggFile.Name), true);
            }

            foreach (FileInfo oggFile in oggMusicModDirInfo.GetFiles())
            {
                Console.WriteLine("Copying file: {0}", oggFile.Name);
                File.Copy(oggFile.FullName, Path.Combine(pathToOggMusic, oggFile.Name), true);
            }

            Console.WriteLine("Done copying ogg music!");
        }
    }
}