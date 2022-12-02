open System.Text.RegularExpressions

let readInput path = System.IO.File.ReadAllText(path);

let (|DivisibleBy|_|) by value = 
    if value % by = 0 then Some DivisibleBy else None

let divideByThree value = value / 3

type Monkey =
  struct
    val id: int
    val initialItems: int[]
    val operation: string[]
    val testValue: int
    val iftrue: int
    val iffalse: int
    val inspections: int

    new (id, items, operation, testValue, iftrue, iffalse) = {
      id = id;
      initialItems = items;
      operation = operation;
      testValue = testValue;
      iftrue = iftrue;
      iffalse = iffalse;
      inspections = 0;
    }

    member x.CalcWorryLevel item =
      let op = x.operation[1]
      let rh = x.operation[2]
      let rhValue = if rh.Equals "old" then item else rh |> int
      match op with
      | "*" -> item * rhValue
      | "+" -> item + rhValue
      | _ -> 0
      |> divideByThree

    member x.Test item = 
      let new_value = x.CalcWorryLevel item
      match new_value with
      | DivisibleBy x.testValue -> (x.iftrue, new_value)
      | _ -> (x.iffalse, new_value)
  end

let monkeyDescription (text: string) = text.Split "\n\n"

let parseMonkey (description: string) =
  let lines = description.Split "\n"
  new Monkey(
    lines[0][7..(lines[0].Length - 2)] |> int,
    (lines[1][18..]).Split ", " |> Array.map(int),
    (lines[2][19..]).Split " ",
    lines[3][21..] |> int,
    lines[4][29..] |> int,
    lines[5][30..] |> int
  )

let parseMonkeys (input: string) =
  let descriptions = monkeyDescription input
  descriptions |> Array.map(parseMonkey)

let update (itemGroups: (int list)[]) toMonkey item =
  itemGroups[toMonkey] <- item :: itemGroups[toMonkey]
  toMonkey

let increase (arr: int[]) idx = arr[idx] <- arr[idx] + 1

let run rounds (monkeys: Monkey[]) = 
  let mutable itemGroups =
    monkeys
    |> Array.map (fun x -> x.initialItems)
    |> Array.map List.ofArray

  let inspections: int[] = Array.zeroCreate monkeys.Length
  for i in [1..rounds] do
    for m in monkeys do
      for item in itemGroups[m.id] do
        item
        |> m.Test
        ||> update itemGroups
        |> increase inspections
      itemGroups[m.id] <- []
  inspections

let input = readInput "input.txt" 

let mulFirstTwo (list: int[]) = list[0] * list[1]
let monkeyBusinessLevel list =
  list |> Seq.sortBy (~-) |> Seq.toArray |> mulFirstTwo

let a = input |> parseMonkeys |> run 20 |> monkeyBusinessLevel
printfn "A: %d\n" a

