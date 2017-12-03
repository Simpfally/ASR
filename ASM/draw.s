;;draw
;; trace une ligne de couleur r0 entre les points de coordonnée (r1,r2) et (r3,r4)
;; Comment faire pour tracer des lignes de bas en haut et de haut en bas??
jump 16 main

draw:

push 16 r7

;; r5 est l'erreur
sub3 r5 r1 r3

let r6 r1
dy ← y2 - y1 ;
dx ← x2 - x1 ;
y ← y1 ;  // rangée initiale
e ← -dx ;  // valeur d’erreur initiale
e(1,0) ← dy × 2;
e(0,1) ← -dx × 2;
   
