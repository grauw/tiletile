;
; Sprite pattern table in VRAM
;
SpritePatternTable_SIZE: equ 64 * SpritePattern._size

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

SpritePatternTable_Select: MACRO ?this, ?displaySettings
	ld a,(?this + SpritePatternTable.baseRegister6)
	ld (?displaySettings + DisplaySettings.spritePattern),a
	ENDM

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

; a = sprite pattern number
; iy = this
; c <- write port
SpritePatternTable_SetPatternWriteIY:
	add a,a
	call c,System_ThrowException
	add a,a
	call c,System_ThrowException
	ld l,a
	ld h,0
	add hl,hl
	add hl,hl
	add hl,hl
	call VRAMTable_SetWriteIY
	ret

; c = write port
; hl = sprite pattern
; iy = this
SpritePatternTable_WritePatternIY:
	REPT 32
	outi
	ENDM
	ret
