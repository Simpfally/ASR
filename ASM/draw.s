;;draw
;; trace une ligne de couleur r0 entre les points de coordonnée (r1,r2) et (r3,r4)
;; Comment faire pour tracer des lignes de bas en haut et de haut en bas??
jump 16 main

draw:

;; valeur de r7 au début du programme: à dépiler avant le return!
push 16 r7

sub3 r6 r4 r2 ;;dy ← y2 - y1
sub3 r5 r1 r3 ;;dx ← x2 - x1 et e ← -dx (valeur d’erreur initiale)
;; y ← y1: on utilisera directement r2 (rangée initiale)
shift 0 r6 1 ;;e(1,0) ← dy × 2 
let r7 r5
shift 0 r7 1 ;;e(0,1) ← -dx × 2  (si le shift marche pour les négatifs)

loop:
;;la valeur de plot est écrasée à l'appel de call donc il faut l'empiler juste avant et le dépiler juste après
push 16 r7
call plot
pop 16 r7
add2i r1 1

add2 r5 r6
cmpi r5 0
jumpif lt 16 endif ;;if (e ← e+e(1,0) >= 0) Ici je sais pas si la valeur de e doit etre modifiée mais je pense que oui (c'est fait) 
add2i r2 1 ;;y ← y+1
add2 r5 r7 ;;e ← e+e(0,1)
endif:

cmp r3 r1
jumpif 16 ge loop

pop 16 r7

return

main:
leti r0 0xF123
leti r1 10
leti r2 10
leti r3 100
leti r4 30
call draw
jump -13
