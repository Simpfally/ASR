;; fill
;; remplit un rectangle (r1,r2),(r3,r4) de la couleur r0 avec la convention (r1>r3)&(r2>r4)

jump 16 main

fill:
let r5 r1
shift 0 r2 5
add2 r5 r2
shift 0 r2 2
add2 r5 r2
shift 0 r5 4
add2i r5 0x10000

;; pour savoir de combien se décaler après une ligne
leti r6 160
sub r6 r3
add r6 r1
shift 0 r6 4

push 16 r1
loop0:
add r2 1
pop 16 r1
push 16 r1
setctr a0 r5
loop1:
write a0 16 r0
addi r5 16
addi r1 1
cmp r3 r1
jumpif 16 ge loop1
addi r5 r6
cmp r4 r2
jumpif 16 ge loop0

return

main:
leti r0 0xF123
leti r1 10
leti r2 10
leti r3 100
leti r4 100
call fill
jump -13
