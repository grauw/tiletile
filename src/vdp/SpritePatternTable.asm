;
; Sprite pattern table in VRAM
;
SpritePatternTable: MACRO ?address
	super: VRAMTable ?address
	baseRegister6:
		db 0
	ENDM

; ix = this
SpritePatternTable_Construct:
	ld a,(ix + VRAMTable.address)
	and a
	call nz,System_ThrowException
	ld a,(ix + VRAMTable.address + 1)
	and 00000111B
	call nz,System_ThrowException
	ld a,(ix + VRAMTable.address + 2)
	and 11111110B
	call nz,System_ThrowException
	ld a,(ix + VRAMTable.address + 2)
	rra
	ld a,(ix + VRAMTable.address + 1)
	rra
	rra
	rra
	ld (ix + SpritePatternTable.baseRegister6),a
	ret

; ix = this
SpritePatternTable_Select:
	ld a,(ix + SpritePatternTable.baseRegister6)
	ld b,6
	call VDP_SetRegister
	ret

; a = sprite pattern number
; ix = this
; c <- write port
SpritePatternTable_SetPatternWrite:
	add a,a
	call c,System_ThrowException
	add a,a
	call c,System_ThrowException
	ld l,a
	ld h,0
	add hl,hl
	add hl,hl
	add hl,hl
	call VRAMTable_SetWrite
	ret
