;;putchar
;;Affiche un caractère codé dans r3 en ASCII de la couleur r0 aux coordonnées (r1,r2)

jump 16 main

putchar:
push 32 r3
push 32 r4
push 16 r5
push 16 r6

shift 0 r3 6 ; r3*64
add2i r3 0x100000
setctr a0 r3
readze r3 32 a0
readze r4 32 a0

leti r6 152


loopy:
	asr3 r5 r2 5
	shift 0 r2 7
	add2 r5 r2
	shift 1 r2 7
	add2 r5 r1
	shift 0 r5 4
  	add2i r5 0x10000
  	push 16 r1
  	leti r1 0

    	loopx:
		setctr a0 r5
    		push 32 r4
    		andi r4 1
  		cmp r4 0
    		jumpif eq 16 endif1
	  	write a0 16 r0
    		endif1:
    		add2i r1 1
	  	cmp r1 8
	  	jumpif 16 gt xbreak
	  	add2i r5 16
	  	jump 16 loopx
    	xbreak:

  	cmp r2 r4
  	jumpif 16 gt ybreak
  	add2i r2 1
  	pop 16 r2
  	pop 16 r1
  	jump 16 loopy
  	ybreak:

return

main:
