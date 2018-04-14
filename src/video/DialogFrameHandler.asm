;
; Dialog frame interrupt handler
;
DialogFrameHandler: MACRO ?settings, ?next
	super: FrameHandler Apply, ?settings, ?next

	; c = VDP port 1
	; hl = boot frame
	; Modifies: af, bc, hl
	Apply:
		VDPRegister_SetDI_M  ; disable display
		ld b,00100000B
	PollHR:
		in a,(c)
		and b
		jr z,PollHR  ; z: display, nz: h-blank
		VDPRegister_SetDI_M  ; pattern name base
		VDPRegister_SetDI_M  ; vertical offset
		VDPRegister_SetDI_M  ; enable display
		VDPRegister_SetDI_M  ; horizontal offset (characters)
		VDPRegister_SetDI_M  ; horizontal offset (dots)
		VDPRegister_SetDI_M  ; disable sprites
		VDPRegister_SetDI_M  ; set interrupt line
		VDPRegister_SetDI_M  ; status register 1
		in a,(c)             ; clear FH
		VDPRegister_SetDI_M  ; status register 2
		jp super.Return
	ENDM

; ix = this
; iy = interrupt
DialogFrameHandler_Construct:
	call FrameHandler_Construct
	ret
