from typing import Optional
from .sizing import DATA_BITS, as_transmission_size, as_data_size, NSIZE_SIZE, ENCODED_NSIZE_SIZE
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


def encode_size(data_size: int, byteorder: Optional[str] = None) -> bytearray:
    encoded: bytearray = encode(data_size.to_bytes(NSIZE_SIZE, byteorder or 'little'))
    for i in range(ENCODED_NSIZE_SIZE):
        encoded[i] |= 1 << 7
    return encoded


def encode_with_size(data: bytes | bytearray | list[int], size_byteorder: Optional[str] = None) -> bytearray:
    encoded: bytearray = encode_size(len(data), size_byteorder)
    encoded.extend(encode(data))
    return encoded


def decode_size(encoded_size: bytearray | bytes | list[int], byteorder: Optional[str] = None) -> int:
    zeroed_out: bytearray = bytearray()
    for byte in encoded_size:
        zeroed_out.append(byte & ~(1 << 7))
    return int.from_bytes(decode(zeroed_out), byteorder or 'little')
