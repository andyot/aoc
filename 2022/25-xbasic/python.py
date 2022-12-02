from pathlib import Path


def snafuToDec(value):
  base = 5
  res = 0
  length = len(value)
  for i in range(length):
    exp = (length - i - 1)
    match value[i]:
      case "-": k = -1
      case "=": k = -2
      case _: k = int(value[i])
    res += base ** exp * k
  return res


def decToSnafu(value):
  base = 5
  res = ""
  carry = 0
  while value:
    v = value % base + carry
    carry = 0 if v <= 2 else 1
    match v:
      case 3: v = "="
      case 4: v = "-"
      case 5: v = "0"
    res = str(v) + res
    value = value // base
  return res

if __name__ == '__main__':
  data = Path("input25.txt").read_text().splitlines()
  x = sum([snafuToDec(v) for v in data])
  print(decToSnafu(x))
