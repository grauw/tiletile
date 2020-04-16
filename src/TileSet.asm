;
; A tile set
;
TileSet: MACRO ?tiles, ?count, ?bank
	tiles:
		dw ?tiles
	count:
		db ?count
	tilesBank:
		db ?bank
	ENDM

; ix = this
TileSet_GetTiles:
	ld e,(ix + TileSet.tiles)
	ld d,(ix + TileSet.tiles + 1)
	ld ixl,e
	ld ixh,d
	ret

; a = tile index
; ix = this
; ix <- tile
TileSet_GetTile:
	ld l,a
	ld h,0
	add hl,hl
	ld e,l
	ld d,h
	add hl,hl
	add hl,de
	call TileSet_GetTiles
	ex de,hl
	add ix,de
	ret

; ix = this
TileSet_Load:
	call TileSet_LoadTiles
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
