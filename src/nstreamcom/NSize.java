package nstreamcom;

public class NSize {
    public static final long NSIZE_SIZE = 4;

    public static final long UINT32_MAX = 0xFFFFFFFFL;

    public static final long STUFFED_BITS = 1;

    public static final long DATA_BITS = 8 - STUFFED_BITS;

    public static final long MAX_DATA_SIZE = UINT32_MAX * DATA_BITS / 8;

    public static final long ENCODED_NSIZE_SIZE = ((NSIZE_SIZE * 8) + DATA_BITS - 1) / DATA_BITS;

    public static long asTransmissonSize(long dataSize) {
        return ((dataSize * 8) + DATA_BITS + 1) / DATA_BITS;
    }

    public static int asTransmissonSize(int dataSize) {
        return (int)asTransmissonSize((long)dataSize);
    }

    public static long asDataSize(long transmissionSize) {
        return transmissionSize * DATA_BITS / 8;
    }

    public static int asDataSize(int transmissionSize) {
        return (int)asDataSize((long)transmissionSize);
    }

    public static long asCollectedSize(long dataSize) {
        return asTransmissonSize(dataSize) + ENCODED_NSIZE_SIZE;
    }

    public static int asCollectedSize(int dataSize) {
        return (int)asCollectedSize((long)dataSize);
    }
}
