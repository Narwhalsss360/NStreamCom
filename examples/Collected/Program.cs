using NStreamCom;
using System.Diagnostics;
using System.Text;

Console.WriteLine("Enter a string that will get encoded, buffer-decoded then printed to the console.");

Collector collector = new();

collector.StateChanged += (sender, e) =>
    Console.WriteLine($"Collector state changed from {e.PreviousState}, to {e.NewState}.");

while (true)
{
    Console.Write('>');
    if (Console.ReadLine() is not string line)
        continue;

    if (line == ".exit")
        break;

    byte[] lineBytes = Encoding.UTF8.GetBytes(line);

    byte[] encoded = lineBytes.EncodeWithSize(); //Encoded size and data

    Debug.Assert(encoded.Length == lineBytes.Length.AsCollectedSize()); //Encoded data (with size) is predetermined by data size.

    //Collect each byte.
    for (int i = 0; i < encoded.Length; i++)
        collector.Collect(encoded[i]);

    if (collector.State != Collector.States.Collected) //Same as collector.DataReady
    {
        Console.WriteLine($"Collector invalid state: {collector.State}");
        continue;
    }

    string decoded = Encoding.UTF8.GetString(collector.Data);

    Debug.Assert(decoded == line); //Data should be the same.l

    Console.WriteLine(decoded);
}
