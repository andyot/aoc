import fs from "fs";

type Item = number | Item[];

function compare(left: Item, right: Item): number {
  if (Array.isArray(left) && Array.isArray(right)) {
    const minLen = Math.min(left.length, right.length);
    for (let i = 0; i < minLen; i++) {
      const result = compare(left[i], right[i]);
      if (result !== 0) {
        return result;
      }
    }
    return left.length - right.length;
  } else if (Array.isArray(left)) {
    return compare(left, [right]);
  } else if (Array.isArray(right)) {
    return compare([left], right);
  } else if (left == right) {
    return 0;
  } else {
    return left < right ? -1 : 1
  }
}

function readInput() {
  return fs.readFileSync("input.txt", "utf-8");
}

function main() {
  const input = readInput();
  const groups = input.split("\n\n");
  const pairs = groups
    .map(g => g.split("\n"))
    .map(g => g.map(i => JSON.parse(i)))

  let a = 0;
  pairs.forEach((p, i) => {
    if (compare(p[0], p[1]) < 0) {
      a += i + 1;
    }
  });
  console.log("A:", a);

  const two = [[2]];
  const six = [[6]];
  const packets = [two, six];
  pairs.forEach(p => packets.push(...p));
  packets.sort(compare);

  let b = 1;
  packets
    .forEach((p, i) => {
      if (p === two || p === six) {
        b *= i + 1;
      }
    });
  console.log("B:", b);
}

main();
