from nstreamcom import encode, BufferedDecoder, as_data_size

ENCODING: str = 'utf-8'

decoder: BufferedDecoder = BufferedDecoder()
while True:
    line: str = input('>')
    if line == '.exit':
        break

    line_bytes: bytes = bytes(line, ENCODING)

    encoded_line_bytes: bytearray = encode(line_bytes)

    for i, byte in enumerate(encoded_line_bytes):
        # Decode next byte, and tell whether or not it is the last byte
        decoder.next(byte, decoder.decoded_index == len(line_bytes))

        # Then length of the decoder's buffer is decoded_index, unless it is the last byte.
        # The decode operation focuses on the previous byte, which is why that is the case.

    decoded_line_bytes: bytearray = decoder.bytearray
    assert len(line_bytes) == as_data_size(len(encoded_line_bytes))

    decoded_line: str = str(decoded_line_bytes, ENCODING)
    print(decoded_line)
    # Reset to get ready for next data
    decoder.reset()
