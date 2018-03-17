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

; iy = this
; bc <- x (-1 left, 1 right)
; de <- y (-1 up, 1 down)
Input_GetDirectionIY: PROC
	ld b,0
	ld c,b
	ld d,b
	ld e,b
	bit 4,(iy + Input.newKey + 8)
	jr nz,NoLeft
	dec bc
NoLeft:
	bit 7,(iy + Input.newKey + 8)
	jr nz,NoRight
	inc bc
NoRight:
	bit 5,(iy + Input.newKey + 8)
	jr nz,NoUp
	dec de
NoUp:
	bit 6,(iy + Input.newKey + 8)
	ret nz
	inc de
	ret
	ENDP
