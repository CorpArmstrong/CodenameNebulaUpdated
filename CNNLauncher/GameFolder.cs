using System;
using System.IO;
using System.Text;

namespace CNNLauncher
{
    // What the player's DeusEx.exe is. Decides how the game can be started.
    public enum ExeKind
    {
        Missing,
        SteamStub,      // Steam's DRM-wrapped exe (64,000 bytes since the 2025-09 build): only Steam can start it
        CuWrapper,      // Community Update's 7-Zip wrapper: runs CU's own game and drops every argument
        Original,       // 1112fm or CD exe (~254 KB): starts directly
        ThirdParty      // Kentie's or Han's launcher (> 300 KB): starts directly
    }

    // The mod folder (where CNNLauncher.exe lives, <game>\CodenameNebula) and
    // the game around it. Paths in CNN.ini are relative to the game's System
    // (..\CodenameNebula\...), so the mod must sit directly in the game folder.
    public class GameFolder
    {
        public const string SteamAppId = "6910";
        public const string CdExeName = "CodenameNebula.exe";
        public const string CuOriginalExe = "DeusEx 1112fm (Original EXE).exe";

        // DeusEx.u of Deus Ex 1112fm (Steam, GOG and GOTY CD ship the same file)
        public const long StockDeusExUSize = 5386972;

        private const long SteamStubMax = 100000;
        private const long ThirdPartyMin = 300000;

        public string ModRoot { get; }
        public string GameRoot { get; }
        public string ModSystem => Path.Combine(ModRoot, "System");
        public string GameSystem => Path.Combine(GameRoot, "System");
        public string CnnIni => Path.Combine(ModSystem, "CNN.ini");
        public string CnnUserIni => Path.Combine(ModSystem, "CNNUser.ini");
        public string DeusExExe => Path.Combine(GameSystem, "DeusEx.exe");

        public GameFolder(string modRoot)
        {
            ModRoot = Path.GetFullPath(modRoot).TrimEnd('\\', '/');
            GameRoot = Path.GetDirectoryName(ModRoot) ?? ModRoot;
        }

        public static GameFolder FromLauncher()
        {
            return new GameFolder(AppDomain.CurrentDomain.BaseDirectory);
        }

        public bool IsGameFolder => File.Exists(DeusExExe) || File.Exists(Path.Combine(GameSystem, "DeusEx.u"));

        public bool IsInstalled => File.Exists(CnnIni);

        // A Steam copy: Steam's install script or library layout
        public bool IsSteamCopy =>
            File.Exists(Path.Combine(GameRoot, "installscript.vdf")) ||
            GameRoot.IndexOf(@"\steamapps\common\", StringComparison.OrdinalIgnoreCase) >= 0;

        public ExeKind DeusExKind => Classify(DeusExExe);

        public static ExeKind Classify(string exe)
        {
            if (!File.Exists(exe))
                return ExeKind.Missing;
            long size = new FileInfo(exe).Length;
            if (size < SteamStubMax)
                return ExeKind.SteamStub;
            if (IsCuWrapper(exe))
                return ExeKind.CuWrapper;
            return size > ThirdPartyMin ? ExeKind.ThirdParty : ExeKind.Original;
        }

        // CU's wrapper is a 7-Zip self-extractor whose script starts
        // ..\Mods\Community Update\System\Deus Ex Community Update.exe
        private static bool IsCuWrapper(string exe)
        {
            byte[] bytes = File.ReadAllBytes(exe);
            string text = Encoding.ASCII.GetString(bytes);
            return text.Contains("SteamProxy.bat") || text.Contains(";!@Install@!UTF-8!");
        }

        public long DeusExUSize
        {
            get
            {
                var f = new FileInfo(Path.Combine(GameSystem, "DeusEx.u"));
                return f.Exists ? f.Length : -1;
            }
        }

        public static string Describe(ExeKind kind)
        {
            switch (kind)
            {
                case ExeKind.SteamStub: return "Steam version";
                case ExeKind.CuWrapper: return "Community Update installed";
                case ExeKind.Original: return "Deus Ex 1112fm (GOG / CD)";
                case ExeKind.ThirdParty: return "Kentie's / Han's launcher";
                default: return "DeusEx.exe not found";
            }
        }
    }
}
