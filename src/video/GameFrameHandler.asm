;
; Game frame interrupt handler
;
GameFrameHandler: MACRO ?settings
	super: FrameHandler Apply, ?settings

	; c = VDP port 1
	; hl = boot frame
	; Modifies: af, bc, hl
	Apply:
		VDPRegister_SetDI_M  ; horizontal offset (characters)
		VDPRegister_SetDI_M  ; horizontal offset (dots)
		VDPRegister_SetDI_M  ; vertical offset
		VDPRegister_SetDI_M  ; pattern name base
		VDPRegister_SetDI_M  ; sprite attribute base LSB
		VDPRegister_SetDI_M  ; sprite attribute base MSB
		VDPRegister_SetDI_M  ; sprite pattern base
		VDPRegister_SetDI_M  ; interrupt line
		VDPRegister_SetDI_M  ; status register 1
		in a,(c)             ; clear FH
		VDPRegister_SetDI_M  ; status register 2
		VDPRegister_SetDI_M  ; palette index
		ld b,(hl)
		inc hl
		ld h,(hl)
		ld l,b
		inc c
		REPT Palette_COLORS
		PaletteColor_SetDI_M
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
