using System;
using System.Collections.Generic;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices;
using System.Windows.Forms;

namespace CNNLauncher
{
    // Renderer, resolution, fullscreen and HD textures, written into CNN.ini --
    // the settings players otherwise fix by hand (FixRenderer used to do part).
    public class ConfigureWindow : Form
    {
        private class Renderer
        {
            public string Name, Device, Dll;
            public override string ToString() { return Name; }
        }

        // Only renderers that work on Windows 10/11; Glide, the 1999 D3D7 device
        // and Software are left out on purpose ("Failed resetting mode")
        private static readonly Renderer[] Renderers =
        {
            new Renderer { Name = "Direct3D 9 (recommended)", Device = "D3D9Drv.D3D9RenderDevice", Dll = "D3D9Drv.dll" },
            new Renderer { Name = "Direct3D 10 (Kentie)", Device = "D3D10Drv.D3D10RenderDevice", Dll = "D3D10Drv.dll" },
            new Renderer { Name = "OpenGL", Device = "OpenGLDrv.OpenGLRenderDevice", Dll = "OpenGlDrv.dll" }
        };

        private const string Engine = "Engine.Engine";
        private const string Client = "WinDrv.WindowsClient";

        private readonly GameFolder game;
        private readonly IniFile ini;
        private readonly ComboBox renderer = new ComboBox { DropDownStyle = ComboBoxStyle.DropDownList, Dock = DockStyle.Fill };
        private readonly ComboBox resolution = new ComboBox { DropDownStyle = ComboBoxStyle.DropDownList, Dock = DockStyle.Fill };
        private readonly CheckBox fullscreen = new CheckBox { Text = "Fullscreen", AutoSize = true };
        private readonly CheckBox hdTextures = new CheckBox { Text = "HD textures (New Vision / HDTP, if installed)", AutoSize = true };
        private readonly string[] hdPaths;

        public ConfigureWindow(GameFolder game)
        {
            this.game = game;
            ini = new IniFile(game.CnnIni);
            hdPaths = new ModSetup(game).FindHDPaths();

            Text = "Codename Nebula - Settings";
            FormBorderStyle = FormBorderStyle.FixedDialog;
            MaximizeBox = MinimizeBox = false;
            StartPosition = FormStartPosition.CenterParent;
            float scale;
            using (var g = CreateGraphics())
                scale = g.DpiX / 96F;
            ClientSize = new Size((int)(440 * scale), (int)(220 * scale));
            Font = new Font("Segoe UI", 9F);

            var layout = new TableLayoutPanel { Dock = DockStyle.Fill, Padding = new Padding(14), ColumnCount = 2 };
            layout.ColumnStyles.Add(new ColumnStyle(SizeType.AutoSize));
            layout.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
            layout.Controls.Add(new Label { Text = "Renderer", AutoSize = true, Anchor = AnchorStyles.Left }, 0, 0);
            layout.Controls.Add(renderer, 1, 0);
            layout.Controls.Add(new Label { Text = "Resolution", AutoSize = true, Anchor = AnchorStyles.Left }, 0, 1);
            layout.Controls.Add(resolution, 1, 1);
            layout.Controls.Add(fullscreen, 1, 2);
            layout.Controls.Add(hdTextures, 1, 3);

            var buttons = new FlowLayoutPanel { FlowDirection = FlowDirection.RightToLeft, Dock = DockStyle.Bottom, Height = (int)(48 * scale), Padding = new Padding(10) };
            var ok = new Button { Text = "Save", DialogResult = DialogResult.OK, AutoSize = true };
            var cancel = new Button { Text = "Cancel", DialogResult = DialogResult.Cancel, AutoSize = true };
            ok.Click += (s, e) => Save();
            buttons.Controls.Add(cancel);
            buttons.Controls.Add(ok);
            AcceptButton = ok;
            CancelButton = cancel;

            Controls.Add(layout);
            Controls.Add(buttons);
            LoadValues();
        }

