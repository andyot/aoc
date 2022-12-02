from collections import deque
from pathlib import Path


def open_valves(start, valves, total_time, n_to_open=None):
  queue = deque([(start, [], set(), set(), 1)])
  if n_to_open is None:
    n_to_open = len([n for n, v in valves.items() if v[0] > 0])
  flows = {name: d[0] for name, d in valves.items()}

  result = []
  seen = set()

  while queue:
    current, valve_log, opened, visited, time = queue.popleft()

    if time >= total_time or len(opened) == n_to_open:
      result.append((valve_log, opened))
      continue

    identity = (current, frozenset(valve_log))
    if identity in seen:
      continue
    seen.add(identity)

    for dest in valves[current][1]:
      if dest not in visited:
        queue.append((dest, valve_log, opened, visited | {dest}, time + 1))
        if flows[dest] > 0 and dest not in opened:
          queue.append((
            dest,
            valve_log + [(flows[dest], time + 1)],
            opened | {dest},
            set(),
            time + 2
          ))
  return result


def calc_pressure(valve_log, t):
  return sum(p * (t - m) for p, m in valve_log)


if __name__ == '__main__':
  with Path("input.txt").open("r") as f:
    valves = {}
    for line in f:
      line = line.replace("valves", "valve").replace("tunnels", "tunnel").replace("leads", "lead").rstrip()
      name = line[6:8]
      flow = int(line[23:line.index(";")])
      destinations = line[line.index(";") + 22:].lstrip().split(", ")
      valves[name] = (flow, destinations)

  
  result = open_valves("AA", valves, 26, 7)
  result = {(calc_pressure(log, 26), frozenset(valves)) for log, valves in result}
  result = {(log, valves) for log, valves in result if log > 1000}

  max_press = 0
  for press_a, name_a in result:
    for press_b, name_b in result:
      if press_a + press_b > max_press and name_a.isdisjoint(name_b):
        max_press = press_a + press_b
  print('B:', max_press)
  