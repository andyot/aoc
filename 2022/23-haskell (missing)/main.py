import sys
from collections import defaultdict

def is_clear(position, elves, direction):
    y, x = position
    dy, dx = direction
    dxx = 1 if dx == 0 else 0
    dyy = 1 if dy == 0 else 0
    return (y+dy, x+dx) not in elves and (y+dy+dyy, x+dx+dxx) not in elves and (y+dy-dyy, x+dx-dxx) not in elves


def n_clear_directions(position, elves, directions):
    return sum([is_clear(position, elves, d) for d in directions])


def get_score(elves):
    min_y = min([y for y, _ in elves])
    max_y = max([y for y, _ in elves])
    min_x = min([x for _, x in elves])
    max_x = max([x for _, x in elves])

    return (max_x-min_x + 1) * (max_y - min_y + 1) - len(elves)


def main():
    elves = set()
    for y, l in enumerate(sys.stdin):
        for x, c in enumerate(l):
            if c == "#":
                elves.add((y, x))
    
    directions = [(-1, 0), (1, 0), (0, -1), (0, 1)]
    i = 0
    while True:
        proposed_move = defaultdict(list)
        direction_index = i % len(directions)

        for e in elves:
            if 0 < n_clear_directions(e, elves, directions) < len(directions):
                for k in range(len(directions)):
                    d = directions[(direction_index+k)%len(directions)]
                    if is_clear(e, elves, d):
                        new_position = (e[0] + d[0], e[1] + d[1])
                        proposed_move[new_position].append(e)
                        break
            else:
                proposed_move[e].append(e)


        elves.clear()
        no_move_count = 0
        for new_position, old_positions in proposed_move.items():
            if len(old_positions) == 1:
                elves.add(new_position)
                if new_position == old_positions[0]:
                    no_move_count += 1
            else:
                elves.update(old_positions)
                no_move_count += len(old_positions)
        if no_move_count == len(elves):
            print(i+1)
            break
        i += 1



if __name__ == "__main__":
    main()