;
; Overscan frame interrupt handler
;
OverscanFrameHandler: MACRO ?settings, ?next
	super: FrameHandler OverscanFrame_FRAME_LINE, ?settings, ?next

	; c = VDP port 1
	; hl = boot frame
	; Modifies: af, bc, hl
	Apply:
		VDPRegister_SetDI_M  ; mode 9 (192 lines)
		jp super.Return
	ENDM

; ix = this
; iy = interrupt
OverscanFrameHandler_Construct:
	call FrameHandler_Construct
	ret
