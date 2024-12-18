using NStreamCom;
using System.Text;

namespace StreamCollector
{
    public static class Program
    {
        private static int RunTest(bool first = false, NStreamCom.StreamCollector? collectorStream = null)
        {
            collectorStream ??= new();

            const string STR = "Lorem ipsum dolor sit amet, consectetur adipiscing nunc";
            byte[] encoded = Encoding.UTF8.GetBytes(STR).EncodeWithSize();

            if (encoded.Length != STR.Length.AsCollectedSize())
            {
                Console.WriteLine("Data as collected size encoded mismatch.");
                return 1;
            }

            collectorStream.Write(encoded);

            if (!collectorStream.Collector.DataReady)
            {
                Console.WriteLine($"Collector data not ready; {collectorStream.Collector.State}.");
                return 2;
            }

            string decoded = Encoding.UTF8.GetString(collectorStream.Collector.Data);
            if (decoded.Length != STR.Length)
            {
                Console.WriteLine($"first={first}:Data size mismatch.");
                return 3;
            }

            if (decoded != STR)
            {
                Console.WriteLine($"first={first}:Encode/Decode data error.");
                return 4;
            }

            collectorStream.Collector.Reset();
            if (first)
                return RunTest(false, collectorStream);

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
