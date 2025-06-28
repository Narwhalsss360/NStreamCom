from nstreamcom import encode_with_size, Collector, CollectorStates


def main() -> None:
    test_bstrings: list[bytes] = [
        b'',
        b'ABC',
        b'1234567',
        b'12345678'
    ]

    collector: Collector = Collector()

    for bstring in test_bstrings:
        encoded: bytearray = encode_with_size(bstring)
        for byte in encoded:
            collector.collect(byte)
            assert collector.state != CollectorStates.MissingData
            assert collector.state != CollectorStates.MissingSize
            assert not (collector.size_ready and collector.error_state)
        assert collector.state == CollectorStates.Collected
        assert not collector.error_state
        assert collector.size_ready
        assert collector.bytearray == bstring
        collector.reset()

    print('Success!')


if __name__ == '__main__':
    main()
