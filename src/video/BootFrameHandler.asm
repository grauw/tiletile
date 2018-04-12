;
; Frame for boot
;
BootFrameHandler: MACRO
	super: DisplayFrameHandler Apply

	frameCount:
		db 0
	registers:
		VDPRegister 16, 0
	palette:
		dw Palette_system

	; c = VDP port 1
	; Modifies: af, bc, hl
	Apply:
		ld hl,registers
		VDPRegister_OUTI_DI_M  ; palette number
		inc c
		ld hl,(palette)
		REPT 32
		outi
		ENDM
		ld a,(frameCount)
		inc a
		ld (frameCount),a
		jp Interrupt_Return
	ENDM

; de = palette
; iy = this
BootFrameHandler_SubmitIY:
	di
	ld (iy + BootFrameHandler.palette),e
	ei
	ld (iy + BootFrameHandler.palette + 1),d
	call BootFrameHandler_WaitIY
	ret

; iy = this
BootFrameHandler_WaitIY: PROC
	ld b,(iy + BootFrameHandler.frameCount)
Wait:
	ld a,(iy + BootFrameHandler.frameCount)
	sub b
	jr z,Wait
	ret
	ENDP
