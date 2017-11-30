;mult.s
; r0 r1 entiers positifs
; r2 <- r0 * r1 (tant que r0 * r1 tiens dans 16bits)


;; Exemple r2 = 30
add2i r0 10
add2i r1 3

add2 r2 r0
sub2i r1 1
jumpif neq -35

;;
jump -13

;; 35 bits par itération (ligne 10 à 12)
