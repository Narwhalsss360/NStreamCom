using System.Text;
using NStreamCom;

namespace EncodeDecode
{
    public static class Program
    {
        private static int RunTest()
        {
            const string STR = "Lorem ipsum dolor sit amet, consectetur adipiscing nunc";
            byte[] encoded = Encoding.UTF8.GetBytes(STR).Encode();

            if (encoded.Length != Sizing.AsTransmissionSize((uint)STR.Length))
            {
                Console.WriteLine("Encoded/AsTransmissionSize size mismatch.");
                return 1;
            }

            string decoded = Encoding.UTF8.GetString(encoded.Decode());
            if (decoded.Length != Sizing.AsDataSize((uint)encoded.Length) || decoded.Length != STR.Length)
            {
                Console.WriteLine("Data size mismatch.");
                return 2;
            }

            if (decoded != STR)
            {
                Console.WriteLine("Encode/Decode data error.");
                return 3;
            }

            uint dataSize = (uint)STR.Length;
            byte[] encodedSize = dataSize.EncodeSize();
            uint decodedSize = encodedSize.DecodeSize();
            if (decodedSize != dataSize)
            {
                Console.WriteLine("EncodeSize/DecodeSize error.");
                return 4;
            }

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
