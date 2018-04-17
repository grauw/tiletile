;
; Split for boot
;
BootSplitHandler: MACRO ?settings, ?next
	super: SplitHandler BootSplit_LINE, ?settings, ?next

	; c = VDP port 1
	; hl = boot split
	; Modifies: af, bc, hl
	Apply:
		ld b,(hl)
		inc hl
		ld h,(hl)
		ld l,b
		inc c
		REPT Palette_COLORS
		PaletteColor_SetDI_M
		ENDM
		dec c
		jp super.Return
	ENDM

; ix = this
; iy = interrupt
BootSplitHandler_Construct:
	call SplitHandler_Construct
	ld a,(VDP_MIRROR_8 + 18)
	sra a
	sra a
	sra a
	sra a
	add a,BootSplit_LINE
	ld (ix + BootSplitHandler.super.line),a
	ret
