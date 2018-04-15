;
; Split for overscan
;
OverscanSplit_FRAME_LINE: equ 192

OverscanSplit: MACRO
	super: Split
	mode9:
		VDPRegister 9
	_size:
	ENDM

; ix = this
OverscanSplit_Construct:
	ld a,(VDP_MIRROR_8 + 9)
	and 01111111B
	ld (ix + OverscanSplit.mode9 + VDPRegister.value),a
	ret
