;
; Game frame interrupt handler
;
GameFrameHandler_FRAME_LINE: equ 228

GameFrameHandler: MACRO
	super: DisplayFrameHandler Apply

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
	call DisplayFrameHandler_Construct
	ret

; Waits until previous frame is displayed
; de = game frame
; iy = this
GameFrameHandler_SubmitIY: equ DisplayFrameHandler_SubmitIY

; iy = this
GameFrameHandler_WaitIY: equ DisplayFrameHandler_WaitIY
