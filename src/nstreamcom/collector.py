import enum
from .sizing import DATA_BITS, NSIZE_SIZE
from .buffered_decoder import BufferedDecoder


class CollectorStates(enum.Enum):
    Collected = 0,
    MissingSize = 1,
    MissingData = 2,
    WaitingSize = 3,
    WaitingData = 4


class Collector:
    def __init__(self) -> None:
        self._state: CollectorStates = CollectorStates.WaitingSize
        self._next_size: int = 0
        self._decoder: BufferedDecoder = BufferedDecoder()

    @property
    def state(self) -> CollectorStates:
        return self._state

    @property
    def size_ready(self) -> bool:
        return self._state == CollectorStates.WaitingData or self._state == CollectorStates.Collected

    @property
    def data_ready(self) -> bool:
        return self._state == CollectorStates.Collected

    @property
    def next_size(self) -> int:
        if self.size_ready:
            return self._next_size
        return 0

    @property
    def bytearray(self) -> bytearray:
        if self.data_ready:
            return self._decoder.bytearray
        return bytearray()

    def reset(self) -> None:
        self._next_size = 0
        self._decoder.reset()
        self._state = CollectorStates.WaitingSize

    def collect(self, byte: int) -> CollectorStates:
        match self._state:
            case CollectorStates.Collected:
                self.reset()
                self.collect(byte)
            case CollectorStates.MissingSize:
                self.reset()
                self.collect(byte)
            case CollectorStates.MissingData:
                self.reset()
                self.collect(byte)
            case CollectorStates.WaitingSize:
                self._collect_size_byte(byte)
            case CollectorStates.WaitingData:
                self._collect_data_byte(byte)

        return self._state

    def _collect_size_byte(self, byte: int) -> None:
        if byte & (1 << 7) == 0:
            self._state = CollectorStates.MissingSize
            return

        byte &= ~(0xFF << DATA_BITS)
        last: bool = self._decoder._decoded_index == NSIZE_SIZE
        self._decoder.next(byte , last)

        if not last:
            return

        self._next_size = int.from_bytes(self._decoder.bytearray, 'little')
        self._decoder.reset()
        self._state = CollectorStates.WaitingData if self._next_size else CollectorStates.Collected

    def _collect_data_byte(self, byte: int) -> None:
        if (byte & 1 << 7) > 0:
            self._state = CollectorStates.MissingData
            return

        last: bool = self._decoder.decoded_index == self._next_size
        self._decoder.next(byte, last)

        if not last:
            return

        self._state = CollectorStates.Collected
