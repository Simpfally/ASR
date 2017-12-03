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
;; modifie un peu r2 : suppose qu'un shift <<2 ne le modifie pas

;; (0,0) -----> (159, 0)
;;   |
;;   V
;; (0, 127)   * (

plot:

; à décider si on fait cet écart de performance ou non :
;push 32 r3 ;;pour pas perdre notre registre quand on exécute la fonction

	asr3 r3 r2 5 	; r3 <- r2 << 5
	shift 0 r2 7
	add2 r3 r2 	; r3 += r2 << 7
	shift 1 r2 7

	add2 r3 r1
	shift 0 r3 4 	; r3 << 4
	add2i r3 0x10000

	setctr a0 r3
	write a0 16 r0

	;pop 32 r3

return


; à retenir 0xF1234 est un joli bleu
; 0x0F111 un rose qui va bien avec.. bref
main:
	leti r0 0xF000
	leti r1 0
	leti r2 0
	call plot
	loop:
		call plot
		add2i r1 1
		add2i r2 1
		add2i r0 50
		cmpi r1 120
		jumpif 16 eq break
		cmpi r2 120
		jumpif 16 eq break
		jump 16 loop
	break:
	jump -13
