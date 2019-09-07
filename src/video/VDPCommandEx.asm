;
; VDP command additions
;

; ix = this
; Modifies: af, bc, hl
VDPCommand_ExecuteS2:
	push ix
	pop hl
	jp VDPCommand_ExecuteS2HL

; iy = this
; Modifies: af, bc, hl
VDPCommand_ExecuteS2IY:
	push iy
	pop hl
	jp VDPCommand_ExecuteS2HL

; Modifies: af
VDPCommand_WaitReadyS2:
	in a,(VDP_PORT_1)
	rra
	jr c,VDPCommand_WaitReadyS2
	ret

; hl = this
; Modifies: af, bc, hl
VDPCommand_ExecuteS2HL: PROC
	ld c,VDP_PORT_3
	ld a,32
	di
	out (VDP_PORT_1),a
	ld a,17 | VDP_REGISTER
	ei
	out (VDP_PORT_1),a
WaitReady:
	in a,(VDP_PORT_1)
	rra
	jr c,WaitReady
	REPT 15
	outi
	ENDM
	ret
	ENDP

; a = start register offset
; c <- command port
; Modifies: af
VDPCommand_PrepareCommandS2: PROC
	ld c,VDP_PORT_3
	add a,32
	di
	out (VDP_PORT_1),a
	ld a,17 | VDP_REGISTER
	ei
	out (VDP_PORT_1),a
WaitReady:
	in a,(VDP_PORT_1)
	rra
	jr c,WaitReady
	ret
	ENDP
