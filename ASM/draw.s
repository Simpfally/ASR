;;draw
;; trace une ligne de couleur r0 entre les points de coordonnée (r1,r2) et (r3,r4)
;; Comment faire pour tracer des lignes de bas en haut et de haut en bas??
jump 16 main

draw:
;; r5 est l'erreur
sub3 r5 r1 r3
