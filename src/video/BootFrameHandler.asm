;
; Frame for boot
;
BootFrameHandler: MACRO
	super: FrameHandler Apply

	; c = VDP port 1
	; hl = boot frame
	; Modifies: af, bc, hl
	Apply:
		VDPRegister_SetDI_M  ; palette index
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
	call FrameHandler_Construct
	ret

; de = boot frame
; iy = this
BootFrameHandler_SubmitIY: equ FrameHandler_SubmitIY

; iy = this
BootFrameHandler_WaitIY: equ FrameHandler_WaitIY
