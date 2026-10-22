using System;
using System.ComponentModel;
using System.Diagnostics;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Text;
using System.Windows.Forms;

namespace CNNLauncher
{
    public class MainWindow : Form
    {
        private static readonly Color Accent = Color.FromArgb(47, 111, 214);
        private static readonly Color AccentLight = Color.FromArgb(90, 160, 255);
        private static readonly Color Muted = Color.FromArgb(160, 172, 196);

        private readonly GameFolder game = GameFolder.FromLauncher();
        private readonly float scale;
        private readonly Button playButton, playSteamButton, configureButton, repairButton;
        private readonly Label status;

        public MainWindow()
        {
            Text = "Codename Nebula";
            Icon = Icon.ExtractAssociatedIcon(Application.ExecutablePath);
            FormBorderStyle = FormBorderStyle.FixedSingle;
            MaximizeBox = false;
            StartPosition = FormStartPosition.CenterScreen;
            DoubleBuffered = true;

            // laid out at 96 DPI and scaled by hand: fonts follow the DPI on
            // their own, sizes and positions do not
            using (var g = CreateGraphics())
                scale = g.DpiX / 96F;
            ClientSize = Scaled(978, 544);
            BackColor = Color.FromArgb(7, 9, 22);
            BackgroundImageLayout = ImageLayout.None;
            BackgroundImage = PaintBackground(ClientSize);

            playButton = MakeButton("PLAY", true);
            playSteamButton = MakeButton("PLAY THROUGH STEAM", false);
            configureButton = MakeButton("SETTINGS", false);
            repairButton = MakeButton("REPAIR", false);
            status = new Label
            {
                BackColor = Color.Transparent,
                ForeColor = Muted,
                Font = new Font("Segoe UI", 8.5F),
                Location = new Point(S(40), S(430)),
                Size = Scaled(270, 100)
            };

            playButton.Click += (s, e) => Play(false);
            playSteamButton.Click += (s, e) => Play(true);
            configureButton.Click += (s, e) => Configure();
            repairButton.Click += (s, e) => Repair();
            Controls.AddRange(new Control[] { playButton, playSteamButton, configureButton, repairButton, status });
            RefreshState();
        }

        // the window is sized by hand after Windows placed it, so centre it again
        protected override void OnShown(EventArgs e)
        {
            base.OnShown(e);
            CenterToScreen();
        }

        private int S(int v) { return (int)(v * scale); }
        private Size Scaled(int w, int h) { return new Size(S(w), S(h)); }

        // The nebula, the darker menu panel on the left, the emblem and the title,
        // drawn at the window's real pixel size
        private Bitmap PaintBackground(Size size)
        {
            var bmp = NebulaArt.Render(size.Width, size.Height);
            using (var g = Graphics.FromImage(bmp))
            {
                g.SmoothingMode = SmoothingMode.AntiAlias;
                g.TextRenderingHint = TextRenderingHint.AntiAliasGridFit;

                // a dark panel behind the menu that fades into the nebula
                var panel = new Rectangle(0, 0, S(460), size.Height);
                // the brush 2 px wider than the fill: GDI+ repeats a gradient at its edge as a hairline
                using (var shade = new LinearGradientBrush(new Rectangle(-1, 0, panel.Width + 2, panel.Height), Color.Black, Color.Black, LinearGradientMode.Horizontal))
                {
                    var blend = new ColorBlend
                    {
                        Colors = new[] { Color.FromArgb(225, 5, 7, 16), Color.FromArgb(190, 5, 7, 16), Color.FromArgb(0, 5, 7, 16) },
                        Positions = new[] { 0f, 0.68f, 1f }
                    };
                    shade.InterpolationColors = blend;
                    g.FillRectangle(shade, panel);
                }

                DrawEmblem(g, new PointF(S(72), S(78)), S(30));
                using (var codename = new Font("Segoe UI", 15 * scale, FontStyle.Regular, GraphicsUnit.Pixel))
                using (var nebula = new Font("Segoe UI Semibold", 34 * scale, FontStyle.Bold, GraphicsUnit.Pixel))
                using (var sub = new Font("Segoe UI", 12 * scale, GraphicsUnit.Pixel))
                using (var white = new SolidBrush(Color.White))
                using (var light = new SolidBrush(AccentLight))
                using (var muted = new SolidBrush(Muted))
                {
                    g.DrawString("C O D E N A M E", codename, light, S(114), S(50));
                    g.DrawString("NEBULA", nebula, white, S(110), S(66));
                    g.DrawString("A Deus Ex total conversion", sub, muted, S(42), S(124));
                    var version = "v" + Application.ProductVersion.Split('+')[0];
                    var vs = g.MeasureString(version, sub);
                    g.DrawString(version, sub, muted, size.Width - vs.Width - S(12), size.Height - vs.Height - S(8));
                }
            }
            return bmp;
        }

