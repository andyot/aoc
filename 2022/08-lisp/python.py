from functools import reduce
from pathlib import Path

def column(matrix, i):
  return [row[i] for row in matrix]

def visible_distance(trees, height):
  distance = 0
  for t in trees:
    distance += 1
    if t >= height:
      break
  return distance

if __name__ == "__main__":
  with Path("input.txt").open("r") as f:
    lines = f.read().splitlines()

  rows = [[int(c) for c in list(line)] for line in lines]
  
  visible_count = 0
  scenic_scores = []

  for y, row in enumerate(rows):
    for x, height in enumerate(row):
      if y == 0 or x == 0 or y == len(row) - 1 or x == len(rows) - 1:
        visible_count += 1
        continue

      col = column(rows, x)
      views = [
        list(reversed(row[:x])),
        row[x + 1:],
        list(reversed(col[:y])),
        col[y + 1:]
      ]
    
      visible_count += 1 if any(max(v) < height for v in views) else 0
      score = reduce(lambda x, y: x * y, [
        visible_distance(v, height) for v in views
      ])
      scenic_scores.append(score)

print("A:", visible_count)
print("B:", max(scenic_scores))