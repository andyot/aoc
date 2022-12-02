// Day 1: Io Language https://github.com/IoLanguage/io

groupByElf := method(
    split("\n\n") \
    map(_, group, 
        group split("\n") map(asNumber) reduce(+)
    )
)

data := File standardInput contents

"A: " print
data groupByElf max println

"B: " print
data groupByElf sort reverse slice(0, 3) reduce(+) println
