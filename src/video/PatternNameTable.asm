;
; Pattern name table in VRAM
;
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

; ix = this
PatternNameTable_Select:
	ld a,(ix + PatternNameTable.baseRegister2)
	ld b,2
	call VDP_SetRegister
	ret

; hl = offset
; ix = this
; c <- write port
PatternNameTable_SetPatternNameWrite:
	add a,a
	add a,a
	ld l,a
	ld h,0
	call VRAMTable_SetWrite
	ret

; hl = offset
; iy = this
; c <- write port
PatternNameTable_SetPatternNameWriteIY:
	add a,a
	add a,a
	ld l,a
	ld h,0
	call VRAMTable_SetWriteIY
	ret
