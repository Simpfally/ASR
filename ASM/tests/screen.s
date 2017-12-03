jump 16 main

draw:
add2 r0 r3
add2 r1 r2
setctr a0 r0
write a0 16 r1
return



main:
leti r0 0x10000
leti r1 0xFF00
leti r2 4
leti r3 16
call draw
loop:
call draw
cmpi r1 0xFFFF
jumpif 16 lt loop
leti r1 0xF001
add2i r2 3
jump 16 loop
jump -13
