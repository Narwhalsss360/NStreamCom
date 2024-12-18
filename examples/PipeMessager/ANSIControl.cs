namespace PipeMessager
{
    public static class ANSIControl
    {
        private static readonly string CSI = "\x1B[";

        private static readonly string SAVE_CURRENT_CURSOR_POSITION = "s";

        private static readonly string CURSOR_DOWN = "B";

        private static readonly string INSERT_NEW_LINE_ABOVE = "L";

        private static readonly string RESTORE_SAVED_CURRENT_CURSOR_POSITION = "u";

        public static void WriteAbove(string str)
        {
            if (str.EndsWith('\n'))
                str.Remove(str.Length - 1, 1);
            int lineCount = str.Count(ch => ch == '\n') + 1;
            WriteANSI(SAVE_CURRENT_CURSOR_POSITION);
            WriteANSI(INSERT_NEW_LINE_ABOVE, lineCount);
            Console.Write(str);
            WriteANSI(RESTORE_SAVED_CURRENT_CURSOR_POSITION);
            WriteANSI(CURSOR_DOWN, lineCount);
        }

        public static void WriteANSI(string ansi, int repeat = 1)
        {
            for (int i = 0; i < repeat; i++)
            {
                Console.Out.Write($"{CSI}{ansi}");
                Console.Out.Flush();
            }
        }
    }
}
