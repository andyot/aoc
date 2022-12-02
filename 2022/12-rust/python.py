from pathlib import Path

START_VALUE = ord('S')
END_VALUE = ord('E')

def location(map, value):
  for y in range(len(map)):
    for x in range(len(map[y])):
      if map[y][x] == value:
        return x, y

def can_move(map, pos, dx, dy):
  x, y = pos
  src = map[y][x]
  dst = map[y + dy][x + dx]
  if src == START_VALUE:
    return True
  if src == ord('z') and dst == END_VALUE:
    return True
  return dst - src <= 1 and dst != END_VALUE
  
def possible_paths(map, pos):
  x, y = pos
  height = len(map)
  width = len(map[0])
  m = []
  if x > 0 and can_move(map, pos, -1, 0):
    m.append((x - 1, y))
  if y > 0 and can_move(map, pos, 0, -1):
    m.append((x, y - 1))
  if y < height-1 and can_move(map, pos, 0, 1):
    m.append((x, y + 1))
  if x < width-1 and can_move(map, pos, 1, 0):
    m.append((x + 1, y))
  return m

def bfs(map, start_list, goal):
  queue = [[s] for s in start_list]
  visited = set()

  while queue:
    path = queue.pop(0)
    node = path[-1]

    if node == goal:
      return path[1:]

    for adjacent in possible_paths(map, node):
      if adjacent not in visited:
        visited.add(adjacent)
        queue.append(path + [adjacent])

if __name__ == "__main__":
  with Path("input.txt").open("r") as f:
    lines = f.read().splitlines()

  map = [
    [ord(letter) for letter in list(line)]
    for line in lines
  ]

  start = location(map, START_VALUE)
  goal = location(map, END_VALUE)

  print("A:", len(bfs(map, [start], goal)))
  print("B:", len(bfs(map, [(0, y) for y in range(len(map))], goal)))
