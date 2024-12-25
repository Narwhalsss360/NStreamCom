package tests;
import java.nio.charset.StandardCharsets;
import nstreamcom.NEncode;

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
        }
    };

    public static void main(String[] args) {
        for (Test test : TESTS) {
            if (!test.run()) {
                System.out.println("Failure: " + test.name());
                System.exit(1);
            }
        }
        System.out.println("Success!");
        System.exit(0);
    }
}
