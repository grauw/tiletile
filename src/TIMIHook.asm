;
; Timer interrupt hook
;
TIMIHook: MACRO
	super: Hook H.TIMI, Entry, OldHook
	Entry:
		push af
		xor a  ; disable part of the BIOS ISR
		ld (INTCNT),a
		ld (SCNCNT),a
		pop af
	OldHook:
		ds 5
	ENDM
