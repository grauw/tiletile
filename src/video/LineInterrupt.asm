;
; Line interrupt
;
LineInterrupt: MACRO ?handler
	installed:
		db 0
	Entry:
		push af
		ld a,1
		out (VDP_PORT_1),a  ; select s#1
		ld a,15 | VDP_REGISTER
		out (VDP_PORT_1),a
		in a,(VDP_PORT_1)
		rra
		jr nc,NotLine
		call ?handler
	handler: equ $ - 2
	Return:
		ld a,2
		out (VDP_PORT_1),a  ; select s#2
		ld a,15 | VDP_REGISTER
		out (VDP_PORT_1),a
		pop af
		ei
		ret
	NotLine:
		xor a
		out (VDP_PORT_1),a  ; select s#0
		ld a,15 | VDP_REGISTER
		out (VDP_PORT_1),a
		call OldHook
		di  ; small window for reentrant interrupt to occur
		jr Return
	OldHook:
		ds Interrupt_HOOK_SIZE
	ENDM

; a = line
; ix = interrupt
; iy = this
LineInterrupt_InstallIY:
	bit 0,(iy + LineInterrupt.installed)
	call nz,System_ThrowException
	push af
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
	pop af
	ld b,19
	call VDP_SetRegister
	ld a,(VDP_MIRROR_0 + 0)
	set 4,a
	ld (VDP_MIRROR_0 + 0),a
	ld b,0
	call VDP_SetRegister
	ld (iy + LineInterrupt.installed),1
	ret

; ix = interrupt
; iy = this
LineInterrupt_UninstallIY:
	bit 0,(iy + LineInterrupt.installed)
	call z,System_ThrowException
	ld a,(VDP_MIRROR_0 + 0)
	res 4,a
	ld (VDP_MIRROR_0 + 0),a
	ld b,0
	call VDP_SetRegister
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
	ld (iy + LineInterrupt.installed),0
	ret
