import java.awt.*;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.*;
import java.util.List;
import java.util.function.Function;
import java.util.stream.IntStream;
import java.util.stream.Stream;


public class Main {
    public static void main(String[] args) throws IOException {
        List<String> lines = Files.readAllLines(Paths.get("input.txt"));
        HashSet<Point> rocks = parseRocks(lines);

        int a = solve(rocks, true);
        System.out.println("A: " + a);

        int b = solve(rocks, false);
        System.out.println("B: " + b);
    }

    private static int solve(HashSet<Point> initialRocks, boolean endlessVoid) {
        HashSet<Point> rocks = new HashSet<>(initialRocks);

        int yMax = max(rocks, r -> r.y);
        int xMax = max(rocks, r -> r.x);
        int xMin = min(rocks, r -> r.x);

        Point source = new Point(500, 0);
        Point current = source;

        int n = 0;
        while (true) {
            int x = current.x;
            int y = current.y;

            if (rocks.contains(source)) {
                return n;
            }

            if (endlessVoid) {
                if (x < xMin || x > xMax || y > yMax) {
                    return n;
                }
            }

            Point down = new Point(x, y + 1);
            if (!collides(down, rocks, yMax)) {
                current = down;
                continue;
            }

            Point downLeft = new Point(x - 1, y + 1);
            if (!collides(downLeft, rocks, yMax)) {
                current = downLeft;
                continue;
            }

            Point downRight = new Point(x + 1, y + 1);
            if (!collides(downRight, rocks, yMax)) {
                current = downRight;
                continue;
            }

            n += 1;
            rocks.add(current);
            current = source;
        }
    }

    private static Integer max(HashSet<Point> rocks, Function<Point, Integer> fn) {
        return rocks.stream()
                .map(fn)
                .max(Integer::compare)
                .orElse(0);
    }

    private static Integer min(HashSet<Point> rocks, Function<Point, Integer> fn) {
        return rocks.stream()
                .map(fn)
                .min(Integer::compare)
                .orElse(0);
    }

    private static boolean collides(Point point, HashSet<Point> rocks, int yMax) {
        return rocks.contains(point) || point.y > yMax + 1;
    }

    private static HashSet<Point> parseRocks(List<String> lines) {
        HashSet<Point> rocks = new HashSet<>();

        for (String line : lines) {
            String[] items = line.split(" -> ");
            List<Point> points = IntStream.range(1, items.length)
                    .mapToObj(i -> parsePoints(items[i - 1], items[i]))
                    .flatMap(p -> p)
                    .toList();
            rocks.addAll(points);
        }
        return rocks;
    }

    private static Stream<Point> parsePoints(String start, String end) {
        Point s = parsePoint(start);
        Point e = parsePoint(end);

        if (s.x == e.x) {
            int yMin = Math.min(s.y, e.y);
            int yMax = Math.max(s.y, e.y);
            return IntStream
                    .range(yMin, yMax + 1)
                    .mapToObj(y -> new Point(s.x, y));
        } else {
            int xMin = Math.min(s.x, e.x);
            int xMax = Math.max(s.x, e.x) + 1;
            return IntStream
                    .range(xMin, xMax)
                    .mapToObj(x -> new Point(x, s.y));
        }
    }

    private static Point parsePoint(String data) {
        int[] c = Arrays.stream(data.split(","))
                .mapToInt(Integer::parseInt).toArray();
        return new Point(c[0], c[1]);
    }
}