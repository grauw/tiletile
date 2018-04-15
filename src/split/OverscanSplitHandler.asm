;
; Overscan split interrupt handler
;
OverscanSplitHandler: MACRO ?settings, ?next
	super: SplitHandler OverscanSplit_FRAME_LINE, ?settings, ?next

	; c = VDP port 1
	; hl = boot split
	; Modifies: af, bc, hl
	Apply:
		VDPRegister_SetDI_M  ; mode 9 (192 lines)
		jp super.Return
	ENDM

; ix = this
; iy = interrupt
OverscanSplitHandler_Construct:
	call SplitHandler_Construct
	ret
