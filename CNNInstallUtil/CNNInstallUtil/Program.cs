using System.Runtime.InteropServices;

namespace CNNInstallUtil
{
    class Program
    {
        // Force-allocate a console window. Needed when Inno Setup launches
        // us from its installer context where a console is not attached —
        // without this the user never sees the detection output or errors.
        [DllImport("kernel32.dll", SetLastError = true)]
        [return: MarshalAs(UnmanagedType.Bool)]
        private static extern bool AllocConsole();

        [DllImport("kernel32.dll")]
        private static extern nint GetConsoleWindow();

        static void Main(string[] args)
        {
            if (GetConsoleWindow() == 0)
                AllocConsole();

            var installUtil = new InstallUtil();

            try
            {
                installUtil.Install();
            }
            catch (System.Exception e)
            {
                System.Console.WriteLine("An exception occurred! Cause:\n{0}\nPlease try again!", e.Message);
            }
            finally
            {
                System.Console.WriteLine("\nPress any key to close this window...");
                try { System.Console.ReadKey(); } catch { }
            }
        }
    }
}
