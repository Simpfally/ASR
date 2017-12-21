;;putchar
;;Affiche un caractère codé dans r3 en ASCII de la couleur r0 aux coordonnées (r1,r2)

jump 16 main

putchar:
push 32 r3
push 32 r4
push 16 r5
push 16 r6

add2i r3 255
shift 0 r3 6
setctr a1 r3

add3i r6 r2 7

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
		leti r4 2
    		readze a1 1 r4
  		cmpi r4 0
    		jumpif 16 eq endif
	  	write a0 16 r0
    		endif:
    		add2i r1 1
	  	cmpi r1 7
	  	jumpif 16 gt xbreak
	  	add2i r5 16
	  	jump 16 loopx
    	xbreak:
	add2i r2 1
  	cmp r2 r6
  	jumpif 32 gt ybreak
  	pop 16 r1
  	jump 16 loopy
ybreak:


pop 16 r6
pop 16 r5
pop 32 r4
pop 32 r3

return

main:

leti r0 20000
leti r1 55
leti r2 55
leti r3 70

call putchar

leti r0 15000
leti r1 65
leti r2 55
leti r3 85

call putchar

leti r0 10000
leti r1 75
leti r2 55
leti r3 67

call putchar

leti r0 5000
leti r1 85
leti r2 55
leti r3 75

call putchar

leti r0 17500
leti r1 95
leti r2 55
leti r3 33

call putchar

jump -13
