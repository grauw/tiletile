;
; Frame for overscan
;
OverscanFrame_FRAME_LINE: equ 192

OverscanFrame: MACRO
	super: Frame
	mode9:
		VDPRegister 9
	_size:
	ENDM

; ix = this
OverscanFrame_Construct:
	ld a,(VDP_MIRROR_8 + 9)
	and 01111111B
	ld (ix + OverscanFrame.mode9 + VDPRegister.value),a
	ret
