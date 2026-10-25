using System;
using System.IO;
using System.Windows.Forms;

namespace CNNLauncher
{
    // CNNLauncher.exe            the launcher window
    // CNNLauncher.exe --setup    set the mod up (run hidden by the installer); exit code 0 = done
    // CNNLauncher.exe --play     start the game the way Play would, without the window
    // CNNLauncher.exe --plan     only write how the game would be started to System\CNNLaunch.log
    static class Program
    {
        [STAThread]
        static int Main(string[] args)
        {
            string mode = args.Length > 0 ? args[0].ToLowerInvariant() : "";
            var game = GameFolder.FromLauncher();
            try
            {
                switch (mode)
                {
                    case "--setup":
                        return new ModSetup(game).Run() ? 0 : 1;

                    case "--play":
                    case "--plan":
                        LaunchPlan plan = GameStarter.Plan(game);
                        File.AppendAllText(Path.Combine(game.ModSystem, "CNNLaunch.log"),
                            DateTime.Now + "  " + GameFolder.Describe(game.DeusExKind) + "  -> " + GameStarter.Summary(plan) + Environment.NewLine);
                        if (mode == "--play" && plan.CanStart)
                            GameStarter.Start(game, plan);
                        return plan.CanStart ? 0 : 1;
                }
            }
            catch (Exception ex)
            {
                File.AppendAllText(Path.Combine(game.ModSystem, "CNNLaunch.log"), DateTime.Now + "  error: " + ex + Environment.NewLine);
                return 2;
            }

            // the installer's AppMutex: setup and uninstall ask to close the launcher first
            using (new System.Threading.Mutex(false, "CodenameNebulaLauncher"))
            {
                Application.EnableVisualStyles();
                Application.SetCompatibleTextRenderingDefault(false);
                Application.Run(new MainWindow());
            }
            return 0;
        }
    }
}
