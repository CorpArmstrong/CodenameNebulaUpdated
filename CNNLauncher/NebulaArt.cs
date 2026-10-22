using System;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;

namespace CNNLauncher
{
    // The launcher's background, drawn at start-up rather than shipped as a
    // picture: a nebula (domain-warped fractal noise), stars and the rim of a
    // planet. Same seed, same picture; sharp at any DPI; no third-party art.
    public static class NebulaArt
    {
        public static Bitmap Render(int width, int height, int seed = 1999)
        {
            // clouds are smooth: render them at half size and let GDI+ scale up
            int cw = Math.Max(1, width / 2), ch = Math.Max(1, height / 2);
            var clouds = new Bitmap(cw, ch, PixelFormat.Format32bppArgb);
            var noise = new Noise(seed);
            var data = clouds.LockBits(new Rectangle(0, 0, cw, ch), ImageLockMode.WriteOnly, PixelFormat.Format32bppArgb);
            var px = new int[cw * ch];
            float aspect = (float)cw / ch;
            for (int y = 0; y < ch; y++)
            {
                for (int x = 0; x < cw; x++)
                {
                    float u = (float)x / cw * aspect * 2.2f, v = (float)y / ch * 2.2f;
                    float wx = noise.Fbm(u + 3.1f, v + 1.7f, 4), wy = noise.Fbm(u - 2.3f, v + 5.9f, 4);
                    float n = noise.Fbm(u + 1.6f * wx, v + 1.6f * wy, 6);          // main cloud shape
                    float m = noise.Fbm(u * 1.7f + 9f, v * 1.7f - 4f, 5);            // colour mix
                    float d = Clamp((n - 0.42f) * 2.4f);                              // density
                    // keep the left third (the menu panel) quieter
                    float side = 0.35f + 0.65f * Smooth(0.15f, 0.7f, (float)x / cw);
                    d *= side;

                    // navy base -> violet / blue / magenta clouds with a cyan core
                    float r = 7, g = 9, b = 22;
                    float violet = d * (1 - m), blue = d * m;
                    r += violet * 120 + blue * 30;
                    g += violet * 40 + blue * 85;
                    b += violet * 170 + blue * 215;
                    float core = Clamp((d - 0.55f) * 3f);
                    r += core * 90; g += core * 150; b += core * 160;
                    float hot = Clamp((noise.Fbm(u * 3f, v * 3f, 3) - 0.62f) * 4f) * d;
                    r += hot * 120; g += hot * 30; b += hot * 60;                  // magenta knots
                    px[y * cw + x] = (255 << 24) | (Byte(r) << 16) | (Byte(g) << 8) | Byte(b);
                }
            }
            Marshal.Copy(px, 0, data.Scan0, px.Length);
            clouds.UnlockBits(data);

            var bmp = new Bitmap(width, height, PixelFormat.Format32bppArgb);
            using (var gfx = Graphics.FromImage(bmp))
            {
                gfx.InterpolationMode = InterpolationMode.HighQualityBicubic;
                gfx.DrawImage(clouds, new Rectangle(0, 0, width, height), 0, 0, cw, ch, GraphicsUnit.Pixel);
                clouds.Dispose();
                gfx.SmoothingMode = SmoothingMode.AntiAlias;
                DrawStars(gfx, width, height, seed);
                DrawPlanet(gfx, width, height);
            }
            return bmp;
        }

        private static void DrawStars(Graphics g, int w, int h, int seed)
        {
            var rnd = new Random(seed);
            int count = w * h / 900;
            for (int i = 0; i < count; i++)
            {
                float x = (float)rnd.NextDouble() * w, y = (float)rnd.NextDouble() * h;
                double t = rnd.NextDouble();
                float size = t > 0.985 ? 2.6f : t > 0.9 ? 1.6f : 1f;
                int a = (int)(70 + rnd.NextDouble() * 185);
                Color c = rnd.NextDouble() < 0.2 ? Color.FromArgb(a, 255, 220, 200) : Color.FromArgb(a, 210, 225, 255);
                using (var br = new SolidBrush(c))
                    g.FillEllipse(br, x, y, size, size);
                if (size > 2)   // a few bright stars get a soft cross
                    using (var pen = new Pen(Color.FromArgb(a / 3, c), 1f))
                    {
                        g.DrawLine(pen, x - 7, y + 1.3f, x + 9, y + 1.3f);
                        g.DrawLine(pen, x + 1.3f, y - 7, x + 1.3f, y + 9);
                    }
            }
        }

        // The night side of a planet in the lower right, lit along its rim
        private static void DrawPlanet(Graphics g, int w, int h)
        {
            float r = h * 0.95f;
            var body = new RectangleF(w * 0.66f, h * 0.56f, r * 2, r * 2);
            using (var path = new GraphicsPath())
            {
                path.AddEllipse(body);
                using (var fill = new PathGradientBrush(path))
                {
                    fill.CenterPoint = new PointF(body.X + r * 1.15f, body.Y + r * 1.15f);
                    fill.CenterColor = Color.FromArgb(255, 2, 3, 8);
                    fill.SurroundColors = new[] { Color.FromArgb(255, 18, 34, 66) };
                    g.FillPath(fill, path);
                }
            }
            for (int i = 0; i < 6; i++)     // atmosphere glow
                using (var pen = new Pen(Color.FromArgb(70 - i * 11, 90, 170, 255), 2f + i * 3))
                    g.DrawArc(pen, body.X - i, body.Y - i, body.Width + 2 * i, body.Height + 2 * i, 180, 90);
        }

        private static float Clamp(float v) { return v < 0 ? 0 : v > 1 ? 1 : v; }
        private static float Smooth(float a, float b, float x) { float t = Clamp((x - a) / (b - a)); return t * t * (3 - 2 * t); }
        private static int Byte(float v) { return v < 0 ? 0 : v > 255 ? 255 : (int)v; }

        // Value noise on a hashed lattice, summed over octaves
        private class Noise
        {
            private readonly int[] perm = new int[512];

            public Noise(int seed)
            {
                var rnd = new Random(seed);
                var p = new int[256];
                for (int i = 0; i < 256; i++) p[i] = i;
                for (int i = 255; i > 0; i--) { int j = rnd.Next(i + 1); int t = p[i]; p[i] = p[j]; p[j] = t; }
                for (int i = 0; i < 512; i++) perm[i] = p[i & 255];
            }

            private float Lattice(int x, int y) { return perm[(perm[x & 255] + y) & 511] / 255f; }

            private float Value(float x, float y)
            {
                int xi = (int)Math.Floor(x), yi = (int)Math.Floor(y);
                float fx = x - xi, fy = y - yi;
                fx = fx * fx * (3 - 2 * fx); fy = fy * fy * (3 - 2 * fy);
                float a = Lattice(xi, yi), b = Lattice(xi + 1, yi), c = Lattice(xi, yi + 1), d = Lattice(xi + 1, yi + 1);
                return (a + (b - a) * fx) + ((c + (d - c) * fx) - (a + (b - a) * fx)) * fy;
            }

            public float Fbm(float x, float y, int octaves)
            {
                float sum = 0, amp = 0.5f, norm = 0;
                for (int i = 0; i < octaves; i++)
                {
                    sum += Value(x, y) * amp;
                    norm += amp;
                    x = x * 2.03f + 17.1f; y = y * 2.03f - 9.4f;
                    amp *= 0.5f;
                }
                return sum / norm;
            }
        }
    }
}
