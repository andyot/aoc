from pathlib import Path

def read_input(lines):
  dirs = set()
  files = []
  cwd = []

  for line in lines:
    if line.startswith("$ cd"):
      match dir := line[5:]:
        case "/":
          cwd = []
        case "..":
          cwd.pop()
        case _:
          cwd.append(dir)
      dirs.add("/" + "/".join(cwd))
    elif line[0].isdigit():
      size, name = line.split(" ")
      files.append(("/" + "/".join(cwd + [name]), int(size)))
  return dirs, files

def size(dir, files):
  return sum(s for f, s in files if f.startswith(dir))

def smallest(dir_sizes_asc, threshold=0):
  for dir, size in dir_sizes_asc:
    if size >= threshold:
      return dir, size
  return None, 0

if __name__ == "__main__":
  with Path("input.txt").open("r") as f:
    lines = f.read().splitlines()

  dirs, files = read_input(lines)
  dir_sizes = sorted(
    ((d, size(d, files)) for d in dirs),
    key=lambda x: x[1]
  )

  print(f"A: {sum(s for _, s in dir_sizes if s < 100000)}")

  required = 30000000 - (70000000 - size("/", files))
  print(f"B: {smallest(dir_sizes, required)[1]}")
  