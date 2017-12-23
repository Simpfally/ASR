jump 32 main

;;insérer les fonctions

main:

leti r0 0

leti r6 0

loopx:
leti r1 0
leti r2 0
leti r3 0
let1 r4 127
	loopy:
	call draw
	add2 r0 r6
	add2i r1 1
	add2i r3 1
	cmpi r1 128
	jumpif 16 eq endloopy
	jump 16 loopy
	endloopy:
addi r6 1
cmpi r6 2000
jumpif 16 eq endloopx
jump 16 loopx
endloopx:
