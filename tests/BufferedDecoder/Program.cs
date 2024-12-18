using NStreamCom;
using System.Text;

namespace BufferedDecoder
{
    public static class Program
    {
        private static int RunTest(bool first = false, NStreamCom.BufferedDecoder? decoder = null)
        {
            decoder ??= new();

            const string STR = "Lorem ipsum dolor sit amet, consectetur adipiscing nunc";
            byte[] encoded = Encoding.UTF8.GetBytes(STR).Encode();

            for (int i = 0; i < encoded.Length; i++)
                decoder.Next(encoded[i], i == encoded.Length - 1);

            string decoded = Encoding.UTF8.GetString(decoder.Bytes);
            if (decoded.Length != Sizing.AsDataSize((uint)encoded.Length) || decoded.Length != STR.Length)
            {
                Console.WriteLine($"first={first}:Data size mismatch.");
                return 1;
            }

            if (decoded != STR)
            {
                Console.WriteLine($"first={first}:Encode/Decode data error.");
                return 2;
            }

            decoder.Reset();
            if (first)
                return RunTest(false, decoder);

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
