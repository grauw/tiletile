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
