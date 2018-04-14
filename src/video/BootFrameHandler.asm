;
; Frame for boot
;
BootFrameHandler: MACRO
	super: DisplayFrameHandler Apply
	frameCount:
		db 0
	handlerPointer:
		dw 0

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

; ix = this
; iy = interrupt
BootFrameHandler_Construct:
	call Interrupt_GetLineInterruptHandlerPointerIY
	ld (ix + BootFrameHandler.handlerPointer),l
	ld (ix + BootFrameHandler.handlerPointer + 1),h
	ret

; de = palette
; iy = this
BootFrameHandler_SubmitIY:
	di
	ld (iy + BootFrameHandler.palette),e
	ei
	ld (iy + BootFrameHandler.palette + 1),d
	push iy
	pop de
	ld l,(iy + BootFrameHandler.handlerPointer)
	ld h,(iy + BootFrameHandler.handlerPointer + 1)
	di
	ld (hl),e
	inc hl
	ei
	ld (hl),d
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
