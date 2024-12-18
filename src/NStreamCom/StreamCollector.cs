namespace NStreamCom
{
    public class StreamCollector(Collector? collector = null) : Stream
    {
        public override bool CanRead => false;

        public override bool CanSeek => false;

        public override bool CanWrite => true;

        public override long Length => Collector.DataReady ? Collector.Size : 0;

        public override long Position { get => throw new NotSupportedException(); set => throw new NotSupportedException(); }

        public Collector Collector { get; set; } = collector ?? new();

        public bool BreakOnCollectorErrorState { get; set; } = true;

        public override void Flush()
        { }

        public override int Read(byte[] buffer, int offset, int count)
        {
            throw new NotSupportedException();
        }

        public override long Seek(long offset, SeekOrigin origin)
        {
            throw new NotSupportedException();
        }

        public override void SetLength(long value)
        {
            throw new NotSupportedException();
        }

        public override void Write(byte[] buffer, int offset, int count)
        {
            for (int i = 0; i < count; i++)
                if (Collector.Collect(buffer[i + offset]).ErrorState() && BreakOnCollectorErrorState)
                    break;
        }
    }
}
