import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;

class TaxiStationTest {

    @Test
    void testFirstInputCase(@TempDir Path tempDir) throws IOException {

        String input = """
            5 3
            0 0
            2 -2
            5 3
            -2 2
            5 1""";
        Path inputFile = tempDir.resolve("input.txt");
        Files.writeString(inputFile, input);


        String expectedOutput = """
            0 2
            1 1
            2 1
            3 1
            4 1""";


        InputReader reader = new InputReader();
        OutputWriter writer = new OutputWriter();
        Path outputFile = tempDir.resolve("output.txt");

        InputReader.ReadResult result = reader.read(inputFile.toString());
        List<Station> solution = new StationMaster().getSimpleSolution(result.getClients(), result.getRadius());
        writer.write(solution, outputFile.toString());


        String actualOutput = Files.readString(outputFile)
                .replace("\r", "")
                .trim();

        String normalizedExpected = expectedOutput
                .replace("\r", "")
                .trim();

        assertEquals(normalizedExpected, actualOutput);
    }

    @Test
    void testSecondInputCase(@TempDir Path tempDir) throws IOException {

        String input = """
            10 3.000000
            3.168070 1.752490
            0.500730 6.436580
            0.089300 0.112720
            2.275440 7.508780
            0.779230 4.377090
            0.644400 1.381650
            1.844920 1.430420
            8.079870 5.225030
            7.823270 5.317290
            1.788400 5.426120""";
        Path inputFile = tempDir.resolve("input.txt");
        Files.writeString(inputFile, input);


        String expectedOutput = """
            5 4
            1 3
            4 3
            6 3
            9 3
            0 2
            2 2
            3 2
            7 1
            8 1""";


        InputReader reader = new InputReader();
        OutputWriter writer = new OutputWriter();
        Path outputFile = tempDir.resolve("output.txt");

        InputReader.ReadResult result = reader.read(inputFile.toString());
        List<Station> solution = new StationMaster().getSimpleSolution(result.getClients(), result.getRadius());
        writer.write(solution, outputFile.toString());

        String actualOutput = Files.readString(outputFile)
                .replace("\r", "")
                .trim();

        String normalizedExpected = expectedOutput
                .replace("\r", "")
                .trim();

        assertEquals(normalizedExpected, actualOutput);
    }
}
