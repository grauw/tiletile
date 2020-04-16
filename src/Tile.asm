;
; A tile
;
Tile_PAGE: equ 2

Tile: MACRO ?imageindex, ?tilesbank, ?collision
	imageBank:
		db ?tilesbank + (?imageindex >> 6)
	image:
		dw 0A000H + (?imageindex << 7 & 1FFFH)
	collision:
		db ?collision
	_size:
	ENDM

; ix = this
Tile_GetCollision_M: MACRO ?this, ?register
	ld ?register,(?this + Tile.collision)
	ENDM

; ix = this
; f <- nz: solid
Tile_IsSolid_M: MACRO ?this
	bit 7,(?this + Tile.collision)
	ENDM

; ix = this
; iy = 4 patterns
; iy <- next pattern
Tile_LoadToSpritePatterns:
	ld a,(ix + Tile.imageBank)
	ld hl,(ROM_bankA000)
	push hl
	ld (hl),a
	ld l,(ix + Tile.image)
	ld h,(ix + Tile.image + 1)
	push hl
	call SpritePattern_LoadFromTileBit0_IY
	ld de,SpritePattern._size
	add iy,de
	pop hl
	push hl
	call SpritePattern_LoadFromTileBit1_IY
	ld de,SpritePattern._size
	add iy,de
	pop hl
	push hl
	call SpritePattern_LoadFromTileBit2_IY
	ld de,SpritePattern._size
	add iy,de
	pop hl
	call SpritePattern_LoadFromTileBit3_IY
	ld de,SpritePattern._size
	add iy,de
	pop hl
	ld (hl),l
	ret

; b = patterns remaining (x4)
; c = write port
; ix = tile
; iy = sprite pattern table
; b <- patterns remaining (x4)
; c <- write port
Tile_LoadToSpritePatternTable:
	push bc
	push iy
	ld iy,Tile_tempPatterns
	call Tile_LoadToSpritePatterns
	pop iy
	pop bc
	ld hl,Tile_tempPatterns
	call SpritePatternTable_WritePatternIY
	call SpritePatternTable_WritePatternIY
	call SpritePatternTable_WritePatternIY
	call SpritePatternTable_WritePatternIY
	ret

;
	SECTION RAM

Tile_tempPatterns:
	SpritePattern
	SpritePattern
	SpritePattern
	SpritePattern

	ENDS
