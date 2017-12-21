leti r1 300
shift 0 r1 6

setctr a0 r1
leti r1 0

loop:
readze a0 16 r2
add2 r1 r2
jump 16 loop
