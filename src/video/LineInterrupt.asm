;
; Line interrupt
;
LineInterrupt: MACRO ?handler
	Entry:
		push af
		push bc
		push hl
		ld bc,(15 | VDP_REGISTER) << 8 | VDP_PORT_1
		ld hl,2 << 8 | 1
		out (c),l
		out (c),b  ; select s#1
		in (c)
		out (c),h
		out (c),b  ; select s#2
		jp pe,?handler  ; V9958 has no light pen bits, and VDP ID is 2
	handler: equ $ - 2
		xor a
		out (c),a
		out (c),b  ; select s#0
		call OldHook
		di  ; small window for reentrant interrupt to occur
		out (c),h
		out (c),b  ; select s#2
		jp LineInterrupt_Return
	OldHook:
		ds Interrupt_HOOK_SIZE
	ENDM

	SECTION RAM

LineInterrupt_Return:
		pop hl
		pop bc
		pop af
		ei
		ret

	ENDS

; ix = interrupt
; iy = this
LineInterrupt_ConstructIY:
	ld e,iyl
	ld d,iyh
	ld hl,LineInterrupt.OldHook
	add hl,de
	ex de,hl
	ld hl,LineInterrupt.Entry - LineInterrupt.OldHook
	add hl,de
	call Interrupt_Hook
	ld a,2
	ld b,15
	call VDP_SetRegister  ; select s#2
	ret

; ix = interrupt
; iy = this
LineInterrupt_DestructIY:
	ld e,iyl
	ld d,iyh
	ld hl,LineInterrupt.OldHook
	add hl,de
	ex de,hl
	ld hl,LineInterrupt.Entry - LineInterrupt.OldHook
	add hl,de
	di
	call Interrupt_Unhook
	ld a,0
	ld b,15
	call VDP_SetRegister  ; select s#0
	ei
	ret

; a = line
LineInterrupt_Enable:
	ld b,19
	call VDP_SetRegister
	ld a,(VDP_MIRROR_0 + 0)
	set 4,a
	ld (VDP_MIRROR_0 + 0),a
	ld b,0
	call VDP_SetRegister
	ret

; ix = interrupt
; iy = this
LineInterrupt_Disable:
	ld a,(VDP_MIRROR_0 + 0)
	res 4,a
	ld (VDP_MIRROR_0 + 0),a
	ld b,0
	call VDP_SetRegister
	ret
