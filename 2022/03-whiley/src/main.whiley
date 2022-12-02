// Day 4: Whiley https://whiley.org

import std::io
import string, char, lowercase, is_lower_case, uppercase, is_upper_case from std::ascii
import slice, contains, append from std::array
import uint from std::int

function compartments(string items, uint count) -> (string[] result)
requires |items| % count == 0
ensures |result| == count
ensures all { i in 0..count | |result[i]| == |items| / count }:
    return [
        slice(items, 0, |items| / count),
        slice(items, |items| / count, |items|)
    ]

function common_item(string[] groups) -> (char item)
requires |groups| >= 2
ensures item != 0:
    for i in 0..|groups[0]|:
        bool not_found = false
        for j in 1..|groups|:
            if !contains(groups[j], groups[0][i], 0, |groups[j]|):
                not_found = true
                break
        if !not_found:
            return groups[0][i]
    return 0

function priority(char item) -> (int prio)
requires is_lower_case(item) || is_upper_case(item)
ensures is_lower_case(item) ==> 1 <= prio && prio <= 26
ensures is_upper_case(item) ==> 27 <= prio && prio <= 27 + 26:
    if item > 'Z':
        return ((int)item - (int)'a') + 1
    else:
        return ((int)item - (int)'A') + 27

function group_backpacks(string[] backpacks, uint count) -> (string[][] result)
requires |backpacks| % count == 0
ensures |backpacks| / count == |result|
ensures all { i in 0..|result| | |result[i]| == count }:
    string[][] groups = [ backpacks ; |backpacks| / count ]
    for i in 0..|backpacks|:
        if i % count == 0:
            groups[i / count] = slice(backpacks, (uint)i, (uint)i + count)
    return groups

public export method main():
    // std::fs::open is not implemented
    string input = ""
    string[] backpacks = split(input, '\n')

    int a = 0
    for i in 0..|backpacks|:
        a = a + priority(common_item(compartments(backpacks[i], 2)))
    io::print("A: ")
    io::println(a)

    int b = 0
    string[][] groups = group_backpacks(backpacks, 3)
    for i in 0..|groups|:
        b = b + priority(common_item(groups[i]))
    io::print("B: ")
    io::println(b)


// Utilities

function split(string str, char separator) -> string[]:
    string[] result = []
    uint start = 0
    for i in 0..|str|
    where start <= i:
        if str[i] == separator:
            result = append(result, slice(str, start, (uint)i))
            start = (uint)i + 1
    if start != |str|:
        result = append(result, slice(str, start, |str|))
    return result