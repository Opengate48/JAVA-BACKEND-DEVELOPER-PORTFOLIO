import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

/**<p>Класс без полей, в котором описан подкласс ReadResult для хранения результата и публичный метод read для чтения файла ввода определенного формата.</p>
 *
 */
public class InputReader {
    /**<p>Класс-контейнер, который хранит результат метода read. Два поля:</p>
     * <p>List<Client> clients - все клиенты;</p>
     * <p>double radius - радиус поиска соседей.</p>
     */
    public static class ReadResult {
        private final List<Client> clients;
        private final double radius;

        public ReadResult(List<Client> clients, double radius) {
            this.clients = clients;
            this.radius = radius;
        }

        public List<Client> getClients() {
            return clients;
        }

        public double getRadius() {
            return radius;
        }
    }

    /**
     * <p>Метод для чтения данных файла input.txt в рабочем катологе программы и только его.
     * Данные в input.txt должны соответсвовать требованиям:</p>
     * <ul>
     *     <li>В первой строке записано 2 числа через пробел - количество клиентов 1 ≤ N ≤ (2^31-1), значение параметра 0 < R ≤ (1.7*10^100);</li>
     *     <li>Начиная со второй строки следует ровно N строк, в которых написано два числа — координаты (-1.7*10^100) < Xi,Yi ≤ (1.7*10^100) i-го клиента.</li>
     * </ul>
     * @return прочитанные данные в формате класса ReadResult
     * @throws IOException
     */
    public ReadResult read(String file) throws IOException {
        List<Client> clients = new ArrayList<>();
        double R;
        try (BufferedReader br = new BufferedReader(new FileReader(file))) {
            String[] firstLine = br.readLine().split(" ");
            if (firstLine.length != 2) {
                throw new IOException("incorrect number of parameters in the first line");
            }
            int N;

            try {
                N = Integer.parseInt(firstLine[0]);
                if (N <= 0) {
                    throw new IOException("N must be positive");
                }
            }
            catch(NumberFormatException e){
                throw new IOException("N must be an integer", e);
            }
            try {
                R = Double.parseDouble(firstLine[1]);
                if (R <= 0) {
                    throw new IOException("R must be positive");
                }
            }
            catch(NumberFormatException e){
                throw new IOException("R must be a number", e);
            }
            for (int i = 0; i < N; i++) {
                String line = br.readLine();
                if (line == null || line.trim().isEmpty()) {
                    throw new IOException("line is missing or there are not enough lines");
                }
                String[] coords = line.split(" ");
                if (coords.length != 2) {
                    throw new IOException("coordinate string must contain exactly two numbers");
                }
                try {
                    double x = Double.parseDouble(coords[0]);
                    double y = Double.parseDouble(coords[1]);
                    clients.add(new Client(i, x, y));
                } catch (NumberFormatException e) {
                    throw new IOException("coordinates must be numbers", e);
                }
            }
        }
        catch (IOException e) {
            throw new IOException("error reading the input file: " + e.getMessage(), e);
        }

        return new ReadResult(clients, R);
    }
}
