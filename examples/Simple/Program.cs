using NStreamCom;
using System.Diagnostics;
using System.Text;

Console.WriteLine("Enter a string that will get encoded, decoded then printed to the console.");

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

    byte[] decodedBytes = encoded.Decode(); //Decode data

    string decoded = Encoding.UTF8.GetString(decodedBytes);

    Debug.Assert(decoded == line); //Data should be the same.l

    Console.WriteLine(decoded);
}
