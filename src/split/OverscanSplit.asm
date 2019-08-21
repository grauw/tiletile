;
; Split for overscan
;
OverscanSplit_LINE: equ 212 - 3

OverscanSplit: MACRO
	super:
		Split
	mode9_192:
		VDPRegister 9
		VDPRegister 15, 2
	mode9_212:
		VDPRegister 9
	_size:
	ENDM

; ix = this
OverscanSplit_Construct:
	ret

OverscanSplit_UpdateMode9_M: MACRO ?this
	ld a,(VDP_MIRROR_8 + 9)
	and 01111111B
	ld (?this + OverscanSplit.mode9_192.value),a
	or 10000000B
	ld (?this + OverscanSplit.mode9_212.value),a
	ENDM
