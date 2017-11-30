; div.s
; r0 r1 entiers positifs sur 16 bits avec l'octet de poids fort de r1 nul
; r2 <- r0/r1


; exemple r2 = 2
add2i r0 22
add2i r1 10

sub2 r0 r1
jumpif le 22
add2i r2 1
jump -48

;;;;
jump -13

;; 48 bits par itération (ligne 10 à 13)
