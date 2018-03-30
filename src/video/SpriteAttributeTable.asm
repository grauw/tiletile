;
; Sprite attribute table in VRAM
;
SpriteAttributeTable: MACRO ?address
	super: VRAMTable ?address
	baseRegister5:
		db 0
	baseRegister11:
		db 0
	worldOffsetX:
		db 8
	worldOffsetY:
		db -1
	cameraOffsetX:
		db 8
	cameraOffsetY:
		db -1
	ENDM

; ix = this
SpriteAttributeTable_Construct:
	ld a,(ix + VRAMTable.address)
	and a
	call nz,System_ThrowException
	ld a,(ix + VRAMTable.address + 1)
	and 00000011B
	cp 00000010B
	call nz,System_ThrowException
	ld a,(ix + VRAMTable.address + 2)
	and 11111110B
	call nz,System_ThrowException
	ld a,(ix + VRAMTable.address + 1)
	rla
	push af
	or 00000011B
	ld (ix + SpriteAttributeTable.baseRegister5),a
	pop af
	ld a,(ix + VRAMTable.address + 2)
	rla
	ld (ix + SpriteAttributeTable.baseRegister11),a
	ret

; h = x
; l = y
; iy = this
SpriteAttributeTable_SetDisplayPositionIY:
	ld a,8
	sub h
	ld (iy + SpriteAttributeTable.worldOffsetX),a
	ld a,-1
	add a,l
	ld (iy + SpriteAttributeTable.cameraOffsetY),a
	ret

SpriteAttributeTable_Select: MACRO ?this, ?displaySettings
	ld a,(?this + SpriteAttributeTable.baseRegister5)
	ld (?displaySettings + DisplaySettings.spriteAttributeLSB),a
	ld a,(?this + SpriteAttributeTable.baseRegister11)
	ld (?displaySettings + DisplaySettings.spriteAttributeMSB),a
	ENDM

; a = sprite number
; ix = this
; c <- write port
SpriteAttributeTable_SetAttributeWrite:
	add a,a
	add a,a
	ld l,a
	ld h,0
	call VRAMTable_SetWrite
	ret

; a = sprite number
; iy = this
; c <- write port
SpriteAttributeTable_SetAttributeWriteIY:
	add a,a
	add a,a
	ld l,a
	ld h,0
	call VRAMTable_SetWriteIY
	ret

; b = pattern number
; c = write port
; h = x
; l = y
; iy = this
SpriteAttributeTable_WriteAttributeIY:
	out (c),l
	nop
	out (c),h
	nop
	out (c),b
	nop
	out (c),a
	ret

; c = write port
; iy = this
SpriteAttributeTable_FinishWriteIY:
	ld a,216
	out (c),a
	ret
