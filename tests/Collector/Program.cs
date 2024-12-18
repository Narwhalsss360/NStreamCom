using NStreamCom;
using System.Text;

namespace Collector
{
    public static class Program
    {
        private static int RunTest(bool first = false, NStreamCom.Collector? collector = null)
        {
            collector ??= new();

            const string STR = "Lorem ipsum dolor sit amet, consectetur adipiscing nunc";
            byte[] encoded = Encoding.UTF8.GetBytes(STR).EncodeWithSize();

            if (encoded.Length != STR.Length.AsCollectedSize())
            {
                Console.WriteLine("Data as collected size encoded mismatch.");
                return 1;
            }

            foreach (byte b in encoded)
            {
                collector.Collect(b);
                if (collector.State == NStreamCom.Collector.States.MissingSize)
                {
                    Console.WriteLine("Collector error state MissingSize");
                    return 2;
                }
                else if (collector.State == NStreamCom.Collector.States.MissingData)
                {
                    Console.WriteLine("Collector error state MissingData");
                    return 2;
                }
            }

            if (!collector.DataReady)
            {
                Console.WriteLine("Collector data not ready.");
                return 3;
            }

            string decoded = Encoding.UTF8.GetString(collector.Data);
            if (decoded.Length != STR.Length)
            {
                Console.WriteLine($"first={first}:Data size mismatch.");
                return 4;
            }

            if (decoded != STR)
            {
                Console.WriteLine($"first={first}:Encode/Decode data error.");
                return 5;
            }

            collector.Reset();
            if (first)
                return RunTest(false, collector);

            return 0;
        }

        public static void Main()
        {
            int code = RunTest();
            if (code != 0)
                Console.WriteLine($"Exit code: {code}");
            else
                Console.WriteLine("Success!");
            Environment.Exit(code);
        }
    }
}
