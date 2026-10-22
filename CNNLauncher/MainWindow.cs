using System;
using System.ComponentModel;
using System.Diagnostics;
using System.Drawing;
using System.Windows.Forms;

namespace CNNLauncher
{
    public class MainWindow : Form
    {
        private readonly GameFolder game = GameFolder.FromLauncher();
        private readonly float scale;
        private readonly Button playButton, playSteamButton, configureButton, repairButton;
        private readonly Label status = new Label
        {
            Dock = DockStyle.Bottom,
            ForeColor = Color.Gainsboro,
            BackColor = Color.FromArgb(200, 10, 14, 20),
            Padding = new Padding(12, 6, 12, 6),
            Font = new Font("Segoe UI", 9F)
        };

        public MainWindow()
        {
            Text = "Codename Nebula";
            Icon = Icon.ExtractAssociatedIcon(Application.ExecutablePath);
            FormBorderStyle = FormBorderStyle.FixedSingle;
            MaximizeBox = false;
            StartPosition = FormStartPosition.CenterScreen;
            // laid out at 96 DPI and scaled by hand: fonts follow the DPI on
            // their own, sizes and positions do not
            using (var g = CreateGraphics())
                scale = g.DpiX / 96F;
            ClientSize = Scaled(978, 544);
            playButton = MakeButton("Play", 180);
            playSteamButton = MakeButton("Play through Steam", 230);
            configureButton = MakeButton("Settings", 280);
            repairButton = MakeButton("Repair", 330);
            status.Height = (int)(52 * scale);
            BackgroundImageLayout = ImageLayout.Stretch;
            using (var s = typeof(MainWindow).Assembly.GetManifestResourceStream("CNNLauncher.background.jpg"))
                if (s != null)
                    BackgroundImage = Image.FromStream(s);

            playButton.Click += (s, e) => Play(false);
            playSteamButton.Click += (s, e) => Play(true);
            configureButton.Click += (s, e) => Configure();
            repairButton.Click += (s, e) => Repair();
            Controls.AddRange(new Control[] { playButton, playSteamButton, configureButton, repairButton, status });
            RefreshState();
        }

        private Size Scaled(int w, int h)
        {
            return new Size((int)(w * scale), (int)(h * scale));
        }

        private Button MakeButton(string text, int y)
        {
            return new Button
            {
                Text = text,
                Location = new Point((int)(379 * scale), (int)(y * scale)),
                Size = Scaled(220, 44),
                Font = new Font("Segoe UI", 10F, FontStyle.Bold)
            };
        }

        private void RefreshState()
        {
            playSteamButton.Visible = GameStarter.CanUseSteam(game);
            if (!game.IsGameFolder)
            {
                status.Text = "Codename Nebula is not inside a Deus Ex folder: " + game.ModRoot +
                              "\nReinstall it into <Deus Ex>\\CodenameNebula.";
                playButton.Enabled = configureButton.Enabled = repairButton.Enabled = false;
                return;
            }
            LaunchPlan plan = GameStarter.Plan(game);
            status.Text = "Deus Ex: " + game.GameRoot + "   (" + GameFolder.Describe(game.DeusExKind) + ")\n" +
                          (plan.CanStart ? plan.Explanation : "Codename Nebula cannot be started - press Play for details.");
            configureButton.Enabled = game.IsInstalled;
        }

        private void Play(bool throughSteam)
        {
            try
            {
                if (!game.IsInstalled && !RunSetup(false))
                    return;
                LaunchPlan plan = throughSteam ? new LaunchPlan { CanStart = true, ThroughSteam = true } : GameStarter.Plan(game);
                if (!plan.CanStart)
                {
                    MessageBox.Show(this, plan.Explanation, "Codename Nebula", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    return;
                }
                GameStarter.Start(game, plan);
                Close();
            }
            catch (Exception ex)
            {
                MessageBox.Show(this, "Could not start the game:\n" + ex.Message, "Codename Nebula",
                                MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void Configure()
        {
            using (var w = new ConfigureWindow(game))
                w.ShowDialog(this);
        }

        private void Repair()
        {
            if (MessageBox.Show(this,
                    "Repair sets Codename Nebula up again from your Deus Ex settings: CNN.ini is rebuilt " +
                    "(your Codename Nebula graphics settings are reset) and the game files it needs are checked.\n\n" +
                    "Saved games are not touched. Continue?",
                    "Codename Nebula", MessageBoxButtons.YesNo, MessageBoxIcon.Question) != DialogResult.Yes)
                return;
            if (RunSetup(true))
                MessageBox.Show(this, "Done. Codename Nebula is set up again.", "Codename Nebula",
                                MessageBoxButtons.OK, MessageBoxIcon.Information);
            RefreshState();
        }

        // Writing into the game's System can need administrator rights (a game
        // under Program Files); then the same setup runs again elevated.
        private bool RunSetup(bool reportFailure)
        {
            try
            {
                var setup = new ModSetup(game);
                if (setup.Run())
                    return true;
                MessageBox.Show(this, setup.Log, "Codename Nebula", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return false;
            }
            catch (UnauthorizedAccessException)
            {
                try
                {
                    var p = Process.Start(new ProcessStartInfo(Application.ExecutablePath, "--setup")
                    {
                        Verb = "runas",
                        UseShellExecute = true
                    });
                    p.WaitForExit();
                    return p.ExitCode == 0;
                }
                catch (Win32Exception)
                {
                    if (reportFailure)
                        MessageBox.Show(this, "Setting up needs administrator rights for the Deus Ex folder.",
                                        "Codename Nebula", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    return false;
                }
            }
        }
    }
}
