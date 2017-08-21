;
; A tile set
;
TileSet: MACRO ?tiles, ?count, ?bank, ?palette
	tiles:
		dw ?tiles
	count:
		db ?count
	tilesBank:
		db ?bank
	palette:
		dw ?palette
	ENDM

; ix = this
TileSet_GetTiles:
	ld e,(ix + TileSet.tiles)
	ld d,(ix + TileSet.tiles + 1)
	ld ixl,e
	ld ixh,d
	ret

; ix = this
TileSet_GetPalette:
	ld e,(ix + TileSet.palette)
	ld d,(ix + TileSet.palette + 1)
	ld ixl,e
	ld ixh,d
	ret

; ix = this
TileSet_Load:
	call TileSet_LoadTiles
	push ix
	call TileSet_GetPalette
	call Palette_Set
	pop ix
	ret

; ix = this
TileSet_LoadTiles: PROC
	push ix
	ld b,(ix + TileSet.count)
	call TileSet_GetTiles
Loop:
	push bc
	call Tile_Load
	pop bc
	ld de,Tile._size
	add ix,de
	djnz Loop
	pop ix
	ret
	ENDP

; b = tile nr
; iy = 4 patterns
; ix = this
; iy <- next pattern
TileSet_LoadTileToSpritePatterns:
	ld a,b
	and 11000000B
	rlca
	rlca
	add a,(ix + TileSet.tilesBank)
	ld hl,(ROM_bank6000)
	push hl
	ld (hl),a
	ld a,b
	and 00111111B
	rra
	ld l,0
	ld h,a
	rr l
	ld de,6000H
	add hl,de
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
