import java.awt.geom.Point2D;
import java.util.List;

public class QuickSelect2D<T extends Point2D.Double> {
    public T quickSelect(List<T> points, int axis, int k) throws NullPointerException, IllegalArgumentException{
        if (points == null) {
            throw new NullPointerException("points list cannot be null");
        }
        if (points.isEmpty()) {
            throw new IllegalArgumentException("points list cannot be empty");
        }
        if (axis != 0 && axis != 1) {
            throw new IllegalArgumentException("axis must be 0 (X) or 1 (Y)");
        }
        if (k < 0 || k >= points.size()) {
            throw new IllegalArgumentException("k is out of bounds");
        }
        int left = 0;
        int right = points.size() - 1;

        while (left <= right) {
            int pivotIndex = partition(points, left, right, axis);
            if (pivotIndex == k) {
                return points.get(pivotIndex);
            } else if (pivotIndex < k) {
                left = pivotIndex + 1;
            } else {
                right = pivotIndex - 1;
            }
        }
        return points.get(left);
    }

    private int partition(List<T> points, int left, int right, int axis) {
        T pivot = points.get(right);
        double pivotValue = getAxisValue(pivot, axis);
        int i = left;

        for (int j = left; j < right; j++) {
            if (getAxisValue(points.get(j), axis) <= pivotValue) {
                swap(points, i, j);
                i++;
            }
        }
        swap(points, i, right);
        return i;
    }

    private void swap(List<T> points, int i, int j) {
        T temp = points.get(i);
        points.set(i, points.get(j));
        points.set(j, temp);
    }

    private double getAxisValue(Point2D.Double point, int axis) {
        return axis == 0 ? point.getX() : point.getY();
    }
}