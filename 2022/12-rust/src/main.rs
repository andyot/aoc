use std::fs;
use std::collections::VecDeque;
use std::collections::HashSet;

const START: u32 = 'S' as u32;
const END: u32 = 'E' as u32;

type Point = (i16, i16);

fn location(map: &Vec<Vec<u32>>, value: u32) -> Option<Point> {
  for y in 0..map.len() {
    for x in 0..map[y].len() {
      if map[y][x] == value {
        return Some(
          (i16::try_from(x).unwrap(), i16::try_from(y).unwrap()));
      }
    }
  }
  return None
}

fn can_move_to(map: &Vec<Vec<u32>>, width: i16, height: i16, position: Point, dx: i16, dy: i16) -> bool {
  let (x, y) = position;

  if x + dx < 0 || y + dy < 0 || x + dx >= width || y + dy >= height {
    return false
  }
  let src = map[y as usize][x as usize];
  let dst = map[(y + dy) as usize][(x + dx) as usize];
  if src == START || (src == 'z' as u32 && dst == END) {
    return true
  }
  return (dst as i16) - (src as i16) <= 1 && dst != END
}

fn possible_paths(map: &Vec<Vec<u32>>, position: Point) -> Vec<Point> {
  let (x, y) = position;
  let h = i16::try_from(map.len()).unwrap();
  let w = i16::try_from(map[0].len()).unwrap();

  let mut paths = Vec::new();
  if can_move_to(map, w, h, position, -1, 0) {
    paths.push((x - 1, y));
  }
  if can_move_to(map, w, h, position, 1, 0) {
    paths.push((x + 1, y));
  }
  if can_move_to(map, w, h, position, 0, -1) {
    paths.push((x, y - 1));
  }
  if can_move_to(map, w, h, position, 0, 1) {
    paths.push((x, y + 1));
  }
  return paths;
}

fn bfs(map: &Vec<Vec<u32>>, start_positions: Vec<Point>, goal: Point) -> Vec<(i16, i16)> {
  let mut queue = VecDeque::new();
  for p in start_positions {
    queue.push_back(vec![p])
  }
  let mut visited = HashSet::new();
  
  while !queue.is_empty() {
    let path = queue.pop_front().unwrap();
    let node = path.last().unwrap();

    if node.0 == goal.0 && node.1 == goal.1 {
      return (&path[1..]).to_vec();
    }
    for adjacent in possible_paths(map, *node) {
      if !visited.contains(&adjacent) {
        visited.insert(adjacent);
        let mut new_path = path.clone();
        new_path.push(adjacent);
        queue.push_back(new_path);
      }
    }
  }
  return Vec::new()
}

fn main() {
  let contents = fs::read_to_string("input.txt").unwrap();

  let map: Vec<Vec<u32>> = contents.lines()
    .map(|l| l.chars().map(|c| c as u32).collect())
    .collect();

  let start_pos = location(&map, START).unwrap();
  let goal_pos = location(&map, END).unwrap();

  println!("A: {:?}", bfs(&map, vec![start_pos], goal_pos).len());

  let b_start = (0..map.len()).map(|y| (0i16, y as i16)).collect();
  println!("B: {:?}", bfs(&map, b_start, goal_pos).len());
}
