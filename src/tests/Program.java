package tests;
import java.nio.charset.StandardCharsets;
import nstreamcom.BufferedDecoder;
import nstreamcom.NEncode;
import nstreamcom.NSize;

public class Program
{
    private static final Test[] TESTS = new Test[]
    {
        new Test() {
            @Override
            public String name() {
                return "Encode-Decode";
            }

            @Override
            public boolean run() {
                String str = "Lorem ipsum.";

                byte[] encodedBytes = NEncode.encode(str.getBytes());
                byte[] decodedBytes = NEncode.decode(encodedBytes);
                String decoded = new String(decodedBytes, StandardCharsets.UTF_8);

                return str.equals(decoded);
            }
        },
        new Test() {
            @Override
            public String name() {
                return "Encode-Decode Size";
            }

            @Override
            public boolean run() {
                long size = 0xBEEF;
                long decoded = NSize.decodeSize(NSize.encodeSize(size));
                return size == decoded;
            }
        },
        new Test() {
            @Override
            public String name() {
                return "BufferedDecoder";
            }

            @Override
            public boolean run() {
                String str = "Lorem ipsum.";

                byte[] encodedBytes = NEncode.encode(str.getBytes());
                BufferedDecoder decoder = new BufferedDecoder();
                for (int i = 0; i < encodedBytes.length; i++) {
                    decoder.next(encodedBytes[i], i == encodedBytes.length - 1);
                }
                String decoded = new String(decoder.bytes(), StandardCharsets.UTF_8);

                return str.equals(decoded);
            }
        }
    };

    public static void main(String[] args) {
        for (Test test : TESTS) {
            System.out.println("Testing: " + test.name());
            if (!test.run()) {
                System.out.println("Failure: " + test.name());
                System.exit(1);
            }
        }
        System.out.println("Success!");
        System.exit(0);
    }
}
