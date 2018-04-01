;
; Line interrupt
;
LineInterrupt: MACRO ?line, ?handler
	installed:
		db 0
	Entry:
		push af
		ld a,1
		out (VDP_PORT_1),a  ; select s#2
		ld a,15 | VDP_REGISTER
		out (VDP_PORT_1),a
		in a,(VDP_PORT_1)
		rra
		ld a,0
		out (VDP_PORT_1),a  ; select s#0
		ld a,15 | VDP_REGISTER
		out (VDP_PORT_1),a
		jr nc,NotLine
		call ?handler
		ld a,(VDP_MIRROR_8 + 23)
		add a,?line
	line: equ $ - 1
		out (VDP_PORT_1),a
		ld a,19 | VDP_REGISTER
		out (VDP_PORT_1),a
		pop af
		ei
		ret
	NotLine:
		pop af
	OldHook:
		ds Interrupt_HOOK_SIZE
	ENDM

; ix = interrupt
; iy = this
LineInterrupt_InstallIY:
	bit 0,(iy + LineInterrupt.installed)
	call nz,System_ThrowException
	ld e,iyl
	ld d,iyh
	ld hl,LineInterrupt.OldHook
	add hl,de
	ex de,hl
	ld hl,LineInterrupt.Entry - LineInterrupt.OldHook
	add hl,de
	call Interrupt_Hook
	ld a,(VDP_MIRROR_8 + 23)
	add a,(iy + LineInterrupt.line)
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
	call Interrupt_Unhook
	ld (iy + LineInterrupt.installed),0
	ret
