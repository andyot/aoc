import std.math, std.typecons, std.algorithm, std.stdio, std.string, std.array, std.conv;

struct Sensor {
  long x;
  long y;
  long distance;
}

struct Beacon {
  long x;
  long y;
}

long solveA(Sensor[] sensors, Beacon[] beacons) {
  long targetY = 2000000;
  bool[long] signals;
  
  foreach (sensor; sensors) {
    auto dx = sensor.distance - abs(targetY - sensor.y);
    if (dx >= 0) {
      foreach (x; (sensor.x - dx)..(sensor.x + dx + 1)) {
        signals[x] = true;
      }
    }
  }

  beacons
    .filter!(b => b.y == targetY)
    .each!(b => signals.remove(b.x));

  return signals.length;
}

long solveB(Sensor[] sensors) {
  long maxY = 4000000;

  foreach (targetY; 0..(maxY + 1)) {
    Tuple!(long, long)[] intervals;

    foreach (sensor; sensors) {
      auto dx = sensor.distance - abs(targetY - sensor.y);
      if (dx >= 0) {
        intervals ~= tuple(sensor.x - dx, sensor.x + dx);
      }
    }
    intervals.sort!("a[0] < b[0]");

    long x = 0;
    foreach (interval; intervals) {
      if (interval[0] - x > 1) {
        return (x + 1) * 4000000 + targetY;
      }
      x = max(interval[1], x);
    }
  }
  return 0;
}

void main() {
  auto file = File("input.txt");
  auto lines = file.byLineCopy();

  Sensor[] sensors = [];
  Beacon[] beacons = [];

  foreach (line; lines) {
    auto idx = indexOf(line, ':');
    auto sensor = line[12..idx]
      .split(", y=")
      .map!(to!long);
    auto beacon = line[(idx + 25)..line.length]
      .split(", y=")
      .map!(to!long);
    
    auto bx = beacon[0];
    auto by = beacon[1];
    auto sx = sensor[0];
    auto sy = sensor[1];
    auto distance = abs(sx - bx) + abs(sy - by);

    auto closestBeacon = Beacon(bx, by);
    if (!canFind(beacons, closestBeacon)) {
      beacons ~= closestBeacon;
    }

    sensors ~= Sensor(sx, sy, distance);
  }
  
  writefln("A: %d", solveA(sensors, beacons));
  writefln("B: %d", solveB(sensors));
}