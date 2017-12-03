jump 16 main

plot:

leti r3 0x10000

;;décalage.... Je vois pas comment faire autrement..
add2 r2 r2
add2 r2 r2
add2 r2 r2
add2 r2 r2
add2 r2 r2
add2 r3 r2
add2 r2 r2
add2 r2 r2
add2 r3 r2
add2 r3 r1

setsctr a0 r3
write a0 16 r0

return

main:
leti r0 0xF123
leti r1 10
leti r2 10
call plot
jump -13
