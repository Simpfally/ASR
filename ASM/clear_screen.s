jump 16 main

;fill screen with color r0
; modify : r1, a0
clean_screen:
leti r1 0x10000
setctr a0 r1

loop:
write a0 16 r0
add2i r1 16

cmpi r1 393216
jumpif 16 lt loop

return


main:
leti r0 0xF123
call clean_screen
jump -13
