;
; Interrupt handler to display a frame.
; Or, the framing of the display.
;
DisplayFrameHandler_FRAME_LINE: equ 228

DisplayFrameHandler: MACRO ?entry
	Entry:
		jp ?entry
	ENDM
