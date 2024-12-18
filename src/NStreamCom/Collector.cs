using static NStreamCom.Collector;

namespace NStreamCom
{
    public class Collector
    {
        public enum States
        {
            Collected,
            MissingSize,
            MissingData,
            WaitingSize,
            WaitingData
        }

        public class StateChangedEventArgs(States previousState, States newState) : EventArgs
        {
            public readonly States PreviousState = previousState;

            public readonly States NewState = newState;
        }

        public delegate void StateChangedEventHandler(object? sender, StateChangedEventArgs e);

        public States State { get; private set; } = States.WaitingSize;

        public bool SizeReady { get => State == States.WaitingData; }

        public bool DataReady { get => State == States.Collected; }

        public uint Size
        {
            get
            {
                if (!SizeReady)
                    throw new InvalidOperationException("Size is not ready.");
                return _nextSize;
            }
        }

        public byte[] Data
        {
            get
            {
                if (!DataReady)
                    throw new InvalidOperationException("Data is not ready.");
                return _decoder.Bytes;
            }
        }

        public event StateChangedEventHandler? StateChanged;

        private readonly BufferedDecoder _decoder = new();

        private uint _nextSize = 0;

        private States _previousState = States.WaitingSize;

        public void Reset()
        {
            _nextSize = 0;
            _decoder.Reset();
            State = States.WaitingSize;
        }

        public States Collect(byte b)
        {
            switch (State)
            {
                case States.Collected:
                case States.MissingSize:
                case States.MissingData:
                    Reset();
                    Collect(b);
                    break;
                case States.WaitingSize:
                    CollectSizeByte(b);
                    break;
                case States.WaitingData:
                    CollectDataByte(b);
                    break;
                default:
                    break;
            }

            if (_previousState != State)
            {
                StateChanged?.Invoke(this, new(_previousState, State));
                _previousState = State;
            }

            return State;
        }

        private void CollectSizeByte(byte b)
        {
            if ((b & (1 << 7)) == 0)
            {
                State = States.MissingSize;
                return;
            }

            b &= (byte)~(0xFF << (byte)Sizing.DATA_BITS);
            bool last = _decoder.DecodedIndex == sizeof(uint);
            _decoder.Next(b , last);

            if (!last)
                return;

            _nextSize = BitConverter.ToUInt32(_decoder.Bytes);
            _decoder.Reset();
            State = _nextSize == 0 ? States.Collected : States.WaitingData;
        }

        private void CollectDataByte(byte b)
        {
            if ((b & 0b10000000) > 0)
            {
                State = States.MissingData;
                return;
            }

            bool last = _decoder.DecodedIndex == _nextSize;
            _decoder.Next(b , last);

            if (!last)
                return;

            State = States.Collected;
        }
    }

    public static class StatesExtensions
    {
        public static bool ErrorState(this States state) => state == States.MissingSize || state == States.MissingData;
    }
}
