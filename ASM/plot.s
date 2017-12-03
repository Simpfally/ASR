;;plot
;;affiche un point de couleur r0 aux coordonnées (r1,r2)

;; (0,0) -----> (159, 0)
;;   |
;;   V
;; (0, 127)
jump 16 main

plot:

push 16 r3 ;;pour pas perdre notre registre quand on exécute la fonction

let r3 r1
shift 0 r2 5
add2 r3 r2
shift 0 r2 2
add2 r3 r2
shift 0 r3 4
add2i r3 0x10000

setctr a0 r3
write a0 16 r0

pop 16 r3

return

main:
leti r0 0xF123
leti r1 0
leti r2 0
call plot
leti r1 1
leti r2 0
call plot
leti r1 100
leti r2 0
call plot
leti r1 159
leti r2 0
call plot
leti r1 0
leti r2 127
call plot
jump -13
