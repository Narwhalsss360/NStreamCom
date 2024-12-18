namespace NStreamCom
{
    public class BufferedDecoder
    {
        private static readonly int BUFFER_CLEAR_SIZE = 512;

        public int DecodedIndex { get; private set; } = 0;

        public byte[] Bytes { get => [.. _bytes]; }

        private readonly List<byte> _bytes = [];

        private byte _rightShift = 0;

        public void Reset()
        {
            DecodedIndex = 0;
            _rightShift = 0;
            if (BUFFER_CLEAR_SIZE <= _bytes.Count)
                _bytes.Clear();
        }

        public void Next(byte b, bool isLast)
        {
            if (!isLast)
                EnsureSize()[DecodedIndex] = (byte)(b >> _rightShift);

            if (_rightShift != 0)
                _bytes[DecodedIndex - 1] |= (byte)(b << (8 -  _rightShift));

            if (_rightShift == 7)
            {
                _rightShift = 0;
            }
            else
            {
                _rightShift++;
                DecodedIndex++;
            }
        }

        private List<byte> EnsureSize()
        {
            while (_bytes.Count <= DecodedIndex)
                _bytes.Add(0);
            return _bytes;
        }
    }
}
