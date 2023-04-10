ori 5 0 72
ori 8 0 40
jr 8
ori 1 0 1
sw 1 0(0)
ori 2 0 1
sw 2 0(0)
ori 3 0 2
sw 3 0(0)
eret
ori 9 0 65281
mtc0 9 12
ori 1 0 1
sw 1 0(0)
ori 2 0 1
sw 2 0(0)
ori 3 0 2
sw 3 0(0)
or 1 0 2
or 2 0 3
add 3 1 2
sw 3 0(0)
jr 5
sync
sync
sync
sync
