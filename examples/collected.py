from nstreamcom import encode_with_size, Collector, CollectorStates, as_collected_size

ENCODING: str = 'utf-8'

collector: Collector = Collector()
while True:
    line: str = input('>')
    if line == '.exit':
        break

    line_bytes: bytes = bytes(line, ENCODING)

    # Encode with size requried for receiver using Collector
    encoded_line_and_size_bytes: bytearray = encode_with_size(line_bytes)
    assert len(encoded_line_and_size_bytes) == as_collected_size(len(line_bytes))

    for byte in encoded_line_and_size_bytes:
        collector.collect(byte)
        if collector.state in (CollectorStates.MissingSize, CollectorStates.MissingData):
            print(f'Collector error state: {collector.state}.')
            break

    if not collector.data_ready:
        print('Collection failed.')
        continue

    decoded_line_bytes: bytearray = collector.bytearray
    assert len(line_bytes) == collector.next_size

    decoded_line: str = str(decoded_line_bytes, ENCODING)
    print(decoded_line)
    # Collector automatically resets to get ready for next size and data
    # collector.reset()
