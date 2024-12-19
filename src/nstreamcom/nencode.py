from .sizing import DATA_BITS, as_transmission_size, as_data_size
from .bits import as_byte


def encode(data: bytes | bytearray | list[int]) -> bytearray:
    encoded: bytearray = bytearray()
    left_shift: int
    previous_stuffed: int
    ratio: int = 0

    for i in range(as_transmission_size(len(data))):
        left_shift = i % 8
        previous_stuffed = 8 - left_shift

        if left_shift == 0:
            encoded.append(as_byte(data[ratio]))
        else:
            encoded.append(as_byte(data[ratio] >> previous_stuffed))
            ratio += 1
            if ratio < len(data):
                encoded[i] |= as_byte(data[ratio] << left_shift)

        encoded[i] &= as_byte(~(0xFF << DATA_BITS))
        
    return encoded


def decode(encoded: bytes | bytearray | list[int]) -> bytearray:
    data: bytearray = bytearray()
    ratio: int = 0
    left_next: int
    for i in range(as_data_size(len(encoded))):
        right_shift = i % DATA_BITS
        left_next = DATA_BITS - right_shift

        if i != 0 and right_shift == 0:
            ratio += 1

        next_data: int = (encoded[ratio] & ~(0xFF << DATA_BITS)) >> right_shift
        data.append(as_byte(next_data))
        ratio += 1

        if ratio < len(encoded):
            data[i] |= as_byte(((encoded[ratio] & ~(0xFF << DATA_BITS)) << left_next))

    return data

