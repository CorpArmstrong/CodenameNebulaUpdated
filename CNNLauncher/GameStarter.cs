using System;
using System.Diagnostics;
using System.IO;

namespace CNNLauncher
{
    // How Codename Nebula gets started, decided at every start from what the
    // game folder holds now -- a Steam update, Kentie or Community Update
    // installed later change DeusEx.exe after the mod was installed.
    public class LaunchPlan
    {
        public bool CanStart;
        public bool ThroughSteam;
        public string Exe;          // started directly
        public string Explanation;  // shown to the player
    }

    public static class GameStarter
    {
        public static LaunchPlan Plan(GameFolder game)
        {
            // CD copies: the setup made a renamed copy of the player's own exe
            // (DeusEx.exe itself asks for the disc)
            string cdExe = Path.Combine(game.GameSystem, GameFolder.CdExeName);
            ExeKind kind = game.DeusExKind;

            if (File.Exists(cdExe) && GameFolder.Classify(cdExe) == ExeKind.Original)
                return Direct(cdExe, "Starts " + GameFolder.CdExeName + ".");

            switch (kind)
            {
                case ExeKind.Original:
                case ExeKind.ThirdParty:
                    return Direct(game.DeusExExe, GameFolder.Describe(kind) + ": starts DeusEx.exe.");

                case ExeKind.SteamStub:
                    return new LaunchPlan
                    {
                        CanStart = true,
                        ThroughSteam = true,
                        Explanation = "Steam version: Steam starts the game (it cannot be started directly)."
                    };

                case ExeKind.CuWrapper:
                    // CU's wrapper ignores our INI=; the original exe CU keeps next to it works
                    string original = Path.Combine(game.GameSystem, GameFolder.CuOriginalExe);
                    ExeKind originalKind = GameFolder.Classify(original);
                    if (originalKind == ExeKind.Original || originalKind == ExeKind.ThirdParty)
                        return Direct(original, "Community Update installed: starts its copy of the original exe.");
                    return new LaunchPlan
                    {
                        CanStart = false,
                        Explanation =
                            "Community Update has replaced DeusEx.exe with its own starter, which can only run " +
                            "Community Update itself, and the original exe is not there.\n\n" +
                            "To play Codename Nebula, do one of these:\n" +
                            " - in Community Update's installer choose the option that keeps the original DeusEx.exe, or\n" +
                            " - install Kentie's Deus Exe (kentie.net) in place of DeusEx.exe, or\n" +
                            " - on Steam: Deus Ex > Properties > Installed Files > Verify integrity (this undoes CU's exe)."
                    };

                default:
                    return new LaunchPlan
                    {
                        CanStart = false,
                        Explanation = "DeusEx.exe was not found in " + game.GameSystem + ".\n\n" +
                                      "Codename Nebula must be installed into your Deus Ex folder " +
                                      "(the one with the System folder), as <Deus Ex>\\CodenameNebula."
                    };
            }
        }

        private static LaunchPlan Direct(string exe, string explanation)
        {
            return new LaunchPlan { CanStart = true, Exe = exe, Explanation = explanation };
        }

        // Whether "Play through Steam" can work: Steam starts its DeusEx.exe,
        // which must pass our INI= on (CU's wrapper does not)
        public static bool CanUseSteam(GameFolder game)
        {
            return game.IsSteamCopy && game.DeusExKind != ExeKind.CuWrapper && game.DeusExKind != ExeKind.Missing;
        }

        public static void Start(GameFolder game, LaunchPlan plan)
        {
            if (plan.ThroughSteam)
                StartThroughSteam(game);
            else
                StartDirect(game, plan.Exe);
        }

        public static void StartDirect(GameFolder game, string exe)
        {
            var psi = new ProcessStartInfo(exe, IniArguments(game, "\""))
            {
                WorkingDirectory = game.GameSystem,
                UseShellExecute = false
            };
            Process.Start(psi);
        }

        // steam://rungameid/6910//INI=%22<path>%22 USERINI=%22<path>%22 -- Steam
        // starts the game's DeusEx.exe with these arguments (verified 2026-10-22)
        public static void StartThroughSteam(GameFolder game)
        {
            string url = "steam://rungameid/" + GameFolder.SteamAppId + "//" + IniArguments(game, "%22");
            Process.Start(new ProcessStartInfo(url) { UseShellExecute = true });
        }

        private static string IniArguments(GameFolder game, string quote)
        {
            return "INI=" + quote + game.CnnIni + quote + " USERINI=" + quote + game.CnnUserIni + quote;
        }

        public static string Summary(LaunchPlan plan)
        {
            if (!plan.CanStart)
                return "cannot start: " + plan.Explanation.Split('\n')[0];
            return plan.ThroughSteam ? "through Steam" : "direct: " + plan.Exe;
        }
    }
}
