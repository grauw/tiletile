;
; Dialog split interrupt handler
;
DialogSplitHandler: MACRO ?settings, ?next
	super: SplitHandler DialogSplit_LINE, ?settings, ?next

	; c = VDP port 1
	; hl = dialog split
	; Modifies: af, bc, hl
	Apply:
		VDPRegister_SetDI_M  ; disable display
		VDPRegister_SetDI_M  ; status register 2
		Split_PollHR_M
		VDPRegister_SetDI_M  ; enable display
		VDPRegister_SetDI_M  ; pattern name base
		VDPRegister_SetDI_M  ; vertical offset 1
		Split_PollHR_M
		VDPRegister_SetDI_M  ; horizontal offset (characters)
		VDPRegister_SetDI_M  ; horizontal offset (dots)
		VDPRegister_SetDI_M  ; disable sprites
		Split_PollHR_M
		Split_PollHRStart_M
		ld a,(hl)
		ld (VDP_MIRROR_8 + 23),a
		Split_PollHRStart_M
		VDPRegister_SetDI_M  ; vertical offset 2
		jp super.Return
	ENDM

; ix = this
; iy = interrupt
DialogSplitHandler_Construct:
	call SplitHandler_Construct
	ret
