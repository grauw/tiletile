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

; iy = this
Input_UpdateIY: PROC
	ld c,iyl
	ld b,iyh
	ld hl,Input.newKey
	add hl,bc
	ld bc,11 << 8 | 0A9H
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

; iy = this
; bc <- x (-1 left, 1 right)
; de <- y (-1 up, 1 down)
Input_GetDirectionIY: PROC
	ld b,0
	ld c,b
	ld d,b
	ld e,b
	ld a,(iy + Input.newKey + 8)
	rlca
	jr c,NoRight
	inc bc
NoRight:
	rlca
	jr c,NoDown
	inc de
NoDown:
	rlca
	jr c,NoUp
	dec de
NoUp:
	rlca
	ret c
	dec bc
	ret
	ENDP
