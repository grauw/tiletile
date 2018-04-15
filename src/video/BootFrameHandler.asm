;
; Frame for boot
;
BootFrameHandler: MACRO ?settings, ?next
	super: FrameHandler BootFrame_FRAME_LINE, ?settings, ?next

	; c = VDP port 1
	; hl = boot frame
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
BootFrameHandler_Construct:
	call FrameHandler_Construct
	ret
