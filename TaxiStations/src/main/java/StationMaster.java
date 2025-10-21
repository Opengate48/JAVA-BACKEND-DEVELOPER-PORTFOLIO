import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * <p>Класс без полей с единственным публичным методом getSimpleSolution, который формирует решение задачи</p>
 */
public class StationMaster {
    /**
     * <p>Решает поставленную задачу.</p>
     * <p><b>Важно</b></p>
     * <p>Алгоритм не ищет такие позиции для станций, которые обеспечивают максимальное покрытие всех станций в совокупности. Алгоритм лишь ищет топ-10 позиций, на которых каждая станция покрывает максимально возможное клличество клиентов. Т.е., в результате может получиться множество позиций для станций, в котором станции покрывают клиентов, которые были уже покрыты другими станциями. Такой алгоритм обусловлен примерами из ТЗ.</p>
     * <p>Н-р, содержимое input.txt из примеров:</p>
     * <p>10 3.000000</p>
     * <p>3.168070 1.752490</p>
     * <p>0.500730 6.436580</p>
     * <p>0.089300 0.112720</p>
     * <p>2.275440 7.508780</p>
     * <p>0.779230 4.377090</p>
     * <p>0.644400 1.381650</p>
     * <p>1.844920 1.430420</p>
     * <p>8.079870 5.225030</p>
     * <p>7.823270 5.317290</p>
     * <p>1.788400 5.426120</p>
     * <p>Содержимое output.txt из примеров</p>
     * <p>5 4</p>
     * <p>1 3</p>
     * <p>4 3</p>
     * <p>6 3</p>
     * <p>9 3</p>
     * <p>0 2</p>
     * <p>2 2</p>
     * <p>3 2</p>
     * <p>7 1</p>
     * <p>8 1</p>
     * <p>Тут можно было обойтись всего тремя станциями, которые покрывали бы всех клиентов, но использовали все 10 станций.</p>
     * @param clients список клиентов
     * @param R радиус поиска
     * @return список станций ArrayList, который представляет собой решение задачи
     * @throws IllegalArgumentException
     * @throws NullPointerException
     */
    public List<Station> getSimpleSolution(List<Client> clients, double R) throws IllegalArgumentException, NullPointerException {
        if (clients == null) {
            throw new NullPointerException("clients cannot be null");
        }
        if (clients.isEmpty()) {
            throw new IllegalArgumentException("clients list cannot be empty");
        }
        if (R <= 0) {
            throw new IllegalArgumentException("radius must be positive");
        }

        TwoDTree<Client> tree = new TwoDTree<>(clients);


        List<Station> stations = new ArrayList<>();
        for (Client client : clients) {
            int neighborsCount = tree.getNumberNeighborsRadius(client, R);
            stations.add(new Station(client.getIndex(), neighborsCount));
        }

        Collections.sort(stations, (s1, s2) -> {
            if (s1.getClientsNumber() != s2.getClientsNumber()) {
                return Integer.compare(s2.getClientsNumber(), s1.getClientsNumber());
            }
            return Integer.compare(s1.getIndex(), s2.getIndex());
        });

        return stations.subList(0, Math.min(10, stations.size()));
    }
}
