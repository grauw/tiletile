;
; Frame for boot
;
BootFrameHandler: MACRO
	super: DisplayFrameHandler Apply
	frameCount:
		db 0
	handlerPointer:
		dw 0

	; c = VDP port 1
	; Modifies: af, bc, hl
	Apply:
		ld hl,0
	settings: equ $ - 2
		VDPRegister_OUTI_DI_M  ; palette number
		inc c
		ld b,(hl)
		inc hl
		ld h,(hl)
		ld l,b
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

; de = boot frame
; iy = this
BootFrameHandler_SubmitIY:
	di
	ld (iy + BootFrameHandler.settings),e
	ei
	ld (iy + BootFrameHandler.settings + 1),d
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
