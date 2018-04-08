;
; VDP command to copy between VRAM tables
;
VRAMTableCopy: MACRO ?source = 0, ?destination = 0, ?size = 0
	super: VDPCommand 0, ?source >> 7, 0, ?destination >> 7, 100H, ?size >> 7, 0, 0, VDPCommand_YMMM
	ENDM

; hl = offset
; ix = VRAM table
; iy = this
VRAMTableCopy_SetSourceIY:
	ld a,l
	and 7FH
	call nz,System_ThrowException
	ld e,(ix + VRAMTable.address)
	ld d,(ix + VRAMTable.address + 1)
	add hl,de
	ld a,(ix + VRAMTable.address + 2)
	adc a,0
	add hl,hl
	adc a,a
	ld (iy + VDPCommand.sy),h
	ld (iy + VDPCommand.sy + 1),a
	ret

; hl = offset
; ix = VRAM table
; iy = this
VRAMTableCopy_SetDestinationIY:
	ld a,l
	and 7FH
	call nz,System_ThrowException
	ld e,(ix + VRAMTable.address)
	ld d,(ix + VRAMTable.address + 1)
	add hl,de
	ld a,(ix + VRAMTable.address + 2)
	adc a,0
	add hl,hl
	adc a,a
	ld (iy + VDPCommand.dy),h
	ld (iy + VDPCommand.dy + 1),a
	ret

; bc = byte count
; iy = this
VRAMTableCopy_SetSizeIY:
	ld a,c
	and 7FH
	call nz,System_ThrowException
	xor a
	sla c
	rl b
	rla
	ld (iy + VDPCommand.ny),b
	ld (iy + VDPCommand.ny + 1),a
	ret

; ix = this
VRAMTableCopy_Execute: equ VDPCommand_ExecuteS2

; iy = this
VRAMTableCopy_ExecuteIY: equ VDPCommand_ExecuteS2IY

; hl = this
VRAMTableCopy_ExecuteHL: equ VDPCommand_ExecuteS2HL
