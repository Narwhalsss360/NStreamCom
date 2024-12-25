package nstreamcom;

public class NEncode {
    public static byte[] encode(byte[] data) {
        if (data.length > NSize.MAX_DATA_SIZE) {
            return new byte[0];
        }

        byte[] encoded = new byte[NSize.asTransmissonSize(data.length)];
        int ratio = 0;
        byte leftShift, previousStuffed;
        for (int i = 0; i < encoded.length; i++)
        {
            leftShift = (byte)(i % 8);
            previousStuffed = (byte)(8 - leftShift);

            if (leftShift == 0)
            {
                encoded[i] = data[ratio];
            }
            else
            {
                encoded[i] = (byte)(data[ratio] >> previousStuffed);
                ratio++;
                if (ratio < data.length)
                    encoded[i] |= (byte)((data[ratio] << leftShift));
            }

            encoded[i] &= (byte)~(0xFF << (byte)NSize.DATA_BITS);
        }

        return encoded;
    }

    public static byte[] decode(byte[] encoded) {
        byte[] data = new byte[NSize.asDataSize(encoded.length)];

        int ratio = 0;
        byte leftNext;

        for (int i = 0; i < data.length; i++)
        {
            byte rightShift = (byte)(i % NSize.DATA_BITS);
            leftNext = (byte)(NSize.DATA_BITS - rightShift);

            if (i != 0 && rightShift == 0)
                ratio++;

            data[i] = (byte)((encoded[ratio] & (byte)~(0xFF << (byte)NSize.DATA_BITS)) >> rightShift);

            ratio++;
            if (ratio < encoded.length)
                data[i] |= (byte)((encoded[ratio] & (byte)~(0xFF << (byte)NSize.DATA_BITS)) << leftNext);
        }

        return data;
    }
}
