using NStreamCom;
using System.Diagnostics;
using System.Text;

Console.WriteLine("Enter a string that will get encoded, buffer-decoded then printed to the console.");

BufferedDecoder decoder = new();

while (true)
{
    Console.Write('>');
    if (Console.ReadLine() is not string line)
        continue;

    if (line == ".exit")
        break;

    byte[] lineBytes = Encoding.UTF8.GetBytes(line);

    byte[] encoded = lineBytes.Encode(); //Encode data

    Debug.Assert(encoded.Length == lineBytes.Length.AsTransmissionSize()); //Encoded data is predetermined by data size.

    //Next byte, for each byte, and whether or not is last
    //Since you need to know whether this is the last byte, from the encoded data, which is when DecodedIndex == data.length
    for (int i = 0; i < encoded.Length; i++)
        decoder.Next(encoded[i], decoder.DecodedIndex == lineBytes.Length);

    string decoded = Encoding.UTF8.GetString(decoder.Bytes);

    Debug.Assert(decoded == line); //Data should be the same.l
    decoder.Reset(); //Reset for next line.

    Console.WriteLine(decoded);
}
