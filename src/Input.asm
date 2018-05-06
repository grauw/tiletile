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
	call Input_GetKeyboardAsJoystickIY
	and (iy + Input.newStick)
	ld (iy + Input.newStick),a
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
	in a,(Input_PPI_PORT_C)
	and 0F0H
	dec a
Loop:
	inc a
	di
	out (Input_PPI_PORT_C),a
	ei
	ini
	jr nz,Loop
	ret
	ENDP

; iy = this
Input_UpdateJoystickIY:
	ld a,(iy + Input.newStick)
	ld (iy + Input.oldStick),a
	ld a,Input_PSG_GPIO_B
	di
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
; a <- keyboard mapped as joystick
Input_GetKeyboardAsJoystickIY:
	ld a,(iy + Input.newKey + 6)
	rra
	ld a,(iy + Input.newKey + 8)
	rla
	rla
	rla
	rla
	rla
	and 3FH
	add a,Input_keyboardAsJoystickLUT & 0FFH
	ld l,a
	ld h,Input_keyboardAsJoystickLUT >> 8
	ld a,(hl)
	ret

;
	ALIGN_FIT8 64
Input_keyboardAsJoystickLUT: REPT 64, ?i
	db (?i & 1) << 2 | (?i & 2) >> 1 | (?i & 4) >> 1 | (?i & 8) | (?i & 32) >> 1 | (?i & 16) << 1 | 0C0H
	ENDM
