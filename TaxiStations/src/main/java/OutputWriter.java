import java.io.IOException;
import java.io.PrintWriter;
import java.lang.Iterable;

/**
 * <p>Класс без полей, содержащий единственный публичный метод write</p>
 */
public class OutputWriter {
    /**
     * <p>Метод для распечатывания элементов коллекции.</p>
     * @param items коллекция для печати
     * @param file файл для печати
     * @throws IOException
     * @throws IllegalArgumentException
     */
    public void write(Iterable<?> items, String file) throws IOException, IllegalArgumentException {
        if (items == null) {
            throw new IllegalArgumentException("items cannot be null");
        }
        try (PrintWriter pw = new PrintWriter(file)) {
            for (Object item : items) {
                pw.println(item.toString());
            }
        } catch (IOException e) {
            throw new IOException("error writing to the output file: " + e.getMessage(), e);
        }
    }
}
