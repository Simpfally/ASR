jump 16 main

plot:

let r3 r1
shift r2 5
add2 r3 r2
shift r2 2
add2 r3 r2
shift r3 4
add2 r3 0x10000

setsctr a0 r3
write a0 16 r0

return

main:
leti r0 0xF123
leti r1 10
leti r2 10
call plot
jump -13
