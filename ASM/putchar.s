;;putchar
;;Affiche un caractère codé dans r3+r4 de la couleur r0 aux coordonnées (r1,r2)

jump 16 main

putchar:
push 32 r3
push 32 r4




return

main:
