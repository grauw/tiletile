;
;
;
VDPRegister: MACRO ?address = 0, ?value = 0
	value:
		db ?value
	address:
		db ?address | VDP_REGISTER
	ENDM

; c = VDP port 1
; hl = this
; hl <- updated
; Modifies: f, b
VDPRegister_SetDI_M: MACRO
	outi
	outi
	ENDM
