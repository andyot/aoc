from math import floor
from pathlib import Path


with Path("input.txt").open("r") as f:
  lines = f.read().splitlines()

  monkeys = []
  all_items = []
  
  for line in lines:
    if line.startswith("Monkey"):
      idx = int(line[7:-1])
    if line.startswith("  Starting"):
      items = list(line[18:].split(", "))
    if line.startswith("  Operation"):
      op = line[19:].split(" ")
    if line.startswith("  Test"):
      test = int(line[21:])
    if line.startswith("    If true"):
      t = int(line[29:])
    if line.startswith("    If false"):
      f = int(line[30:])
    if line == "":
      monkeys.append([idx, op, test, t, f])
      for item in items:
        all_items.append([idx, item])

  factor = 1
  for monkey in monkeys:
    factor *= monkey[2]

  previous = []
  inspections = [0] * 8
  for round in range(1, 10000+1):
    for monkey in monkeys:
      idx, op, test, t, f = monkey
      
      for i, current in enumerate(all_items):
        owner, item = current
        if owner != idx:
          continue
      
        inspections[idx] += 1
        rh = int(op[2].replace("old", item))
        if op[1] == "*":
          new_value = item * rh
        elif op[1] == "+":
          new_value = item + rh
        
        all_items[i][0] = t if new_value % test == 0 else f
        
        new_value %= factor
        all_items[i][1] = str(new_value)

    for monkey in monkeys:
      idx, op, test, t, f = monkey
  
  x = sorted(inspections)[-2:]
  print("B: ", x[0] * x[1])
    