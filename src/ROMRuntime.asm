;
; ROM runtime
;
ROMRuntime: MACRO ?main
	header:
		db "AB"
		dw Entry
		dw 0, 0, 0, 0, 0, 0
	Entry:
		ld hl,?main
		call System_TryCall
		ret
	ENDM
