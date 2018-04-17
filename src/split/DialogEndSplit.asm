;
; Split for dialog
;
DialogEndSplit_LINE: equ 208

DialogEndSplit: MACRO
	super: Split
		VDPRegister 15, 2
	horizontalOffsetCharacters:
		VDPRegister 26
	horizontalOffsetDots:
		VDPRegister 27
	mode1Blank:
		VDPRegister 1
	verticalOffset:
		VDPRegister 23
	mode8:
		VDPRegister 8
	mode1Display:
		VDPRegister 1
		VDPRegister 2, 0 << 5 | 00011111B
	_size:
	ENDM

; ix = this
DialogEndSplit_Construct:
	ld a,(VDP_MIRROR_0 + 1)
	and 10111111B
	ld (ix + DialogEndSplit.mode1Blank + VDPRegister.value),a
	or 01000000B
	ld (ix + DialogEndSplit.mode1Display + VDPRegister.value),a
	ld a,(VDP_MIRROR_8 + 8)
	and 11111101B
	ld (ix + DialogEndSplit.mode8 + VDPRegister.value),a
	ret

DialogEndSplit_SetDisplayOffset_M: MACRO ?this, ?displayOffset
	ld a,(?displayOffset + DisplayOffset.horizontalOffsetCharacters)
	ld (?this + DialogEndSplit.horizontalOffsetCharacters + VDPRegister.value),a
	ld a,(?displayOffset + DisplayOffset.horizontalOffsetDots)
	ld (?this + DialogEndSplit.horizontalOffsetDots + VDPRegister.value),a
	ld a,(?displayOffset + DisplayOffset.verticalOffset)
	ld (?this + DialogEndSplit.verticalOffset + VDPRegister.value),a
	ENDM
