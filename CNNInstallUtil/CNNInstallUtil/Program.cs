namespace CNNInstallUtil
{
    class Program
    {
        static void Main(string[] args)
        {
            var installUtil = new InstallUtil();

            try
            {
                installUtil.Install();
            }
            catch (System.Exception e)
            {
                System.Console.WriteLine("An exception occured! Cause:\n{0}\nPlease try again!" + e.Message);
            }
            finally
            {
                System.Console.ReadKey();
            }
        }
    }
}