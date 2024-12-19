from nstreamcom import encode, decode, as_transmission_size, as_data_size

ENCODING: str = 'utf-8'

while True:
    line: str = input('>')
    if line == '.exit':
        break

    line_bytes: bytes = bytes(line, ENCODING)

    encoded_line_bytes: bytearray = encode(line_bytes)
    # To know the length of encoded bytes, use `as_transmission_size`
    assert len(encoded_line_bytes) == as_transmission_size(len(line_bytes))


    decoded_line_bytes: bytearray = decode(encoded_line_bytes)
    # If you don't know legth of data but you do know length of encoded, use `as_data_size`
    assert len(line_bytes) == as_data_size(len(encoded_line_bytes))

    decoded_line: str = str(decoded_line_bytes, ENCODING)
    print(decoded_line)
