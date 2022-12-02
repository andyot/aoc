from pathlib import Path

def move(x, y, tx, ty):
  if abs(x - tx) >= 2:
    tx += 1 if x > tx else - 1
    if ty != y:
      ty += max(-1, min(1, y - ty))
  if abs(y - ty) >= 2:
    ty += 1 if y > ty else - 1
    if tx != x:
      tx += max(-1, min(1, x - tx))
  return tx, ty

def count_tail_positions(lines, knot_count):
  hx, hy, tx, ty = 0, 0, 0, 0

  knots = [(0, 0)] * knot_count
  tail_positions = set()
  for line in lines:
    direction, distance = line.split(" ")
    for _ in range(int(distance)):
      match direction:
        case "R":
          hx += 1
        case "U":
          hy -= 1
        case "D":
          hy += 1
        case "L":
          hx -= 1

      tx, ty = move(hx, hy, tx, ty)
      knots[0] = (tx, ty)

      for i in range(1, len(knots)):
        knots[i] = move(knots[i-1][0], knots[i-1][1], knots[i][0], knots[i][1])
        
      tail_positions.add(knots[-1])
  return len(tail_positions)


if __name__ == "__main__":
  with Path("input.txt").open("r") as f:
    lines = f.read().splitlines()

  print("A:", count_tail_positions(lines, 1))
  print("B:", count_tail_positions(lines, 9))
