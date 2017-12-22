jump 32 main

; div r0 <- r1/r2
; tous positifs 16bits et r1 en 8bits?
; modifie r0 r3
div:
	leti r0 0
	let r3 r1
	divloop:
		sub2 r3 r2
		jumpif 8 lt divreturn ;; if r1 < r2
		add2i r0 1
		jump 8 divloop
	divreturn:
	return

; mult r0 <- r1 * r2
; positifs ok tant que r0 tiens dans 16 bits
; modifie r0 r3

mult:
	leti r0 0
	let r3 r1
	multloop:
		add2 r0 r2
		sub2i r3 1
		jumpif 8 neq multloop ; if r3 != 0
	return
	

; fill screen with color r0
; modify : r1, a0
clean_screen:
	leti r1 0x10000
	setctr a0 r1
	clearscreenloop:
		write a0 16 r0
		add2i r1 16
		cmpi r1 393216
		jumpif 16 lt clearscreenloop
	return


;; plot
;; affiche un point de couleur r0 aux coordonnées (r1,r2)
;; modify r3 a0
;; modifie un peu r2 : suppose qu'un shift <<7 ne le modifie pas

;; (0,0) -----> (159, 0)
;;   |
;;   V
;; (0, 127)

plot:

; à décider si on fait cet écart de performance ou non :
push 32 r3 ;;pour pas perdre notre registre quand on exécute la fonction

	asr3 r3 r2 5 	; r3 <- r2 << 5 ; r3 = r2 * 32
	shift 0 r2 7
	add2 r3 r2 	; r3 += r2 << 7 ; r3 = r2 * 160
	shift 1 r2 7

	add2 r3 r1 ; r3 += r1 ; r3 = r2 * 160 + r1
	shift 0 r3 4 	; r3 << 4 ; r3 *= 16
	add2i r3 0x10000

	setctr a0 r3
	write a0 16 r0

	pop 32 r3

return


;; fill
;; remplit un rectangle (r1,r2),(r3,r4) de la couleur r0 avec la convention (r1>r3)&(r2>r4)
fill:

	push 32 r5
	push 16 r2
	push 16 r1
	sub2i r4 1

	fillloopy:
		asr3 r5 r2 5
		shift 0 r2 7
		add2 r5 r2
		shift 1 r2 7
		add2 r5 r1
		shift 0 r5 4
		add2i r5 0x10000

		fillloopx:
			setctr a0 r5
			write a0 16 r0
			add2i r1 1
			cmp r1 r3
			jumpif 16 gt fillbreak
			add2i r5 16
			jump 16 fillloopx
		fillbreak:


		cmp r2 r4
		jumpif 16 gt fillbreak2
		add2i r2 1
		pop 16 r1
		push 16 r1
		jump 16 fillloopy

	fillbreak2:

	pop 16 r1
	pop 16 r2
	pop 32 r5

return

;;putchar
;;Affiche un caractère codé dans r3 en ASCII de la couleur r0 aux coordonnées (r1,r2)


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


;;draw : trace une ligne de couleur r0 entre les points de coordonnée (r1,r2) et (r3,r4)
draw:
push 16 r0 ; couleur
push 16 r1 ; addr du pixel
push 16 r2 ; dy
push 16 r3 ; dx
push 16 r4 ; err
push 32 r5 ; pas selon x
push 32 r6 ; 
push 32 r7 ; 

let r6 r4
setctr a1 r4 ; y1
push 16 r3 ; x1
push 16 r2 ; y0
push 16 r1
push 16 r3


let r3 r1
asr3 r1 r2 5 ; r1 = x0 + r2 * 32
shift 0 r2 7
add2 r1 r2 ;r1 = x0 + r2 * 160
add2 r1 r3
shift 1 r2 7 ; r2 retour à sa valeur (y0)
shift 0 r1 4
add2i r1 0x10000
setctr a0 r1

write a0 16 r0
getctr a0 r1
sub2i r1 16
setctr a0 r1

pop 16 r3
pop 16 r1

cmp r1 r3
jumpif 16 lt x0<x1
;then
	sub3 r3 r1 r3 ; DX = x0 - x1
	leti r5 0
	jump 16 skipx0<x1
;else
	x0<x1:
	leti r5 1
	sub3 r3 r3 r1
skipx0<x1:


	cmp r2 r4
	jumpif 16 lt y0<y1
;then
	sub3 r2 r4 r2 ; DY = y1 - y0
	jump 16 skipy0<y1
;else
	y0<y1:
	add2i r5 2
	sub2 r2 r4
	skipy0<y1:

pop 16 r6 ;y0

add3 r4 r2 r3

loop:
	shift 0 r4 1 ; R4 = ERR * 2


	cmp r4 r2
	jumpif 16 slt e2>=dy ; jump if e2 < dy
	pop 16 r7 ; x1
	cmp r7 r1 ; x1 == x0
	push 16 r7
	jumpif 16 eq break1
	push 32 r0
	push 32 r4 ;; ERR*2 E2
	shift 1 r4 1 ; R4 = ERR
	add2 r4 r2 ;R4 = ERR += DY


let r0 r5 ; r0 = donnée des pas
and3i r0 r0 1
cmpi r0 1
jumpif 16 neq pasneg
add2i r1 1
getctr a0 r7
add2i r7 16
setctr a0 r7

jump 16 skippaspos
pasneg:
sub2i r1 1
getctr a0 r7
sub2i r7 16
setctr a0 r7
jump 16 skippaspos


	e2>=dy: ; (rien fait)
	push 32 r0
	push 32 r4
	shift 1 r4 1

	skippaspos:
	pop 32 r0 ; r0 = E2

	cmp r3 r0
	jumpif 16 slt dx<e2
	; là  dx >= e2

	getctr a1 r7 ; Y1
	cmp r7 r6 ; Y1 == Y0?
	jumpif 16 eq break2

	add2 r4 r3 ; ERR += DX

let r0 r5
and3i r0 r0 2
shift 1 r0 1
cmpi r0 1
jumpif 16 neq pasnegro
add2i r6 1
getctr a0 r7
add2i r7 2560
setctr a0 r7
jump 16 skippasneg
pasnegro:
sub2i r6 1
getctr a0 r7
sub2i r7 2560
setctr a0 r7
jump 16 skippasneg
	dx<e2:
	;(rien fait)





skippasneg:
	pop 32 r0
	write a0 16 r0
	getctr a0 r7
	sub2i r7 16
	setctr a0 r7
jump 16 loop
break1:
pop 16 r1
jump 16 nff
break2:
pop 32 r0
pop 16 r1

nff:
pop 32 r7
pop 32 r6
pop 32 r5
pop 16 r4
pop 16 r3
pop 16 r2
pop 16 r1
pop 16 r0
return
;;;;


main:

leti r0 61444
leti r1 10
leti r2 60
leti r3 55
leti r4 70
call fill

leti r0 12444
leti r1 10
leti r2 60
call plot
leti r1 55
leti r2 70
call plot


	jump -13
