using NStreamCom;
using System.IO.Pipes;
using System.Text;

namespace PipeMessager
{
    public static class Program
    {
        static readonly string PIPE_NAME = "PipeMessager";

        static readonly int PIPE_BUFFER_SIZE = 512;

        static PipeStream? stream;

        static void Connect()
        {
            try
            {
                NamedPipeServerStream server = new
                (
                    PIPE_NAME,
                    PipeDirection.InOut,
                    1,
                    PipeTransmissionMode.Byte,
                    PipeOptions.FirstPipeInstance | PipeOptions.Asynchronous,
                    PIPE_BUFFER_SIZE,
                    PIPE_BUFFER_SIZE
                );

                server.WaitForConnection();
                stream = server;
            }
            catch (Exception)
            {
                NamedPipeClientStream client = new(".", PIPE_NAME, PipeDirection.InOut, PipeOptions.Asynchronous);
                client.Connect();
                stream = client;
            }
        }

        public static void Main(string[] args)
        {
            Collector collector = new();
            collector.StateChanged += (sender, e) =>
            {
                if (e.NewState.ErrorState())
                {
                    Console.WriteLine($"Collector error: {e.NewState}");
                    return;
                }

                if (e.NewState != Collector.States.Collected)
                    return;

                ANSIControl.WriteAbove(Encoding.UTF8.GetString(collector.Data));
            };

            Thread writer = new(WriteLoop);
            Console.WriteLine("Connecting...");
            Connect();

            if (stream is null)
                return;

            writer.Start();
            if (stream is NamedPipeServerStream)
                Console.WriteLine("Serving");
            else
                Console.WriteLine("Client");

            while (stream.IsConnected)
            {
                int read = stream.ReadByte();
                if (read == -1)
                {
                    Thread.Sleep(3);
                    continue;
                }

                collector.Collect((byte)read);
            }
            stream.Close();
            writer.Join();
        }

        static async Task<string?> ReadLineAsync() => await Task.Run(Console.ReadLine);

        static void SingleWrite()
        {
            if (stream is null)
                return;

            Console.Write('>');
            Task<string?> read = ReadLineAsync();
            while (!read.IsCompleted)
                if (!stream.IsConnected)
                    break;

            if (!stream.IsConnected)
            {
                Console.WriteLine("\n====The pipe has been closed. Press enter to exit.====");
                Console.ReadLine();
                return;
            }

            if (read.Result is not string line)
                return;

            if (line == ".exit")
            {
                stream.Close();
                return;
            }

            stream.Write(Encoding.UTF8.GetBytes(line).EncodeWithSize());
        }

        static void WriteLoop()
        {
            while (stream?.IsConnected ?? false)
                SingleWrite();
        }
    }
}
