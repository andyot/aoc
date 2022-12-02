# Day 2: Bash

normalize() {
  sed "s/A/0/g; s/B/1/g; s/C/2/g; s/X/0/g; s/Y/1/g; s/Z/2/g"
}

points() {
  while read -r you me; do
    case "$you $me" in
      "0 0"|"1 1"|"2 2") echo $(($me + 4)) ;; # draw
      "0 1"|"1 2"|"2 0") echo $(($me + 7)) ;; # won
      *) echo $(($me + 1)) ;;                 # lost
    esac
  done
}

shopt -s expand_aliases
alias sum_lines="awk '{s+=\$1} END {printf \"%.0f\", s}'"

select_move() {
  while read move strategy; do
    case "$strategy" in
      "0") echo "$move $(((3 + $move - 1) % 3))" ;; # lose: -1
      "1") echo "$move $move" ;;                    # draw: 0
      "2") echo "$move $((($move + 1) % 3))" ;;     # win: +1
    esac
  done
}

data=$(</dev/stdin)

echo -n "A: "
normalize <<< $data | points | sum_lines
echo -n "B: "
normalize <<< $data | select_move | points | sum_lines
