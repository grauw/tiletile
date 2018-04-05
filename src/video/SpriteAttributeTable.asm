;
; Sprite attribute table in VRAM
;
SpriteAttributeTable_COUNT: equ 32
SpriteAttributeTable_SIZE: equ SpriteAttributeTable_COUNT * SpriteAttribute._size

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
; iy = this
; b <- sprites remaining
; c <- write port
SpriteAttributeTable_SetAttributeWriteIY:
	ld b,a
	add a,a
	add a,a
	ld l,a
	ld h,0
	call VRAMTable_SetWriteIY
	ld a,SpriteAttributeTable_COUNT
	sub b
	ld b,a
	ret

; b = sprites remaining
; c = write port
; b <- sprites remaining
; c <- write port
; f <- z: no sprites remaining
SpriteAttributeTable_WriteAttribute_M: MACRO ?x, ?y, ?pattern
	out (c),?y
	nop
	out (c),?x
	nop
	out (c),?pattern
	dec b
	out (c),a
	ENDM

; b = sprites remaining
; c = write port
; iy = this
SpriteAttributeTable_FinishWriteIY: PROC
	ld a,b
	and a
	ret z
	call m,System_ThrowException
Loop:
	ld a,216
	ld hl,0
	SpriteAttributeTable_WriteAttribute_M h, a, l
	jr nz,Loop
	ret
	ENDP
