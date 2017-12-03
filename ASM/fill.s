;;fill
;;remplit un rectangle (r1,r2),(r3,r4) de la couleur r0 avec la convention (r1>r3)&(r2>r4)

jump 16 main

fill:
let r5 r1
shift 0 r2 5
add2 r5 r2
shift 0 r2 2
add2 r5 r2
shift 0 r5 4
add2i r5 0x10000

let r6 r3
shift 0 r4 5
add2 r6 r4
shift 0 r4 2
add2 r6 r4
shift 0 r6 4
addi r6 1

setctr a0 r5
loop:
write a0 16 r0
addi r5 16
cmp r5 r6
jumpif 16 lt loop

return

main:
leti r0 0xF123
leti r1 10
leti r2 10
leti r3 100
leti r4 100
call fill
jump -13
