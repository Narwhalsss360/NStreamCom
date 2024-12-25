package nstreamcom;

public class Collector {
    public enum States {

        COLLECTED,
        MISSING_SIZE,
        MISSING_DATA,
        WAITING_SIZE,
        WAITING_DATA;

        private boolean _errorState;

        static {
            COLLECTED._errorState = false;
            MISSING_SIZE._errorState = true;
            MISSING_DATA._errorState = true;
            WAITING_SIZE._errorState = false;
            WAITING_DATA._errorState = false;
        }

        public boolean error() {
            return _errorState;
        }
    }

    private States _state = States.WAITING_SIZE;

    private final BufferedDecoder _decoder = new BufferedDecoder();

    private int _nextSize;

    public States state() {
        return _state;
    }

    public int nextSize() {
        if (_state == States.COLLECTED || _state == States.WAITING_DATA) {
            return _nextSize;
        }
        return 0;
    }

    public byte[] bytes() {
        if (_state == States.COLLECTED) {
            return _decoder.bytes();
        }
        return new byte[0];
    }

    public void reset() {
        _nextSize = 0;
        _decoder.reset();
        _state = States.WAITING_SIZE;
    }

    public States collect(byte b) {
        switch (_state) {
            case COLLECTED:
            case MISSING_SIZE:
            case MISSING_DATA:
                reset();
            case WAITING_SIZE:
                collectSizeByte(b);
                break;
            case WAITING_DATA:
                collectDataByte(b);
                break;
            default:
                break;
        }
        return _state;
    }

    private void collectSizeByte(byte b) {
        if ((b & (1 << 7)) == 0) {
            _state = States.MISSING_SIZE;
            return;
        }

        b &= (byte)~(0xFF << NSize.DATA_BITS);
        boolean last = _decoder.decodedIndex() == NSize.NSIZE_SIZE;
        _decoder.next(b, last);

        if (!last) {
            return;
        }

        _nextSize = (int)NSize.littleUInt32toLong(_decoder.bytes());
        _decoder.reset();
        _state = _nextSize == 0 ? States.COLLECTED : States.WAITING_DATA;
    }

    private void collectDataByte(byte b) {
        if ((b & (1 << 7)) > 0) {
            _state = States.MISSING_SIZE;
            return;
        }

        boolean last = _decoder.decodedIndex() == _nextSize;
        _decoder.next(b, last);

        if (!last) {
            return;
        }

        _state = States.COLLECTED;
    }
}
