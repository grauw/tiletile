;
; Input processing
;
Input_KEY_MATRIX_ROWS: equ 11
Input_PPI_PORT_B: equ 0A9H
Input_PPI_PORT_C: equ 0AAH
Input_PSG_ADDRESS: equ 0A0H
Input_PSG_WRITE: equ 0A1H
Input_PSG_READ: equ 0A2H
Input_PSG_GPIO_A: equ 14
Input_PSG_GPIO_B: equ 15

Input: MACRO
	newKey:
		ds Input_KEY_MATRIX_ROWS, 0FFH
	oldKey:
		ds Input_KEY_MATRIX_ROWS, 0FFH
	newStick:
		db 0FFH
	oldStick:
		db 0FFH
	ENDM

; ix = this
Input_Construct:
	ret

; iy = this
Input_UpdateIY:
	call Input_UpdateKeyboardIY
	call Input_UpdateJoystickIY
	ret

; iy = this
Input_UpdateKeyboardIY: PROC
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
Input_UpdateJoystickIY:
	ld a,(iy + Input.newStick)
	ld (iy + Input.oldStick),a
	di
	ld a,Input_PSG_GPIO_B
	out (Input_PSG_ADDRESS),a
	in a,(Input_PSG_READ)
	and ~(1 << 6)
	out (Input_PSG_WRITE),a
	ld a,Input_PSG_GPIO_A
	out (Input_PSG_ADDRESS),a
	ei
	in a,(Input_PSG_READ)
	ld (iy + Input.newStick),a
	ret

; iy = this
; bc <- x (-1 left, 1 right)
; de <- y (-1 up, 1 down)
Input_GetDirectionIY: PROC
	call Input_GetKeyboardAsJoystickIY
	and (iy + Input.newStick)
	ld b,0
	ld c,b
	ld d,b
	ld e,b
	rrca
	jr c,NoUp
	dec de
NoUp:
	rrca
	jr c,NoDown
	inc de
NoDown:
	rrca
	jr c,NoLeft
	dec bc
NoLeft:
	rrca
	ret c
	inc bc
	ret
	ENDP

; iy = this
; a <- keyboard mapped as joystick
Input_GetKeyboardAsJoystickIY:
	ld a,(iy + Input.newKey + 8)
	rlca
	rlca
	rlca
	rr b
	rrca
	rrca
	rr b
	rlca
	rlca
	rlca
	rr b
	rrca
	rrca
	rrca
	rrca
	rr b
	rrca
	rr b
	ld a,(iy + Input.newKey + 6)
	rrca
	rr b
	scf
	rr b
	scf
	rr b
	ld a,b
	ret
