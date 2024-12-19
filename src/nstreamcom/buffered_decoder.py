from .bits import as_byte


class BufferedDecoder:
    def __init__(self):
        self._decoded_index: int = 0
        self._buffer: bytearray = bytearray()
        self._right_shift: int = 0

    def reset(self) -> None:
        self._decoded_index = 0
        self._right_shift = 0
        self._buffer.clear()

    @property
    def decoded_index(self) -> int:
        return self._decoded_index

    @property
    def bytearray(self) -> bytearray:
        return self._buffer

    def next(self, byte: int, is_last: bool) -> None:
        if not is_last:
            self._ensure_size[self._decoded_index] = as_byte(byte >> self._right_shift)

        if self._right_shift != 0:
            self._buffer[self._decoded_index - 1] |= as_byte(byte << (8 - self._right_shift))

        if self._right_shift == 7:
            self._right_shift = 0
        else:
            self._right_shift += 1
            self._decoded_index += 1

    @property
    def _ensure_size(self) -> bytearray:
        while len(self._buffer) <= self._decoded_index:
            self._buffer.append(0)
        return self._buffer
