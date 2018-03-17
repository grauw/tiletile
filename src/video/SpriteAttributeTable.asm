;
; Sprite attribute table in VRAM
;
SpriteAttributeTable: MACRO ?address
	super: VRAMTable ?address
	baseRegister5:
		db 0
	baseRegister11:
		db 0
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

; ix = this
SpriteAttributeTable_Select:
	ld a,(ix + SpriteAttributeTable.baseRegister5)
	ld b,5
	call VDP_SetRegister
	ld a,(ix + SpriteAttributeTable.baseRegister11)
	ld b,11
	call VDP_SetRegister
	ret

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
