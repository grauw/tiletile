;
; Pattern name table in VRAM
;
PatternNameTable_SIZE: equ 8000H

PatternNameTable: MACRO ?address
	super: VRAMTable ?address
	baseRegister2:
		db 0
	ENDM

; ix = this
PatternNameTable_Construct:
	ld a,(ix + VRAMTable.address)
	and a
	call nz,System_ThrowException
	ld a,(ix + VRAMTable.address + 1)
	and 01111111B
	call nz,System_ThrowException
	ld a,(ix + VRAMTable.address + 2)
	and 11111110B
	call nz,System_ThrowException
	ld a,(ix + VRAMTable.address + 2)
	rra
	ld a,(ix + VRAMTable.address + 1)
	rra
	rra
	and 01111111B
	or 00011111B
	ld (ix + PatternNameTable.baseRegister2),a
	ret

; hl = offset
; iy = this
; c <- write port
PatternNameTable_SetPatternNameWriteIY: equ VRAMTable_SetWriteIY
