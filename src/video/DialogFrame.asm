;
; Frame for dialog
;
DialogFrame_FRAME_LINE: equ 160

DialogFrame: MACRO
	super: Frame
	mode1Blank:
		VDPRegister 1
		VDPRegister 15, 2
	mode1Display:
		VDPRegister 1
		VDPRegister 2, 3 << 5 | 00011111B
	verticalOffset:
		VDPRegister 23, -DialogFrame_FRAME_LINE
		VDPRegister 26, 0
		VDPRegister 27, 0
	mode8:
		VDPRegister 8
	_size:
	ENDM

; ix = this
DialogFrame_Construct:
	ld a,(VDP_MIRROR_0 + 1)
	and 10111111B
	ld (ix + DialogFrame.mode1Blank + VDPRegister.value),a
	or 01000000B
	ld (ix + DialogFrame.mode1Display + VDPRegister.value),a
	ld a,(VDP_MIRROR_8 + 8)
	or 00000010B
	ld (ix + DialogFrame.mode8 + VDPRegister.value),a
	ret
