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
