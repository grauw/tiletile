;
; Frame for boot
;
BootFrame: MACRO
	super: DisplayFrame Apply

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
		ret
	ENDM

; de = palette
; iy = this
BootFrame_SubmitIY:
	di
	ld (iy + BootFrame.palette),e
	ei
	ld (iy + BootFrame.palette + 1),d
	call BootFrame_WaitIY
	ret

; iy = this
BootFrame_WaitIY: PROC
	ld b,(iy + BootFrame.frameCount)
Wait:
	ld a,(iy + BootFrame.frameCount)
	sub b
	jr z,Wait
	ret
	ENDP
