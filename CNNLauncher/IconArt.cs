using System;
using System.Drawing;
using System.Drawing.Drawing2D;

namespace CNNLauncher
{
    // The mod's icon (CodenameNebula\cnnico.ico, Tantalus 2018) redrawn in its
    // own 32-unit space so it stays sharp at any size: the 32x32 original only
    // blurs when scaled up. Blue rings, a violet core, red glints with ticks
    // at the four sides and a red-violet tail to the lower left; each stroke
    // is drawn several times, wider and fainter, for the glow.
    public static class IconArt
    {
        public static void Draw(Graphics g, PointF center, float size)
        {
            g.SmoothingMode = SmoothingMode.AntiAlias;
            float k = size / 32f;

            // faint outer spiral arms and the diagonal threads
            Arc(g, center, k, Color.FromArgb(130, 40, 60, 210), 13.2f, 0.55f, 290, 120, 0.2f, 0.3f);
            Arc(g, center, k, Color.FromArgb(100, 40, 60, 200), 13.0f, 0.5f, 120, 70, 0, 0);
            Line(g, center, k, Color.FromArgb(110, 50, 70, 200), 21, 0.5f, 25, 4, 0.5f);
            Line(g, center, k, Color.FromArgb(100, 50, 70, 200), 26, 3, 31, 8, 0.45f);
            Line(g, center, k, Color.FromArgb(110, 50, 70, 200), 11.5f, 31.5f, 13.5f, 26, 0.5f);

            // outer ring, brighter to the lower left
            Arc(g, center, k, Color.FromArgb(170, 40, 65, 215), 9.9f, 0.8f, 0, 360, 0, 0.3f);
            Arc(g, center, k, Color.FromArgb(225, 55, 95, 250), 9.9f, 0.95f, 100, 150, 0, 0.3f);

            // inner ring
            Arc(g, center, k, Color.FromArgb(255, 55, 95, 255), 6.4f, 1.15f, 0, 360, -0.3f, 0.5f);
            Arc(g, center, k, Color.FromArgb(255, 90, 130, 255), 6.4f, 1.2f, 110, 150, -0.3f, 0.5f);

            // red ticks and glints at the four sides
            var red = Color.FromArgb(230, 230, 30, 50);
            var dim = Color.FromArgb(150, 150, 20, 40);
            Line(g, center, k, dim, 16, 0.5f, 16, 5, 0.55f);
            Line(g, center, k, dim, 16, 27, 16, 31.5f, 0.55f);
            Line(g, center, k, dim, 0.5f, 15, 5, 15, 0.55f);
            Line(g, center, k, dim, 27, 16.5f, 31.5f, 16.5f, 0.55f);
            foreach (var pt in new[] { new PointF(16, 6.8f), new PointF(7.6f, 15.1f), new PointF(24.6f, 16.4f), new PointF(16, 24.5f) })
                for (int i = 3; i >= 0; i--)
                    using (var b = new SolidBrush(Color.FromArgb(i == 0 ? 255 : 60 / i, red)))
                    {
                        float rr = (0.9f + i * 0.9f) * k;
                        PointF p = At(center, k, pt.X, pt.Y);
                        g.FillEllipse(b, p.X - rr, p.Y - rr, rr * 2, rr * 2);
                    }

            // the red-violet tail
            Line(g, center, k, Color.FromArgb(220, 200, 30, 70), 0.5f, 21.5f, 9.5f, 18.2f, 0.9f);
            Line(g, center, k, Color.FromArgb(200, 150, 50, 200), 6, 20, 10.5f, 18, 0.7f);

            // glowing violet core
            using (var path = new GraphicsPath())
            {
                float r = 4.6f * k;
                path.AddEllipse(center.X - r, center.Y - r, r * 2, r * 2);
                using (var br = new PathGradientBrush(path))
                {
                    br.CenterColor = Color.FromArgb(255, 170, 150, 255);
                    br.SurroundColors = new[] { Color.FromArgb(0, 60, 40, 220) };
                    g.FillPath(br, path);
                }
            }
            using (var b = new SolidBrush(Color.FromArgb(255, 150, 120, 255)))
            {
                float r = 1.6f * k;
                g.FillEllipse(b, center.X - r, center.Y - r, r * 2, r * 2);
            }
        }

        // icon coordinates (0..32, centre 16,16) to the target graphics
        private static PointF At(PointF c, float k, float x, float y)
        {
            return new PointF(c.X + (x - 16) * k, c.Y + (y - 16) * k);
        }

        private static void Arc(Graphics g, PointF c, float k, Color col, float r, float width,
                                float start, float sweep, float ox, float oy)
        {
            PointF o = At(c, k, 16 + ox, 16 + oy);
            for (int i = 3; i >= 0; i--)
                using (var p = new Pen(Color.FromArgb(i == 0 ? col.A : col.A / (3 + i * 2), col), width * k * (1 + i * 1.6f)))
                {
                    p.StartCap = p.EndCap = LineCap.Round;
                    g.DrawArc(p, o.X - r * k, o.Y - r * k, r * 2 * k, r * 2 * k, start, sweep);
                }
        }

        private static void Line(Graphics g, PointF c, float k, Color col, float x1, float y1, float x2, float y2, float width)
        {
            PointF a = At(c, k, x1, y1), b = At(c, k, x2, y2);
            for (int i = 3; i >= 0; i--)
                using (var p = new Pen(Color.FromArgb(i == 0 ? col.A : col.A / (3 + i * 2), col), width * k * (1 + i * 1.8f)))
                {
                    p.StartCap = p.EndCap = LineCap.Round;
                    g.DrawLine(p, a, b);
                }
        }
    }
}
