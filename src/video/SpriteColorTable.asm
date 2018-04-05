;
; Sprite color table in VRAM
;
SpriteColorTable_SIZE: equ 32 * SpriteColor._size

SpriteColorTable: MACRO ?address
	super: VRAMTable ?address
	baseRegister5:
		db 0
	baseRegister11:
		db 0
	ENDM

; ix = this
SpriteColorTable_Construct:
	ld a,(ix + VRAMTable.address)
	and a
	call nz,System_ThrowException
	ld a,(ix + VRAMTable.address + 1)
	and 00000011B
	call nz,System_ThrowException
	ld a,(ix + VRAMTable.address + 2)
	and 11111110B
	call nz,System_ThrowException
	ld a,(ix + VRAMTable.address + 1)
	rla
	push af
	or 00000011B
	ld (ix + SpriteColorTable.baseRegister5),a
	pop af
	ld a,(ix + VRAMTable.address + 2)
	rla
	ld (ix + SpriteColorTable.baseRegister11),a
	ret

SpriteColorTable_Select: MACRO ?this, ?displaySettings
	ld a,(?this + SpriteColorTable.baseRegister5)
	ld (?displaySettings + SpriteColorTable.spriteAttributeLSB),a
	ld a,(?this + SpriteColorTable.baseRegister11)
	ld (?displaySettings + SpriteColorTable.spriteAttributeMSB),a
	ENDM

; a = sprite number
; iy = this
; c <- write port
SpriteColorTable_SetColorWriteIY:
	add a,a
	add a,a
	add a,a
	add a,a
	ld l,a
	ld h,0
	rl h
	jp VRAMTable_SetWriteIY

; c = write port
; hl = sprite color
; iy = this
SpriteColorTable_WriteColorIY:
	REPT 16
	outi
	ENDM
	ret
