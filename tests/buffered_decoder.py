from nstreamcom import encode, BufferedDecoder


def main() -> None:
    test_bstrings: list[bytes] = [
        b'',
        b'ABC',
        b'1234567',
        b'12345678'
    ]

    decoder: BufferedDecoder = BufferedDecoder()
    for bstring in test_bstrings:
        encoded: bytearray = encode(bstring)
        for i, byte in enumerate(encoded):
            decoder.next(byte, i == len(encoded) - 1)

        assert bytes(decoder.bytearray) == bstring, f'{bstring}:{bytes(decoder.bytearray)}'
        decoder.reset()
    print('Success!')


if __name__ == '__main__':
    main()
