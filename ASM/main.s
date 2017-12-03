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
;push 32 r3 ;;pour pas perdre notre registre quand on exécute la fonction

	asr3 r3 r2 5 	; r3 <- r2 << 5 ; r3 = r2 * 32
	shift 0 r2 7
	add2 r3 r2 	; r3 += r2 << 7 ; r3 = r2 * 160
	shift 1 r2 7

	add2 r3 r1 ; r3 += r1 ; r3 = r2 * 160 + r1
	shift 0 r3 4 	; r3 << 4 ; r3 *= 16
	add2i r3 0x10000

	setctr a0 r3
	write a0 16 r0

	;pop 32 r3

return


;; fill
;; remplit un rectangle (r1,r2),(r3,r4) de la couleur r0 avec la convention (r1>r3)&(r2>r4)
fill:

push 32 r5
push 16 r2
push 16 r1

loopy:
asr3 r5 r2 5
shift 0 r2 7
add2 r5 r2
shift 1 r2 7
add2 r5 r1
shift 0 r5 4
add2i r5 0x10000

loopx:
setctr a0 r5
write a0 16 r0
add2i r1 1
cmp r1 r3
jumpif 16 gt break
add2i r5 16
jump 16 loopx
break:


cmp r2 r4
jumpif 16 gt break2
add2i r2 1
pop 16 r1
push 16 r1
jump 16 loopy

break2:

pop 16 r2
pop 16 r1
pop 32 r5

return

; à retenir 0xF1234 est un joli bleu
; 0x0F111 un rose qui va bien avec.. bref
main:
	leti r0 0xF000
	leti r1 10
	leti r2 10
	leti r3 15
	leti r4 15
	call fill

	jump -13
