;
; A tile
;
Tile_PAGE: equ 2

Tile: MACRO ?imageindex, ?tilesbank, ?collision
	image:
		dw 0A000H + (?imageindex << 7 & 1FFFH)
	imageBank:
		db ?tilesbank + (?imageindex >> 6)
	x:
		db (?imageindex & 0FH) << 4
	y:
		db ?imageindex & 0F0H
	collision:
		db ?collision
	_size:
	ENDM

; ix = this
Tile_Load:
	ld a,(ix + Tile.imageBank)
	ld hl,(ROM_bankA000)
	push hl
	ld (hl),a
	ld l,(ix + Tile.image)
	ld h,(ix + Tile.image + 1)
	ld de,16
	ld a,4
	call VDPCommand_PrepareCommand
	ld a,(ix + Tile.x)
	out (c),a
	out (c),d
	ld a,(ix + Tile.y)
	out (c),a
	ld a,Tile_PAGE
	out (c),a
	out (c),e
	out (c),d
	out (c),e
	out (c),d
	ld a,(hl)
	inc hl
	out (c),a
	out (c),d
	ld a,VDPCommand_HMMC
	out (c),a
	call VDPCommand_PrepareTransfer
	ld b,16 * 16 / 2 - 1
	otir
	pop hl
	ld (hl),l
	ret

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

; c = write port
; ix = tile
; iy = sprite pattern table
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
