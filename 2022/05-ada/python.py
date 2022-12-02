from pathlib import Path
import re

def read_stacks(lines):
  stacks = [""] * 9
  for line in lines:
    if line == "":
      break
    for i in range(0, len(line), 4):
      if line[i] != " ":
        stacks[(i // 4)] += line[i + 1]
  return [s[::-1] for s in stacks if len(s) > 0]

def read_instructions(lines):
  return [
    [int(d) for d in re.findall(r"(\d+)", line)]
    for line in lines
    if line[:4] == "move"
  ]

def move_crates(instructions, stacks, upgraded = False):
  for instruction in instructions:
    n, f, t = instruction
    f -= 1
    t -= 1
    
    stacks[t] += stacks[f][-n:][::1 if upgraded else -1]
    stacks[f] = stacks[f][:-n]
  return stacks

def top_crates(stacks):
  return "".join([s[-1] for s in stacks])

with Path("input.txt").open("r") as f:
  lines = f.read().splitlines()
  instr = read_instructions(lines)

  print("A: " + top_crates(move_crates(instr, read_stacks(lines))))
  print("B: " + top_crates(move_crates(instr, read_stacks(lines), True)))
