;
; Game frame interrupt handler
;
GameFrameHandler_FRAME_LINE: equ 228

GameFrameHandler: MACRO
	super: DisplayFrameHandler Apply
	pending:
		db 0

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

; Waits until previous display frame is displayed
; de = game frame settings
; iy = this
GameFrameHandler_SubmitIY:
	call GameFrameHandler_WaitIY
	di
	ld (iy + GameFrameHandler.settings),e
	ld (iy + GameFrameHandler.settings + 1),d
	ei
	ld (iy + GameFrameHandler.pending),1
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
