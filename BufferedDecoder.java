package nstreamcom;

import java.util.ArrayList;

public class BufferedDecoder {
    private int _decodedIndex = 0;

    private int _rightShift = 0;

    private final ArrayList<Byte> _bytes = new ArrayList<>();

    public int decodedIndex() {
        return _decodedIndex;
    }

    public byte[] bytes() {
        byte[] bytes = new byte[_bytes.size()];
        for (int i = 0; i < _bytes.size(); i++) {
            bytes[i] = _bytes.get(i);
        }
        return bytes;
    }

    public void reset() {
        _decodedIndex = 0;
        _rightShift = 0;
        _bytes.clear();
    }

    public void next(byte b, boolean isLast) {
        if (!isLast) {
            ensureSize().set(_decodedIndex, (byte)((b >>> _rightShift) & (0xFF >>> _rightShift)));
        }

        if (_rightShift != 0) {
            _bytes.set(_decodedIndex - 1, (byte)(_bytes.get(_decodedIndex - 1) | (byte)(b << (8 -  _rightShift))));
        }

        if (_rightShift == 7) {
            _rightShift = 0;
        } else {
            _rightShift++;
            _decodedIndex++;
        }
    }

    private ArrayList<Byte> ensureSize() {
        while (_bytes.size() <= _decodedIndex) {
            _bytes.add((byte)0);
        }
        return _bytes;
    }
}
