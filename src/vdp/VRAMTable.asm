;
; Table in VRAM
;
VRAMTable: MACRO ?address
	address:
		dw ?address & 0FFFFH
		db ?address >> 16
	ENDM

; hl = offset
; ix = this
; c <- write port
VRAMTable_SetWrite:
	rl h
	sbc a,a
	rr h
	ld e,(ix + VRAMTable.address)
	ld d,(ix + VRAMTable.address + 1)
	add hl,de
	adc a,(ix + VRAMTable.address + 2)
	call VDP_SetWriteAddress
	ld c,VDP_PORT_0
	ret
