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
	ld e,(ix + VRAMTable.address)
	ld d,(ix + VRAMTable.address + 1)
	add hl,de
	ld a,(ix + VRAMTable.address + 2)
	adc a,0
	call VDP_SetWriteAddress
	ld c,VDP_PORT_0
	ret

; hl = offset
; iy = this
; c <- write port
VRAMTable_SetWriteIY:
	ld e,(iy + VRAMTable.address)
	ld d,(iy + VRAMTable.address + 1)
	add hl,de
	ld a,(iy + VRAMTable.address + 2)
	adc a,0
	call VDP_SetWriteAddress
	ld c,VDP_PORT_0
	ret
