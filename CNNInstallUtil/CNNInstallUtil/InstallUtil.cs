using System;
using System.Collections.Generic;
using System.Text;
using System.IO;

namespace CNNInstallUtil
{
    class InstallUtil
    {
        private string currentPath = Directory.GetCurrentDirectory();

        public void Install()
        {
            string pathToModSystem = Path.Combine(currentPath, "System");
            string pathToSystem = Path.Combine(Directory.GetParent(Environment.CurrentDirectory).ToString(), "System");

            DirectoryInfo modSystemInfo = new DirectoryInfo(pathToModSystem);
            DirectoryInfo originalSystemInfo = new DirectoryInfo(pathToSystem);

            FileInfo originalDeusExIni = new FileInfo(Path.Combine(pathToSystem, "DeusEx.ini"));
            FileInfo originalDeusExUserIni = new FileInfo(Path.Combine(pathToSystem, "User.ini"));

            if (!modSystemInfo.Exists)
            {
                Console.WriteLine("Error: directory {0} doesn't exists!", pathToModSystem);
                Console.WriteLine("Creating directory!");
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
                    Console.WriteLine("Error: file {0} doesn't exists!", originalDeusExIni.FullName);
                    Console.WriteLine("Creating template CNN.ini file!");
                    CreateTemplateCNNIniFile(pathToModSystem);
                }

                if (originalDeusExUserIni.Exists)
                {
                    File.Copy(originalDeusExUserIni.FullName, Path.Combine(pathToModSystem, "CNNUser.ini"), true);
                    Console.WriteLine("CNNUser.ini file created!");
                }
                else
                {
                    Console.WriteLine("Error: file {0} doesn't exists!", originalDeusExUserIni.FullName);
                    Console.WriteLine("Skipping copy file.");
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
            StreamWriter streamWriter = new StreamWriter(Path.Combine(pathToModSystem, "CNN.ini"));
            StringBuilder stringBuilder = new StringBuilder();

            stringBuilder.Append("[URL]");
            stringBuilder.AppendLine();
            stringBuilder.Append("Class=CNN.TantalusDenton");
            stringBuilder.AppendLine().AppendLine();
            stringBuilder.Append("[Engine.Engine]");
            stringBuilder.AppendLine();
            stringBuilder.Append("DefaultGame=CNN.CNNGameInfo");
            stringBuilder.AppendLine().AppendLine();
            stringBuilder.Append("[Core.System]");
            stringBuilder.AppendLine();
            stringBuilder.Append("SavePath=" + Path.Combine(currentPath, "Save"));
            stringBuilder.AppendLine();
            stringBuilder.Append("Paths=" + Path.Combine(currentPath, "Maps\\*.dx"));
            stringBuilder.AppendLine();
            stringBuilder.Append("Paths=" + Path.Combine(currentPath, "System\\*.u"));
            stringBuilder.AppendLine();
            stringBuilder.Append("Paths=" + Path.Combine(currentPath, "Textures\\*.utx"));
            stringBuilder.AppendLine();
            stringBuilder.Append("Paths=" + Path.Combine(currentPath, "Music\\*.umx"));
            stringBuilder.AppendLine();

            streamWriter.Write(stringBuilder.ToString());
            streamWriter.Flush();
            streamWriter.Close();
        }

        private void InjectIniProperties(string pathToFile)
        {
            List<string> iniKeyValues = new List<string>(File.ReadAllLines(pathToFile));

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

            DirectoryInfo musicDirInfo = new DirectoryInfo(pathToMusic);
            DirectoryInfo oggMusicDirInfo = new DirectoryInfo(pathToOggMusic);
            DirectoryInfo oggMusicModDirInfo = new DirectoryInfo(pathToModOggMusic);

            FileInfo dxOggDLLFile = new FileInfo(Path.Combine(pathToSystem, "DXOgg.dll"));
            FileInfo dxOggFile = new FileInfo(Path.Combine(pathToSystem, "DXOgg.u"));

            if (!musicDirInfo.Exists)
            {
                Console.WriteLine("Error: directory {0} doesn't exists!", pathToMusic);
                Console.WriteLine("Creating directory!");
                Directory.CreateDirectory(pathToMusic); // unauthorized exception?
            }

            if (!oggMusicDirInfo.Exists)
            {
                Console.WriteLine("Error: directory {0} doesn't exists!", pathToOggMusic);
                Console.WriteLine("Creating directory!");
                Directory.CreateDirectory(pathToOggMusic); // unauthorized exception?
            }

            File.Copy(dxOggDLLFile.FullName, Path.Combine(pathToSystem, dxOggDLLFile.Name), true);
            File.Copy(dxOggFile.FullName, Path.Combine(pathToSystem, dxOggFile.Name), true);

            foreach (FileInfo oggFile in oggMusicModDirInfo.GetFiles())
            {
                Console.WriteLine("Copying file: {0}", oggFile.Name);
                File.Copy(oggFile.FullName, Path.Combine(pathToOggMusic, oggFile.Name), true);
            }

            Console.WriteLine("Done copying ogg music!");
        }
    }
}
