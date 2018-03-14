;
; Input processing
;
Input: MACRO
	newKey:
		ds 11,0FFH
	ENDM

; ix = this
Input_Construct:
	ret

; ix = this
Input_Update: PROC
	ld c,ixl
	ld b,ixh
	ld hl,Input.newKey
	add hl,bc
	ld bc,0BA9H
	di
	in a,(0AAH)
	and 0F0H
Loop:
	out (0AAH),a
	inc a
	ini
	jr nz,Loop
	ei
	ret
	ENDP
