/**
 * <p>Класс для хранения и печати результата</p>
 */
public class Station {
    private final int index;
    private final int clientsNumber;

    public Station(int index, int clientsNumber) throws IllegalArgumentException{
        if (index < 0){
            throw new IllegalArgumentException("index must be non-negative");
        }
        if (clientsNumber < 0){
            throw new IllegalArgumentException("clientsNumber must be non-negative");
        }
        this.index = index;
        this.clientsNumber = clientsNumber;
    }

    public int getIndex() {
        return index;
    }

    public int getClientsNumber() {
        return clientsNumber;
    }

    @Override
    public String toString() {
        return index + " " + clientsNumber;
    }
}
