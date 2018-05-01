;
; Dialog split interrupt handler
;
DialogEndSplitHandler: MACRO ?settings, ?next
	super: SplitHandler DialogEndSplit_LINE, ?settings, ?next

	; c = VDP port 1
	; hl = dialog end split
	; Modifies: af, bc, hl
	Apply:
		VDPRegister_SetDI_M  ; status register 2
		Split_PollHR_M
		VDPRegister_SetDI_M  ; horizontal offset (characters)
		VDPRegister_SetDI_M  ; horizontal offset (dots)
		VDPRegister_SetDI_M  ; disable display
		ld a,(hl)
		ld (VDP_MIRROR_8 + 23),a
		Split_PollHR_M
		VDPRegister_SetDI_M  ; vertical offset
		VDPRegister_SetDI_M  ; enable sprites
		VDPRegister_SetDI_M  ; enable display
		VDPRegister_SetDI_M  ; pattern name base
		jp super.Return
	ENDM

; ix = this
; iy = interrupt
DialogEndSplitHandler_Construct:
	call SplitHandler_Construct
	ret
