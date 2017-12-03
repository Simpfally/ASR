;;putchar
;;Affiche un caractère codé dans r3+r4 de la couleur r0 aux coordonnées (r1,r2)

jump 16 main

putchar:
push 32 r3
push 32 r4
push 16 r5
push 16 r6

leti r6 0x10000
leti r5 152


loop0:
push 32 r4
andi r4 1
cmpi r4 0
jumpif eq 16 endif1



return

main:
