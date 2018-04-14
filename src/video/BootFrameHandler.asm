;
; Frame for boot
;
BootFrameHandler: MACRO ?settings, ?next
	super: FrameHandler Apply, ?settings, ?next

	; c = VDP port 1
	; hl = boot frame
	; Modifies: af, bc, hl
	Apply:
		VDPRegister_SetDI_M  ; palette index
		ld b,(hl)
		inc hl
		ld h,(hl)
		ld l,b
		inc c
		REPT Palette_COLORS
		PaletteColor_SetDI_M
		ENDM
		jp super.Return
	ENDM

; ix = this
; iy = interrupt
BootFrameHandler_Construct:
	call FrameHandler_Construct
	ret
