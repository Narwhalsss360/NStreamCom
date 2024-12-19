from nstreamcom import encode, decode, as_transmission_size, as_data_size


def main():
    data: bytes = b'Hello, World!'

    encoded: bytearray = encode(data)

    assert len(encoded) == as_transmission_size(len(data))

    decoded: bytearray = decode(encoded)

    assert len(decoded) == len(data) == as_data_size(len(encoded))

    assert data == bytes(decoded)
    print('Success!')


if __name__ == '__main__':
    main()