        private void LoadValues()
        {
            string current = ini.Get(Engine, "GameRenderDevice") ?? "";
            foreach (var r in Renderers)
                if (File.Exists(Path.Combine(game.GameSystem, r.Dll)) || current.Equals(r.Device, StringComparison.OrdinalIgnoreCase))
                    renderer.Items.Add(r);
            renderer.SelectedItem = renderer.Items.Cast<Renderer>()
                .FirstOrDefault(r => r.Device.Equals(current, StringComparison.OrdinalIgnoreCase));
            if (renderer.SelectedIndex < 0 && renderer.Items.Count > 0)
                renderer.SelectedIndex = 0;

            string w = ini.Get(Client, "FullscreenViewportX"), h = ini.Get(Client, "FullscreenViewportY");
            foreach (string mode in DisplayModes())
                resolution.Items.Add(mode);
            string currentMode = w + "x" + h;
            if (!resolution.Items.Contains(currentMode) && w != null)
                resolution.Items.Insert(0, currentMode);
            resolution.SelectedItem = currentMode;
            if (resolution.SelectedIndex < 0 && resolution.Items.Count > 0)
                resolution.SelectedIndex = 0;

            fullscreen.Checked = !"False".Equals(ini.Get(Client, "StartupFullscreen"), StringComparison.OrdinalIgnoreCase);
            hdTextures.Enabled = hdPaths.Length > 0;
            hdTextures.Checked = ini.Lines.Any(IsHdPath);
        }

        private void Save()
        {
            if (renderer.SelectedItem is Renderer r)
                foreach (string key in new[] { "GameRenderDevice", "WindowedRenderDevice", "RenderDevice" })
                    ini.Set(Engine, key, r.Device);

            if (resolution.SelectedItem is string mode)
            {
                string[] wh = mode.Split('x');
                ini.Set(Client, "FullscreenViewportX", wh[0]);
                ini.Set(Client, "FullscreenViewportY", wh[1]);
                ini.Set(Client, "WindowedViewportX", wh[0]);
                ini.Set(Client, "WindowedViewportY", wh[1]);
            }
            ini.Set(Client, "StartupFullscreen", fullscreen.Checked ? "True" : "False");

            // HD texture paths go first among Paths= so they take precedence
            ini.Lines.RemoveAll(l => IsHdPath(l) || l.StartsWith("; HD Textures"));
            if (hdTextures.Checked && hdPaths.Length > 0)
            {
                int at = ini.Lines.FindIndex(l => l.StartsWith(@"Paths=..\CodenameNebula", StringComparison.OrdinalIgnoreCase));
                if (at >= 0)
                    ini.Lines.InsertRange(at, hdPaths);
            }
            ini.Save();
        }

        // Absolute Paths= to NewVision / HDTP (CNN's own paths are relative)
        private static bool IsHdPath(string line)
        {
            return line.StartsWith("Paths=") && line.Length > 7 && line[7] == ':' &&
                   (line.IndexOf("NewVision", StringComparison.OrdinalIgnoreCase) >= 0 ||
                    line.IndexOf("New Vision", StringComparison.OrdinalIgnoreCase) >= 0 ||
                    line.IndexOf("HDTP", StringComparison.OrdinalIgnoreCase) >= 0);
        }

        // Real display modes of the main monitor, 800x600 and up, largest first
        private static IEnumerable<string> DisplayModes()
        {
            var modes = new List<Tuple<int, int>>();
            var dm = new ModSetup.DEVMODE();
            dm.dmSize = (short)Marshal.SizeOf(typeof(ModSetup.DEVMODE));
            for (int i = 0; ModSetup.EnumDisplaySettings(null, i, ref dm); i++)
            {
                var m = Tuple.Create(dm.dmPelsWidth, dm.dmPelsHeight);
                if (dm.dmBitsPerPel == 32 && m.Item1 >= 800 && m.Item2 >= 600 && !modes.Contains(m))
                    modes.Add(m);
            }
            return modes.OrderByDescending(m => m.Item1 * m.Item2).Select(m => m.Item1 + "x" + m.Item2);
        }
    }
}
