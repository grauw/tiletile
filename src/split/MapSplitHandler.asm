;
; Map split interrupt handler
;
MapSplitHandler: MACRO ?settings, ?next
	super: SplitHandler MapSplit_LINE, ?settings, ?next

	; c = VDP port 1
	; hl = map split
	; Modifies: af, bc, hl
	Apply:
		VDPRegister_SetDI_M  ; horizontal offset (characters)
		VDPRegister_SetDI_M  ; horizontal offset (dots)
		ld a,(hl)
		VDPRegister_SetDI_M  ; vertical offset
		VDPRegister_SetDI_M  ; pattern name base
		VDPRegister_SetDI_M  ; sprite attribute base LSB
		VDPRegister_SetDI_M  ; sprite attribute base MSB
		VDPRegister_SetDI_M  ; sprite pattern base
		VDPRegister_SetDI_M  ; palette index
		ld b,(hl)
		inc hl
		ld h,(hl)
		ld l,b
		inc c
		REPT Palette_COLORS
		PaletteColor_SetDI_M
		ENDM
		ld (VDP_MIRROR_8 + 23),a
		dec c
		jp super.Return
	ENDM

; ix = this
; iy = interrupt
MapSplitHandler_Construct:
	call SplitHandler_Construct
	ld a,(VDP_MIRROR_8 + 18)
	sra a
	sra a
	sra a
	sra a
	add a,MapSplit_LINE
	ld (ix + MapSplitHandler.super.line),a
	ret
