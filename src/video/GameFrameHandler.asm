;
; Game frame interrupt handler
;
GameFrameHandler: MACRO
	super: FrameHandler Apply

	; c = VDP port 1
	; hl = boot frame
	; Modifies: af, bc, hl
	Apply:
		VDPRegister_OUTI_DI_M  ; horizontal offset (characters)
		VDPRegister_OUTI_DI_M  ; horizontal offset (dots)
		VDPRegister_OUTI_DI_M  ; vertical offset
		VDPRegister_OUTI_DI_M  ; pattern name base
		VDPRegister_OUTI_DI_M  ; sprite attribute base LSB
		VDPRegister_OUTI_DI_M  ; sprite attribute base MSB
		VDPRegister_OUTI_DI_M  ; sprite pattern base
		VDPRegister_OUTI_DI_M  ; interrupt line
		VDPRegister_OUTI_DI_M  ; status register 1
		in a,(c)               ; clear FH
		VDPRegister_OUTI_DI_M  ; status register 2
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
GameFrameHandler_Construct:
	call FrameHandler_Construct
	ret

; de = game frame
; iy = this
GameFrameHandler_SubmitIY: equ FrameHandler_SubmitIY

; iy = this
GameFrameHandler_WaitIY: equ FrameHandler_WaitIY
