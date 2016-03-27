;
; Input processing
;
Input: MACRO
	newKey:
		ds 11,0FFH
	ENDM

; ix = this
Input_Update_IY:
	push iy
	ex (sp),ix
	call Input_UpdateNewKey
	ex (sp),ix
	pop iy
	ret

; ix = this
Input_UpdateNewKey: PROC
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
