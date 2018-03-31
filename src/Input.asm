;
; Input processing
;
Input_KEY_MATRIX_ROWS: equ 11
Input_PPI_PORT_B: equ 0A9H
Input_PPI_PORT_C: equ 0AAH

Input: MACRO
	newKey:
		ds Input_KEY_MATRIX_ROWS, 0FFH
	oldKey:
		ds Input_KEY_MATRIX_ROWS, 0FFH
	ENDM

; ix = this
Input_Construct:
	ret

; iy = this
Input_UpdateIY: PROC
	ld e,iyl
	ld d,iyh
	ld hl,Input.oldKey
	add hl,de
	ex de,hl
	ld hl,Input.newKey - Input.oldKey
	add hl,de
	push hl
	REPT Input_KEY_MATRIX_ROWS
	ldi
	ENDM
	pop hl
	ld bc,Input_KEY_MATRIX_ROWS << 8 | Input_PPI_PORT_B
	di
	in a,(Input_PPI_PORT_C)
	and 0F0H
Loop:
	out (Input_PPI_PORT_C),a
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
