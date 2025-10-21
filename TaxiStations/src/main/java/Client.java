import java.awt.geom.Point2D;
/**
 * <p>Класс для всей информации о каждом клиенте</p>
 */
public class Client extends Point2D.Double {
    private final int index;

    public Client(int index, double x, double y) throws IllegalArgumentException{
        super(x, y);
        if (index < 0){
            throw new IllegalArgumentException("index must be non-negative");
        }
        this.index = index;
    }

    public int getIndex() {
        return index;
    }
}