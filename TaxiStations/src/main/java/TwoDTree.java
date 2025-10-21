import java.awt.geom.Point2D;
import java.io.IOException;
import java.util.*;

/**
 * <p>Класс, реализующий структуру двумерного KD-дерева (2D-дерева). "Работает" c классом Point2D.Double и его потомками. Имеет два публичных метода - конструктор и getNumberNeighborsRadius.</p>
 * @param <T>
 */
public class TwoDTree<T extends Point2D.Double> {
    private Node root;
    private QuickSelect2D<T> quickSelect;

    private class Node {
        private T point;
        private Node left;
        private Node right;

        public Node(T point) {
            this.point = point;
            this.left = null;
            this.right = null;
        }

        public T getPoint() {
            return point;
        }

        public void setPoint(T point) {
            this.point = point;
        }

        public Node getLeft() {
            return left;
        }

        public void setLeft(Node left) {
            this.left = left;
        }

        public Node getRight() {
            return right;
        }

        public void setRight(Node right) {
            this.right = right;
        }
    }

    /**
     * Конструктор 2D-дерева.
     * @param points список точек, из которого нужно сформировать 2D-дерево
     * @throws NullPointerException
     * @throws IllegalArgumentException
     */
    public TwoDTree(List<T> points) throws NullPointerException, IllegalArgumentException{
        try {
            if (points == null) {
                throw new NullPointerException("points list cannot be null");
            }
            if (points.isEmpty()) {
                throw new IllegalArgumentException("points list cannot be empty");
            }
        } catch (RuntimeException e){
            throw new IllegalArgumentException("2D tree creation error: " + e.getMessage(), e);
        }
        this.quickSelect = new QuickSelect2D<>();
        /*this.root = buildBalancedTree(new ArrayList<>(points), 0);*/
        this.root = buildBalancedTree(new ArrayList<>(points));
    }

    public Node getRoot(){
        return this.root;
    }

    /*
    private Node buildBalancedTree(List<T> points, int depth) {
        if (points.isEmpty()) return null;

        int axis = depth % 2;
        int medianIndex = points.size() / 2;
        T median = quickSelect.quickSelect(points, axis, medianIndex);

        Node node = new Node(median);

        List<T> leftPoints = new ArrayList<>(points.subList(0, medianIndex));
        List<T> rightPoints = new ArrayList<>(points.subList(medianIndex + 1, points.size()));

        node.setLeft(buildBalancedTree(leftPoints, depth + 1));
        node.setRight(buildBalancedTree(rightPoints, depth + 1));

        return node;
    }
    */

    private Node buildBalancedTree(List<T> points) {
        if (points.isEmpty()) {
            return null;
        }

        Deque<BuildTask<T>> stack = new ArrayDeque<>();
        Node root = null;
        stack.push(new BuildTask<>(new ArrayList<>(points), 0, null, true));

        while (!stack.isEmpty()) {
            BuildTask<T> task = stack.pop();
            List<T> currentPoints = task.points;
            int depth = task.depth;

            if (currentPoints.isEmpty()) {
                continue;
            }

            int axis = depth % 2;
            int medianIndex = currentPoints.size() / 2;
            T median = quickSelect.quickSelect(currentPoints, axis, medianIndex);

            Node node = new Node(median);

            if (task.parent == null) {
                root = node;
            } else if (task.isLeft) {
                task.parent.setLeft(node);
            } else {
                task.parent.setRight(node);
            }

            stack.push(new BuildTask<>(
                    new ArrayList<>(currentPoints.subList(medianIndex + 1, currentPoints.size())),
                    depth + 1,
                    node,
                    false
            ));

            stack.push(new BuildTask<>(
                    new ArrayList<>(currentPoints.subList(0, medianIndex)),
                    depth + 1,
                    node,
                    true
            ));
        }

        return root;
    }

    private class BuildTask<T> {
        List<T> points;
        int depth;
        Node parent;
        boolean isLeft;

        BuildTask(List<T> points, int depth, Node parent, boolean isLeft) {
            this.points = points;
            this.depth = depth;
            this.parent = parent;
            this.isLeft = isLeft;
        }
    }

    /**
     * Находит колчество соседей точки в радиусе.
     * @param center точка, количество соседей которой нужно найти
     * @param radius радиус поиска соседей
     * @return количество соседей точки в радиусе
     * @throws NullPointerException
     * @throws IllegalArgumentException
     */
    public int getNumberNeighborsRadius(Point2D.Double center, double radius) throws NullPointerException, IllegalArgumentException {
        if (center == null) {
            throw new NullPointerException("center point cannot be null");
        }
        if (radius <= 0) {
            throw new IllegalArgumentException("radius must be positive");
        }
        int count = 0;
        Deque<Node> stack = new ArrayDeque<>();
        Deque<Integer> depths = new ArrayDeque<>();
        stack.push(root);
        depths.push(0);

        while (!stack.isEmpty()) {
            Node node = stack.pop();
            int depth = depths.pop();

            int axis = depth % 2;
            double nodeValue = (axis == 0) ? node.getPoint().getX() : node.getPoint().getY();
            double centerValue = (axis == 0) ? center.getX() : center.getY();

            double distance = center.distance(node.getPoint());
            if (distance <= radius && distance > 0) {
                count++;
            }

            boolean shouldVisitLeft = (centerValue - radius <= nodeValue);
            boolean shouldVisitRight = (centerValue + radius >= nodeValue);

            if (shouldVisitRight && node.getRight() != null) {
                stack.push(node.getRight());
                depths.push(depth + 1);
            }
            if (shouldVisitLeft && node.getLeft() != null) {
                stack.push(node.getLeft());
                depths.push(depth + 1);
            }
        }

        return count;
    }
}
