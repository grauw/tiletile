;
; Dialog split interrupt handler
;
DialogSplitHandler: MACRO ?settings, ?next
	super: SplitHandler DialogSplit_FRAME_LINE - 2, ?settings, ?next

	; c = VDP port 1
	; hl = boot split
	; Modifies: af, bc, hl
	Apply:
		VDPRegister_SetDI_M  ; disable display
		VDPRegister_SetDI_M  ; status register 2
		ld b,00100000B
	PollHR:
		in a,(c)
		and b
		jr z,PollHR  ; z: display, nz: h-blank
		VDPRegister_SetDI_M  ; enable display
		VDPRegister_SetDI_M  ; pattern name base
		ld a,(hl)
		VDPRegister_SetDI_M  ; vertical offset
		VDPRegister_SetDI_M  ; horizontal offset (characters)
		VDPRegister_SetDI_M  ; horizontal offset (dots)
		VDPRegister_SetDI_M  ; disable sprites
		ld (VDP_MIRROR_8 + 23),a
		jp super.Return
	ENDM

; ix = this
; iy = interrupt
DialogSplitHandler_Construct:
	call SplitHandler_Construct
	ret
