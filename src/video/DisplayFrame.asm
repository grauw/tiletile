;
; Interrupt handler to display a frame.
; Or, the framing of the display.
;
DisplayFrame_FRAME_LINE: equ 228

DisplayFrame: MACRO ?entry
	Entry:
		jp ?entry
	ENDM
