namespace NStreamCom
{
    public static class Sizing
    {
        public static readonly uint STUFFED_BITS = 1;

        public static readonly uint DATA_BITS = 8 - STUFFED_BITS;

        public static readonly uint MAX_DATA_SIZE = uint.MaxValue * DATA_BITS / 8;

        public static readonly uint ENCODED_NSIZE_SIZE = ((sizeof(uint) * 8) + DATA_BITS - 1) / DATA_BITS;

        public static uint AsTransmissionSize(this uint dataSize) => ((dataSize * 8) + DATA_BITS - 1) / DATA_BITS;

        public static int AsTransmissionSize(this int dataSize) => (int)AsTransmissionSize((uint)dataSize);

        public static uint AsDataSize(this uint transmissionSize) => transmissionSize * DATA_BITS / 8;

        public static int AsDataSize(this int transmissionSize) => (int)AsDataSize((uint)transmissionSize);

        public static byte[] EncodeSize(this uint size)
        {
            byte[] encoded = BitConverter.GetBytes(size).Encode();
            for (int i = 0; i < encoded.Length; i++)
                encoded[i] |= (byte)(1 << (byte)DATA_BITS);
            return encoded;
        }

        public static byte[] EncodeSize(this int size) => EncodeSize((uint)size);

        public static uint DecodeSize(this byte[] encoded)
        {
            for (int i = 0; i < encoded.Length; i++)
                encoded[i] &= (byte)~(1 << (byte)DATA_BITS);
            return BitConverter.ToUInt32(encoded.Decode());
        }
    }
}
