using NStreamCom;
using System.Diagnostics;
using System.Text;

Console.WriteLine("Enter a string that will get encoded, buffer-decoded then printed to the console.");

StreamCollector stream = new()
{
    BreakOnCollectorErrorState = true
};
//BreakOnCollectorErrorState: Default true.
//If there's a buffer being written, and a byte in the middle of the buffer
//gives an error collector state, then no more bytes would be collected from that buffer, the next
//call to write will collect.

stream.Collector.StateChanged += (sender, e) =>
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

    //This stream collects all the bytes written to the stream.
    stream.Write(encoded);

    if (!stream.Collector.DataReady) 
    {
        Console.WriteLine($"Collector invalid state: {stream.Collector.State}");
        continue;
    }

    string decoded = Encoding.UTF8.GetString(stream.Collector.Data);

    Debug.Assert(decoded == line); //Data should be the same.l

    Console.WriteLine(decoded);
}
