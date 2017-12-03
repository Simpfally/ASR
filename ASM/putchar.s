;;putchar
;;Affiche un caractère codé dans r3 en ASCII de la couleur r0 aux coordonnées (r1,r2)

jump 16 main

putchar:
push 32 r3
push 32 r4
push 16 r5
push 16 r6

add2i r3 255
shift 0 r3 6 ; r3 =r3*64
setctr a0 r3
readze a0 32 r3
readze a0 32 r4

add3i r6 r2 4


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
    		add2i r4 1
  		cmpi r4 0
    		jumpif 16 eq endif1
	  	write a0 16 r0
    		endif1:
		pop 32 r4 
    		add2i r1 1
	  	cmpi r1 8
	  	jumpif 16 gt xbreak
	  	add2i r5 16
		shift 0 r4 1
	  	jump 16 loopx
    	xbreak:

  	cmp r2 r6
  	jumpif 16 gt ybreak
  	add2i r2 1
  	pop 16 r1
  	jump 16 loopy
ybreak:

add3i r6 r2 4


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
    		push 32 r3
    		add2i r3 1
  		cmpi r3 0
    		jumpif 16 eq endif1
	  	write a0 16 r0
    		endif1:
		pop 32 r3 
    		add2i r1 1
	  	cmpi r1 8
	  	jumpif 16 gt xbreak
	  	add2i r5 16
		shift 0 r3 1
	  	jump 16 loopx
    	xbreak:

  	cmp r2 r6
  	jumpif 16 gt ybreak
  	add2i r2 1
  	pop 16 r1
  	jump 16 loopy
ybreak:

pop 16 r6
pop 16 r5
pop 32 r4
pop 32 r3

return

main:

leti r0 20
leti r1 20
leti r2 20

leti r3 80
call putchar
