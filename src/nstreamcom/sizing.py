import math


NSIZE_SIZE: int = 4
STUFFED_BITS: int = 1
DATA_BITS: int = 8 - STUFFED_BITS
MAX_DATA_SIZE: int = pow(2, NSIZE_SIZE * 8) * DATA_BITS / 8
ENCODED_NSIZE_SIZE: int = math.ceil(NSIZE_SIZE * 8 / DATA_BITS)


def as_transmission_size(data_size: int) -> int:
    return math.ceil(data_size * 8 / DATA_BITS)


def as_collected_size(data_size: int) -> int:
    return as_transmission_size(data_size) + ENCODED_NSIZE_SIZE


def as_data_size(encoded_size: int) -> int:
    return encoded_size * DATA_BITS // 8

