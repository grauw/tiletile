;
; Frame for boot
;
BootFrameHandler: MACRO
	super: DisplayFrameHandler Apply

	; c = VDP port 1
	; hl = boot frame
	; Modifies: af, bc, hl
	Apply:
		VDPRegister_OUTI_DI_M  ; palette number
		inc c
		ld b,(hl)
		inc hl
		ld h,(hl)
		ld l,b
		REPT 32
		outi
		ENDM
		jp super.Return
	ENDM

; ix = this
; iy = interrupt
BootFrameHandler_Construct:
	call DisplayFrameHandler_Construct
	ret

; Waits until previous frame is displayed
; de = boot frame
; iy = this
BootFrameHandler_SubmitIY: equ DisplayFrameHandler_SubmitIY

; iy = this
BootFrameHandler_WaitIY: equ DisplayFrameHandler_WaitIY