        // Rings and a red crosshair, after the mod's icon
        private static void DrawEmblem(Graphics g, PointF c, float r)
        {
            foreach (float k in new[] { 0.38f, 0.66f, 0.95f })
            {
                float rr = r * k;
                using (var glow = new Pen(Color.FromArgb(55, 80, 140, 255), r * 0.16f))
                    g.DrawEllipse(glow, c.X - rr, c.Y - rr, rr * 2, rr * 2);
                using (var ring = new Pen(Color.FromArgb(230, 110, 170, 255), Math.Max(1.2f, r * 0.05f)))
                    g.DrawEllipse(ring, c.X - rr, c.Y - rr, rr * 2, rr * 2);
            }
            using (var cross = new Pen(Color.FromArgb(220, 230, 60, 70), Math.Max(1.2f, r * 0.06f)))
            {
                g.DrawLine(cross, c.X - r * 1.15f, c.Y, c.X - r * 0.45f, c.Y);
                g.DrawLine(cross, c.X + r * 0.45f, c.Y, c.X + r * 1.15f, c.Y);
                g.DrawLine(cross, c.X, c.Y - r * 1.15f, c.X, c.Y - r * 0.45f);
                g.DrawLine(cross, c.X, c.Y + r * 0.45f, c.X, c.Y + r * 1.15f);
            }
            using (var core = new SolidBrush(Color.FromArgb(255, 200, 225, 255)))
                g.FillEllipse(core, c.X - r * 0.12f, c.Y - r * 0.12f, r * 0.24f, r * 0.24f);
        }

        private Button MakeButton(string text, bool primary)
        {
            var b = new Button
            {
                Text = text,
                Size = Scaled(270, 46),
                FlatStyle = FlatStyle.Flat,
                ForeColor = Color.White,
                Font = new Font("Segoe UI Semibold", 10.5F),
                TextAlign = ContentAlignment.MiddleLeft,
                Padding = new Padding(S(14), 0, 0, 0),
                Cursor = Cursors.Hand,
                UseVisualStyleBackColor = false,
                BackColor = primary ? Accent : Color.FromArgb(120, 18, 24, 44)
            };
            b.FlatAppearance.BorderSize = 1;
            b.FlatAppearance.BorderColor = primary ? AccentLight : Color.FromArgb(70, 90, 130);
            b.FlatAppearance.MouseOverBackColor = primary ? Color.FromArgb(66, 134, 240) : Color.FromArgb(170, 36, 56, 100);
            b.FlatAppearance.MouseDownBackColor = primary ? Color.FromArgb(36, 90, 180) : Color.FromArgb(200, 26, 40, 76);
            return b;
        }

        // Buttons stack from the top of the menu; a hidden Steam button leaves no gap
        // (Visible reads false for every control until the window is shown)
        private void LayoutButtons(bool withSteam)
        {
            int y = 168;
            playSteamButton.Visible = withSteam;
            foreach (var b in new[] { playButton, playSteamButton, configureButton, repairButton })
            {
                if (b == playSteamButton && !withSteam)
                    continue;
                b.Location = new Point(S(40), S(y));
                y += b == playButton ? 62 : 54;
            }
        }

        private void RefreshState()
        {
            LayoutButtons(GameStarter.CanUseSteam(game));
            if (!game.IsGameFolder)
            {
                status.Text = "Codename Nebula is not inside a Deus Ex folder:\n" + game.ModRoot +
                              "\n\nReinstall it into <Deus Ex>\\CodenameNebula.";
                playButton.Enabled = configureButton.Enabled = repairButton.Enabled = false;
                return;
            }
            LaunchPlan plan = GameStarter.Plan(game);
            status.Text = (plan.CanStart ? plan.Explanation : "Codename Nebula cannot be started - press Play for details.") +
                          "\n\nDeus Ex: " + game.GameRoot;
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
