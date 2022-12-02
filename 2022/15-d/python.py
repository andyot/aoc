from pathlib import Path


def solve_a(sensors, beacons, target_y):
  signals = set()
  bx = set(x for x, y in beacons if y == target_y)
  for sx, sy, distance in sensors:
    dx = distance - abs(target_y - sy)
    if dx >= 0:
      signals.update(range(sx - dx, sx + dx + 1))
  return len(signals - bx)

def solve_b(sensors):
  for target_y in range(4_000_001):
    intervals = []
    for sx, sy, distance in sensors:
      dx = distance - abs(target_y - sy)
      if dx >= 0:
        intervals.append((sx - dx, sx + dx))

    intervals.sort()

    x = 0
    for min_x, max_x in intervals:
      if min_x - x > 1:
        return (x + 1) * 4000000 + target_y
      x = max(max_x, x)


if __name__ == '__main__':
  with Path("input.txt").open("r") as f:
    sensors = []
    beacons = set()

    for line in f:
      idx = line.index(":")
      sx, sy = map(int, line[12:idx].split(", y="))
      bx, by = map(int, line[idx+25:].split(", y="))
      beacons.add((bx, by))
      sensors.append((sx, sy, abs(sx - bx) + abs(sy - by)))

    # print("A:", solve_a(sensors, beacons, 2_000_000))
    print("B:", solve_b(sensors))
