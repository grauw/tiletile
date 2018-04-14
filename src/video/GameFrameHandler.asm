;
; Game frame interrupt handler
;
GameFrameHandler_FRAME_LINE: equ 228

GameFrameHandler: MACRO
	super: DisplayFrameHandler Apply
	pending:
		db 0
	handlerPointer:
		dw 0

	; c = VDP port 1
	; Modifies: af, bc, hl
	Apply:
		IF DEBUG
		PROFILE_BEGIN 10
		ENDIF
		ld hl,0
	settings: equ $ - 2
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
		xor a
		ld (pending),a
		IF DEBUG
		PROFILE_END 10
		ENDIF
		jp Interrupt_Return
	ENDM

; ix = this
; iy = interrupt
GameFrameHandler_Construct:
	call Interrupt_GetLineInterruptHandlerPointerIY
	ld (ix + GameFrameHandler.handlerPointer),l
	ld (ix + GameFrameHandler.handlerPointer + 1),h
	ret

; Waits until previous display frame is displayed
; de = game frame settings
; iy = this
GameFrameHandler_SubmitIY:
	call GameFrameHandler_WaitIY
	di
	ld (iy + GameFrameHandler.settings),e
	ei
	ld (iy + GameFrameHandler.settings + 1),d
	ld (iy + GameFrameHandler.pending),1
	push iy
	pop de
	ld l,(iy + GameFrameHandler.handlerPointer)
	ld h,(iy + GameFrameHandler.handlerPointer + 1)
	di
	ld (hl),e
	inc hl
	ei
	ld (hl),d
	ret

; iy = this
GameFrameHandler_WaitIY:
	bit 0,(iy + GameFrameHandler.pending)
	ret z
	IF DEBUG
	PROFILE_BEGIN 29
	ENDIF
	halt
	IF DEBUG
	PROFILE_END 29
	ENDIF
	jr GameFrameHandler_WaitIY
