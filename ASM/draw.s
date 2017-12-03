;;draw
;; trace une ligne de couleur r0 entre les points de coordonnée (r1,r2) et (r3,r4)
;; Comment faire pour tracer des lignes de bas en haut et de haut en bas??
jump 16 main

draw:

;; valeur de r7 au début du programme: à dépiler avant le return!
push 16 r7

;; r5 est l'erreur

sub3 r6 r4 r2 ;;dy ← y2 - y1
sub3 r5 r1 r3 ;;dx ← x2 - x1 et e ← -dx (valeur d’erreur initiale)
;; y ← y1: on utilisera directement r2 (rangée initiale)
;; pour ces deux la il faut voir comment gerer la pile et r7
;; sachant que r7 sera écrasé à l'execution de call plot 
;;donc il faudra l'empiler juste avant et le dépiler juste après (c'est pas un probleme mais c'est important^^)
e(1,0) ← dy × 2; 
e(0,1) ← -dx × 2;

loop:
push 16 r7
call plot
pop 16 r7
addi r1 1

;; Ici le if à gérer je sais pas comment faire (je comprends moyen les jumps avec les adresses...)
if (e+e(1,0) >= 0) 
  then { add r2 1
         

cmp r3 r1
jumpif 16 ge loop

pop 16 r7

return

main:
