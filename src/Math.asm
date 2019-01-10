;
; Math functions
;

; e = multiplicand
; h = multiplier
; hl <- product
Math_Multiply8x8: PROC
	ld d,0
	ld l,d
	REPT 8
	add hl,hl
	jr nc,NoAdd
	add hl,de
NoAdd:
	ENDM
	ret
	ENDP

; See http://www.arklyffe.com/main/2010/08/29/xorshift-pseudorandom-number-generator/
; The 24 full-cycle 8-bit generators triplets:
; (1, 1, 2) (1, 1, 3) (1, 7, 3) (1, 7, 6) (1, 7, 7) (2, 1, 1)
; (2, 5, 5) (3, 1, 1) (3, 1, 5) (3, 5, 4) (3, 5, 5) (3, 5, 7)
; (3, 7, 1) (4, 5, 3) (5, 1, 3) (5, 3, 6) (5, 3, 7) (5, 5, 2)
; (5, 5, 3) (6, 3, 5) (6, 7, 1) (7, 3, 5) (7, 5, 3) (7, 7, 1)
; a = seed (not 0)
; a <- next
Math_XorShift_M: MACRO ?a, ?b, ?c, ?tempregister = l
	ld ?tempregister,a
	REPT ?a
	add a,a
	ENDM
	xor ?tempregister
	ld ?tempregister,a
	REPT ?b
	srl a
	ENDM
	xor ?tempregister
	ld ?tempregister,a
	REPT ?c
	add a,a
	ENDM
	xor ?tempregister
	ENDM
