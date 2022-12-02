from collections import deque
from pathlib import Path


def neighbours(cube):
  x, y, z = cube
  return [
    (x+1, y, z),
    (x-1, y, z),
    (x, y+1, z),
    (x, y-1, z),
    (x, y, z+1),
    (x, y, z-1)
  ]


def interior(cube, lava_cubes, bounds, interior_space, exterior_space):
  visited = set()
  queue = deque([cube])
  while queue:
    node = queue.pop()
    if node in exterior_space or not in_bounds(node, bounds):
      return False, visited

    visited.add(node)

    for new_node in neighbours(node):
      if new_node not in visited and new_node not in lava_cubes and node not in interior_space:
        queue.append(new_node)

  return True, visited


def solve_a(lava_cubes):
  n = 0
  for lava_cube in lava_cubes:
    for neighbour in neighbours(lava_cube):
      if neighbour not in lava_cubes:
        n += 1
  return n


def in_bounds(cube, bounds):
  x, y, z = cube
  bx, by, bz = bounds

  if x < bx[0] or x > bx[1]:
    return False
  if y < by[0] or y > by[1]:
    return False
  if z < bz[0] or z > bz[1]:
    return False

  return True


def bounds(cubes):
  bx = min(c[0] for c in cubes), max(c[0] for c in cubes)
  by = min(c[1] for c in cubes), max(c[1] for c in cubes)
  bz = min(c[2] for c in cubes), max(c[2] for c in cubes)
  return bx, by, bz


def solve_b(lava_cubes):
  n = 0
  exterior_space = set()
  interior_space = set()
  trapped = set(lava_cubes)

  lava_bounds = bounds(lava_cubes)

  for lava_cube in lava_cubes:
    for neighbour in neighbours(lava_cube):
      if neighbour not in lava_cubes:
        is_interior, path = interior(neighbour, trapped, lava_bounds, interior_space, exterior_space)
        if not is_interior:
          exterior_space.update(path)
          n += 1
        else:
          interior_space.update(path)
  return n


if __name__ == '__main__':
  with Path("input.txt").open("r") as f:
    cubes = set([
      tuple(map(int, line.split(",")))
      for line in f
    ])

  print("A:", solve_a(cubes))
  print("B:", solve_b(cubes))
