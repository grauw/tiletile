;
; Split for overscan
;
OverscanSplit_LINE: equ 212 - 2

OverscanSplit: MACRO
	super: Split
	mode9_192:
		VDPRegister 9
		VDPRegister 15, 2
	mode9_212:
		VDPRegister 9
	_size:
	ENDM

; ix = this
OverscanSplit_Construct:
	ld a,(VDP_MIRROR_8 + 9)
	and 01111111B
	ld (ix + OverscanSplit.mode9_192 + VDPRegister.value),a
	ld a,(VDP_MIRROR_8 + 9)
	or 10000000B
	ld (ix + OverscanSplit.mode9_212 + VDPRegister.value),a
	ret
