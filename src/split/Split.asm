;
; Settings for the split interrupt handler.
;
	INCLUDE "SplitHandler.asm"
	INCLUDE "BootSplit.asm"
	INCLUDE "BootSplitHandler.asm"
	INCLUDE "MapSplit.asm"
	INCLUDE "MapSplitHandler.asm"
	INCLUDE "DialogSplit.asm"
	INCLUDE "DialogSplitHandler.asm"
	INCLUDE "OverscanSplit.asm"
	INCLUDE "OverscanSplitHandler.asm"

Split: MACRO
	ENDM

; Have status register 2 selected.
; c = VDP port 1
; Modifies: af, b
Split_PollHR_M: MACRO
	ld b,00100000B
Loop:
	in a,(c)
	and b
	jr z,Loop  ; z: display, nz: h-blank
	ENDM
