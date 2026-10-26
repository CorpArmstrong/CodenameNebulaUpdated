using System;
using System.Drawing;
using System.Runtime.InteropServices;
using System.Windows.Forms;

namespace CNNLauncher
{
    // The launcher's dark look, shared by the main window and Settings
    public static class Theme
    {
        public static readonly Color Accent = Color.FromArgb(47, 111, 214);
        public static readonly Color AccentLight = Color.FromArgb(90, 160, 255);
        public static readonly Color Muted = Color.FromArgb(160, 172, 196);
        public static readonly Color Window = Color.FromArgb(12, 15, 30);
        public static readonly Color Field = Color.FromArgb(22, 28, 50);
        public static readonly Color Border = Color.FromArgb(70, 90, 130);
        public static readonly Color Text = Color.FromArgb(228, 233, 245);

        public static void StyleButton(Button b, bool primary)
        {
            b.FlatStyle = FlatStyle.Flat;
            b.ForeColor = Color.White;
            b.UseVisualStyleBackColor = false;
            b.BackColor = primary ? Accent : Color.FromArgb(120, 18, 24, 44);
            b.FlatAppearance.BorderSize = 1;
            b.FlatAppearance.BorderColor = primary ? AccentLight : Border;
            b.FlatAppearance.MouseOverBackColor = primary ? Color.FromArgb(66, 134, 240) : Color.FromArgb(170, 36, 56, 100);
            b.FlatAppearance.MouseDownBackColor = primary ? Color.FromArgb(36, 90, 180) : Color.FromArgb(200, 26, 40, 76);
        }

        // A flat drop-down list drawn in the window's colours; the system one
        // stays light whatever BackColor says
        public static void StyleComboBox(ComboBox box)
        {
            box.FlatStyle = FlatStyle.Flat;
            box.BackColor = Field;
            box.ForeColor = Text;
            box.DrawMode = DrawMode.OwnerDrawFixed;
            box.DrawItem += (s, e) =>
            {
                bool selected = (e.State & DrawItemState.Selected) != 0 && (e.State & DrawItemState.ComboBoxEdit) == 0;
                using (var back = new SolidBrush(selected ? Accent : Field))
                    e.Graphics.FillRectangle(back, e.Bounds);
                if (e.Index >= 0)
                    TextRenderer.DrawText(e.Graphics, box.GetItemText(box.Items[e.Index]), box.Font, e.Bounds,
                                          box.Enabled ? Text : Muted,
                                          TextFormatFlags.Left | TextFormatFlags.VerticalCenter | TextFormatFlags.NoPrefix);
            };
        }

        public static void StyleCheckBox(CheckBox box)
        {
            box.FlatStyle = FlatStyle.Flat;
            box.ForeColor = Text;
            box.FlatAppearance.BorderColor = Border;
            box.FlatAppearance.CheckedBackColor = Field;
            box.FlatAppearance.MouseOverBackColor = Field;
        }

        // Windows 10 1809+ draws the title bar dark on request; older builds
        // ignore the call and keep the light one
        public static void DarkTitleBar(Form form)
        {
            form.HandleCreated += (s, e) =>
            {
                try
                {
                    int on = 1;
                    if (DwmSetWindowAttribute(form.Handle, 20, ref on, sizeof(int)) != 0)
                        DwmSetWindowAttribute(form.Handle, 19, ref on, sizeof(int));
                }
                catch (DllNotFoundException) { }
                catch (EntryPointNotFoundException) { }
            };
        }

        [DllImport("dwmapi.dll")]
        private static extern int DwmSetWindowAttribute(IntPtr hwnd, int attribute, ref int value, int size);
    }
}
