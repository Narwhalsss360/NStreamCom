namespace NStreamCom
{
    public class OversizedDataException : NEncodeException
    {
        public OversizedDataException(string message = "", Exception? inner = null)
            : base($"The data is larget than the max allowable size.{(message.Length > 0 ? $" {message}" : "")}", inner)
        { }
    }
}
