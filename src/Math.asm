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
