namespace NStreamCom
{
    public static class NEncode
    {
        public static byte[] Encode(this byte[] data)
        {
            if (data.Length > Sizing.MAX_DATA_SIZE)
                throw new OversizedDataException($"{Encode}; ${nameof(data)} is too large.");

            byte[] encoded = new byte[data.Length.AsTransmissionSize()];
            uint ratio = 0;
            byte leftShift, previousStuffed;
            for (uint i = 0; i < encoded.Length; i++)
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
                    if (ratio < data.Length)
                        encoded[i] |= (byte)((data[ratio] << leftShift));
                }

                encoded[i] &= (byte)~(0xFF << (byte)Sizing.DATA_BITS);
            }

            return encoded;
        }

        public static byte[] Decode(this byte[] encoded)
        {
            byte[] data = new byte[encoded.Length.AsDataSize()];

            uint ratio = 0;
            byte leftNext;

            for (uint i = 0; i < data.Length; i++)
            {
                byte rightShift = (byte)(i % Sizing.DATA_BITS);
                leftNext = (byte)(Sizing.DATA_BITS - rightShift);

                if (i != 0 && rightShift == 0)
                    ratio++;

                data[i] = (byte)((encoded[ratio] & (byte)~(0xFF << (byte)Sizing.DATA_BITS)) >> rightShift);

                ratio++;
                if (ratio < encoded.Length)
                    data[i] |= (byte)((encoded[ratio] & (byte)~(0xFF << (byte)Sizing.DATA_BITS)) << leftNext);
            }

            return data;
        }
    }
}
