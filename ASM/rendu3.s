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

	pop 16 r2
	pop 16 r1
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

orgamacro:
setctr a0 r2
readze a0 16 r3
cmpi r3 65535
jumpif 16 neq orgamacroend
backo:
add2i r4 1
cmpi r4 4
jumpif 16 eq shoulddo

jump 16 endosni
orgamacroend:
cmpi r3 61440
jumpif 16 eq backo

endosni:
return

;; do w/e to pixel in r0 r1, address is in r2
orga:
;;count neighbors
push 32 r7
push 32 r2
leti r4 0

sub2i r2 2560
call orgamacro
add2i r2 16
call orgamacro
sub2i r2 32
call orgamacro
add2i r2 16

add2i r2 2560
add2i r2 16
call orgamacro
sub2i r2 32
call orgamacro
add2i r2 16

add2i r2 2560
call orgamacro
add2i r2 16
call orgamacro
sub2i r2 32
call orgamacro

shoulddo:


pop 32 r2
setctr a0 r2
push 32 r2
readze a0 16 r3
cmpi r3 65535
jumpif 16 neq isthree ;finished if its dead

cmpi r4 3
jumpif 16 eq end

cmpi r4 2
jumpif 16 eq end ;let it
;not 2 not 3 = dead
jump 16 delete

isthree:
cmpi r4 3
jumpif 16 eq create
jump 16 end

create:
pop 32 r2
push 32 r2
push 32 r4
leti r4 960 ; green
setctr a0 r2
write a0 16 r4
pop 32 r4
jump 16 end

delete:
pop 32 r2
push 32 r4
leti r4 61440 ; rouge
setctr a0 r2
write a0 16 r4
pop 32 r4
pop 32 r7
return

end:

pop 32 r2
pop 32 r7

return


;PRESTEP
life:
push 32 r7
leti r1 1
leti r0 1

; set cursor at r0 r1
asr3 r2 r1 5
shift 0 r1 7
add2 r2 r1
shift 1 r1 7
add2 r2 r0
shift 0 r2 4
add2i r2 0x10000
setctr a0 r2


loopy:
push 16 r0
push 32 r2
loopx:
push 32 r2
call orga
pop 32 r2
add2i r0 1
add2i r2 16
cmpi r0 159
jumpif 16 eq breakx
jump 16 loopx
breakx:
pop 32 r2
add2i r1 1
add2i r2 2560
cmpi r1 127
jumpif 16 eq breaky
pop 16 r0
jump 16 loopy


breaky:
pop 16 r0


pop 32 r7
return


;;
gala:
push 32 r7
push 32 r4
setctr a0 r2
readze a0 16 r4
setctr a0 r2
cmpi r4 61440
jumpif 16 eq galadelete
cmpi r4 960
jumpif 16 eq galacreate
jump 16 galaend
galadelete:
leti r4 0
write a0 16 r4
jump 16 galaend
galacreate:
leti r4 65535
write a0 16 r4

galaend:
pop 32 r4 
pop 32 r7
return

;; do modifications
life2:

push 32 r7
leti r1 1
leti r0 1

; set cursor at r0 r1
asr3 r2 r1 5
shift 0 r1 7
add2 r2 r1
shift 1 r1 7
add2 r2 r0
shift 0 r2 4
add2i r2 0x10000
setctr a0 r2


galaloopy:
push 16 r0
push 32 r2
galaloopx:
push 32 r2
call gala
pop 32 r2
add2i r0 1
add2i r2 16
cmpi r0 159
jumpif 16 eq galabreakx
jump 16 galaloopx
galabreakx:
pop 32 r2
add2i r1 1
add2i r2 2560
cmpi r1 127
jumpif 16 eq galabreaky
pop 16 r0
jump 16 galaloopy


galabreaky:
pop 16 r0


pop 32 r7
return


main:

leti r0 0xFFFFFF
leti r1 12
leti r2 12
call plot
sub2i r2 1
call plot
add2i r1 1
call plot
add2i r2 1
call plot



leti r1 20
leti r2 20
call plot
leti r1 19
leti r2 19
call plot
leti r1 21
leti r2 19
call plot

leti r1 30
leti r2 20
call plot
leti r1 30
leti r2 21
call plot
leti r1 29
leti r2 22
call plot
leti r1 28
leti r2 21
call plot

leti r1 55
leti r2 55
call plot
leti r1 55
leti r2 56
call plot
leti r1 55
leti r2 57
call plot
leti r1 56
leti r2 55
call plot
leti r1 54
leti r2 56
call plot


leti r1 50
leti r2 110
call plot
add2i r1 1
call plot
add2i r1 1
call plot
add2i r1 1
call plot
add2i r1 1
call plot
add2i r1 1
call plot
add2i r1 1
call plot
add2i r1 1
call plot
add2i r1 2
call plot
add2i r1 1
call plot
add2i r1 1
call plot
add2i r1 1
call plot
add2i r1 1
call plot
add2i r1 4
call plot
add2i r1 1
call plot
add2i r1 1
call plot
add2i r1 7
call plot
add2i r1 1
call plot
add2i r1 1
call plot
add2i r1 1
call plot
add2i r1 1
call plot
add2i r1 1
call plot
add2i r1 1
call plot
add2i r1 2
call plot
add2i r1 1
call plot
add2i r1 1
call plot
add2i r1 1
call plot
add2i r1 1
call plot

leti r5 50
loopdsq:
call life
call life2
sub2i r5 1
jumpif 16 eq endkk
jump 16 loopdsq
endkk:
jump -13
