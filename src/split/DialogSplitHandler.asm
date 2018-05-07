;
; Dialog split interrupt handler
;
DialogSplitHandler: MACRO ?settings, ?next
	super: SplitHandler DialogSplit_LINE, ?settings, ?next

	; c = VDP port 1
	; hl = dialog split
	; Modifies: af, bc, hl
	Apply:
		VDPRegister_SetDI_M  ; status register 2
		Split_PollHREnd_M
		VDPRegister_SetDI_M  ; palette index
		VDPRegister_SetDI_M  ; disable display
		VDPRegister_SetDI_M  ; disable sprites
		Split_PollHR_M
		VDPRegister_SetDI_M  ; pattern name base
		VDPRegister_SetDI_M  ; vertical offset 1
		inc c
		PaletteColor_SetDI_M  ; color 10
		dec c
		VDPRegister_SetDI_M  ; enable display
		Split_PollHR_M
		VDPRegister_SetDI_M  ; horizontal offset (characters)
		VDPRegister_SetDI_M  ; horizontal offset (dots)
		inc c
		PaletteColor_SetDI_M  ; color 11
		PaletteColor_SetDI_M  ; color 12
		dec c
		Split_PollHR_M
		inc c
		PaletteColor_SetDI_M  ; color 13
		PaletteColor_SetDI_M  ; color 14
		PaletteColor_SetDI_M  ; color 15
		dec c
		Split_PollHR_M
		ld a,(hl)
		ld (VDP_MIRROR_8 + 23),a
		Split_PollHRStart_M
		VDPRegister_SetDI_M  ; vertical offset 2
		VDPRegister_SetDI_M  ; palette index
		inc c
		PaletteColor_SetDI_M  ; color 10
		PaletteColor_SetDI_M  ; color 11
		dec c
		jp super.Return
	ENDM

; ix = this
; iy = interrupt
DialogSplitHandler_Construct:
	call SplitHandler_Construct
	ret
