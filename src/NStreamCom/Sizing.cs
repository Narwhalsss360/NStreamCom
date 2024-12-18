namespace NStreamCom
{
    public static class Sizing
    {
        public static readonly uint STUFFED_BITS = 1;

        public static readonly uint DATA_BITS = 8 - STUFFED_BITS;

        public static readonly uint MAX_DATA_SIZE = uint.MaxValue * DATA_BITS / 8;

        public static uint AsTransmissionSize(this uint dataSize) => ((dataSize * 8) + DATA_BITS - 1) / DATA_BITS;

        public static int AsTransmissionSize(this int dataSize) => (int)AsTransmissionSize((uint)dataSize);

        public static uint AsDataSize(this uint transmissionSize) => transmissionSize * DATA_BITS / 8;

        public static int AsDataSize(this int transmissionSize) => (int)AsDataSize((uint)transmissionSize);
    }
}
