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

; hl = source offset
; de = destination offset
; bc = byte count
; ix = source table (this)
; iy = destination table
VRAMTable_Copy:
	ld a,l
	or e
	or c
	and 7FH
	call nz,System_ThrowException
	push de
	ld e,(ix + VRAMTable.address)
	ld d,(ix + VRAMTable.address + 1)
	add hl,de
	ld a,(ix + VRAMTable.address + 2)
	adc a,0
	add hl,hl
	adc a,a
	push iy
	ld iy,VRAMTable_copyCommand
	ld (iy + VDPCommand.sy),h
	ld (iy + VDPCommand.sy + 1),a
	pop iy
	pop de
	ld l,(iy + VRAMTable.address)
	ld h,(iy + VRAMTable.address + 1)
	add hl,de
	ld a,(iy + VRAMTable.address + 2)
	adc a,0
	add hl,hl
	adc a,a
	push iy
	ld iy,VRAMTable_copyCommand
	ld (iy + VDPCommand.dy),h
	ld (iy + VDPCommand.dy + 1),a
	xor a
	sla c
	rl b
	rla
	ld (iy + VDPCommand.ny),b
	ld (iy + VDPCommand.ny + 1),a
	call VDPCommand_Execute_IY
	pop iy
	ret

;
	SECTION RAM

VRAMTable_copyCommand: VDPCommand 0, 0, 0, 0, 100H, 0, 0, 0, VDPCommand_YMMM

	ENDS
