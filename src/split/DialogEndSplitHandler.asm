;
; Dialog split interrupt handler
;
DialogEndSplitHandler: MACRO ?settings, ?next
	super:
		SplitHandler DialogEndSplit_LINE, ?settings, ?next

	; c = VDP port 1
	; hl = dialog end split
	; Modifies: af, bc, hl
	Apply:
		VDPRegister_SetDI_M  ; status register 2
		Split_PollHR_M
		VDPRegister_SetDI_M  ; vertical offset 1
		Split_PollHRStart_M
		VDPRegister_SetDI_M  ; palette index
		inc c
		PaletteColor_SetDI_M  ; color 12
		PaletteColor_SetDI_M  ; color 13
		dec c
		Split_PollHRStart_M
		inc c
		PaletteColor_SetDI_M  ; color 14
		dec c
		VDPRegister_SetDI_M  ; horizontal offset (characters)
		VDPRegister_SetDI_M  ; horizontal offset (dots)
		VDPRegister_SetDI_M  ; disable display
		Split_PollHR_M
		VDPRegister_SetDI_M  ; pattern name base
		inc c
		PaletteColor_SetDI_M  ; color 15
		dec c
		VDPRegister_SetDI_M  ; enable sprites
		VDPRegister_SetDI_M  ; enable display
		ld a,(hl)
		VDPRegister_SetDI_M  ; vertical offset 2
		ld (VDP_MIRROR_8 + 23),a
		jp super.Return
	ENDM

; ix = this
; iy = interrupt
DialogEndSplitHandler_Construct:
	call SplitHandler_Construct
	ret
