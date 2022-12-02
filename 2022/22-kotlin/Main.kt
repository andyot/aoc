import java.io.File

private fun parse(input: String): Pair<List<String>, List<String>> {
  val data = File(input).readText().split("\n\n")
  val boardLines = data[0].split("\n")
  val instructions = data[1]
    .replace("R", " R ")
    .replace("L", " L ")
    .split(" ")
  return boardLines to instructions
}

private fun wrap(lines: List<String>, x: Int, y: Int, facing: Int): Pair<Int, Int> {
  var nx = x
  var ny = y
  while (true) {
    when (facing) {
      0 -> nx = if (nx + 1 < lines[y].length) nx + 1 else 0
      1 -> ny = if (ny + 1 < lines.size) ny + 1 else 0
      2 -> nx = if (nx > 0) nx - 1 else lines[y].length - 1
      3 -> ny = if (ny > 0) ny - 1 else lines.size - 1
    }
    if (nx >= lines[ny].length) {
      continue
    }
    when (lines[ny][nx]) {
      '#' -> return Pair(x, y)
      '.' -> return Pair(nx, ny)
    }
  }
}

private fun wrapCube(board: HashMap<Pair<Int, Int>, Char>, x: Int, y: Int, facing: Int): Triple<Int, Int, Int> {
  val result = moveAroundEdge(x, y, facing)
  return if (board[Pair(result.first, result.second)] == '.') {
    result
  } else {
    Triple(x, y, facing)
  }
}

private fun moveAroundEdge(x: Int, y: Int, facing: Int): Triple<Int, Int, Int> {
  val q0 = 0
  val q1 = 50
  val q2 = 100
  val q3 = 150
  val q4 = 200

  when (facing) {
    3 -> when {
      x in q1 until q2 && y == 0 ->
        return Triple(0, q2 + x, 0)
      x in 0 until q1 && y == q2 ->
        return Triple(q1, q1 + x, 0)
      x in q2 until q3 && y == 0 ->
        return Triple(x - q2, q4 - 1, 3)
    }
    2 -> when {
      x == 0 && y in q3 until q4 ->
        return Triple(y - q2, 0, 1)
      x == q1 && y in 0 until q1 ->
        return Triple(0, q3 - y - 1, 0)
      x == 0 && y in q2 until q3 ->
        return Triple(q1, q3 - y - 1, 0)
      x == q1 && y in q1 until q2 ->
        return Triple(y - q1, q2, 1)
    }
    1 -> when {
      x in q0 until q1 && y == q4 - 1 ->
        return Triple(q2 + x, 0, 1)
      x in q2 until q3 && y == q1 - 1 ->
        return Triple(q2 - 1, x - q1, 2)
      x in q1 until q2 && y == q3 - 1 ->
        return Triple(q1 - 1, q2 + x, 2)
    }
    0 -> when {
      x == q3 - 1 && y in 0 until q1 ->
        return Triple(q2 - 1, q3 - y - 1, 2)
      x == q2 - 1 && y in q2 until q3 ->
        return Triple(q3 - 1, q3 - y - 1, 2)
      x == q2 - 1 && y in q1 until q2 ->
        return Triple(q1 + y, q1 - 1, 3)
      x == q1 - 1 && y in q3 until q4 ->
        return Triple(y - q2, q3 - 1, 3)
    }
  }
  return Triple(x, y, facing)
}

private fun findStart(lines: List<String>): Pair<Int, Int>? {
  lines.forEachIndexed { y, row ->
    val x = row.indexOf('.')
    if (x >= 0) {
      return x to y
    }
  }
  return null
}

private fun createBoard(boardLines: List<String>): HashMap<Pair<Int, Int>, Char> {
  val board = HashMap<Pair<Int, Int>, Char>()
  boardLines.forEachIndexed { y, row ->
    row.forEachIndexed { x, v ->
      if (v == '#' || v == '.') {
        board[Pair(x, y)] = v
      }
    }
  }
  return board
}

private fun solve(lines: List<String>, instructions: List<String>, cube: Boolean): Int {
  val board = createBoard(lines)
  var (x, y) = findStart(lines)!!
  var facing = 0

  val directions = mapOf(
    0 to Pair(1, 0),
    1 to Pair(0, 1),
    2 to Pair(-1, 0),
    3 to Pair(0, -1)
  )

  for (instruction in instructions) {
    if (instruction == "R") {
      facing = (facing + 1).mod(4)
      continue
    }
    if (instruction == "L") {
      facing = (facing - 1).mod(4)
      continue
    }
    for (i in 0 until instruction.toInt()) {
      val (dx, dy) = directions[facing]!!
      val newPos = Pair(x + dx, y + dy)
      if (newPos !in board) {
        if (cube) {
          wrapCube(board, x, y, facing).also {
            x = it.first
            y = it.second
            facing = it.third
          }
        } else {
          wrap(lines, x, y, facing).also {
            x = it.first
            y = it.second
          }
        }
      } else if (board[newPos] == '.') {
        x += dx
        y += dy
      }
    }
  }
  return (y + 1) * 1000 + (x + 1) * 4 + facing
}

fun main() {
  val (boardLines, instructions) = parse("input.txt")
  println("A: " + solve(boardLines, instructions, false))
  println("B: " + solve(boardLines, instructions, true))
}
