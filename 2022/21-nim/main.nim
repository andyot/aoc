import std/strutils
import std/tables


proc isNumeric(x: string): bool =
  try:
    discard parseInt(x)
    return true
  except ValueError:
    return false


proc evaluate(monkey: string, monkeys: Table[string, string]): string =
  let expression = monkeys[monkey]
  if isNumeric(expression):
    return expression

  let components = expression.split()
  let a = parseInt(evaluate(components[0], monkeys))
  let b = parseInt(evaluate(components[2], monkeys))
  
  case components[1]:
    of "+": return $(a + b)
    of "-": return $(a - b)
    of "*": return $(a * b)
    of "/": return $(a div b)


proc find_monkey(target_monkey: string, monkey: string, monkeys: Table[string, string], idx: int): bool =
  let expression = monkeys[monkey]
  if target_monkey in expression:
    return true

  if isNumeric(expression):
    return monkey == target_monkey

  let components = expression.split()
  let lhs = find_monkey(target_monkey, components[idx], monkeys, 0)
  return lhs or find_monkey(target_monkey, components[idx], monkeys, 2)


proc solve(monkey: string, target_monkey: string, monkeys: Table[string, string], acc: int64): int64 =
  if monkey == target_monkey:
    return acc

  let expression = monkeys[monkey]
  if isNumeric(expression):
    return acc

  let components = expression.split()
  let a = components[0]
  let op = components[1]
  let b = components[2]

  if find_monkey(target_monkey, monkey, monkeys, 0):
    let val = parseInt(evaluate(b, monkeys))
    case op:
      of "+": return solve(a, target_monkey, monkeys, acc - val)
      of "-": return solve(a, target_monkey, monkeys, acc + val)
      of "*": return solve(a, target_monkey, monkeys, acc div val)
      of "/": return solve(a, target_monkey, monkeys, acc * val)
  else:
    let val = parseInt(evaluate(a, monkeys))
    case op:
      of "+": return solve(b, target_monkey, monkeys, acc - val)
      of "-": return solve(b, target_monkey, monkeys, val - acc)
      of "*": return solve(b, target_monkey, monkeys, acc div val)
      of "/": return solve(b, target_monkey, monkeys, val div acc)


proc read_input(filename: string): Table[string, string] =
  let f = open(filename)
  defer: f.close()

  var line: string

  var monkeys = initTable[string, string]()
  while f.read_line(line):
    let c = line.split(": ")
    monkeys[c[0]] = c[1]

  return monkeys


let monkeys = read_input("input.txt")

echo("A: ", evaluate("root", read_input("input.txt")))

let rootMonkey = monkeys["root"].split()
let lhs = rootMonkey[0]
let rhs = rootMonkey[2]

echo("B: ", solve(lhs, "humn", monkeys, parseInt(evaluate(rhs, monkeys))))