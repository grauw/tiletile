;
; A tile map
;
TileMap_TILE_SIZE: equ 16
TileMap_CHUNK_SIZE: equ 16

TileMap: MACRO ?width, ?height, ?palette, ?tiles, ?collision
	size:
		Vector2W ?width * TileMap_TILE_SIZE, ?height * TileMap_TILE_SIZE
	palette:
		dw ?palette
	tiles:
		ROMAddress ?tiles, 8000H
	collision:
		ROMAddress ?collision, 8000H
	ENDM

; ix = this
TileMap_GetPalette:
	ld e,(ix + TileMap.palette)
	ld d,(ix + TileMap.palette + 1)
	ld ixl,e
	ld ixh,d
	ret

; ix = this
TileMap_SelectTiles:
	ld a,(ix + TileMap.tiles.bank)
	ld h,(ix + TileMap.tiles.address + 1)
	jp ROMMapper_SetBank

; ix = this
TileMap_SelectCollision:
	ld a,(ix + TileMap.collision.bank)
	ld h,(ix + TileMap.collision.address + 1)
	jp ROMMapper_SetBank

; bc = x
; de = y
; ix = this
; hl <- tile
; Modifies: af, bc, de
TileMap_GetTile:
	call TileMap_GetIndex
	add hl,hl
	add hl,hl
	ld e,(ix + TileMap.tiles.address)
	ld d,(ix + TileMap.tiles.address + 1)
	add hl,de
	ret

; bc = x
; de = y
; ix = this
; hl <- collision
; Modifies: af, bc, de
TileMap_GetCollision:
	call TileMap_GetIndex
	ld e,(ix + TileMap.collision.address)
	ld d,(ix + TileMap.collision.address + 1)
	add hl,de
	ret

; bc = x
; de = y
; ix = this
; hl <- tile index
; Modifies: af, bc, de, hl
TileMap_GetIndex:
	call TileMap_GetTileIndex
	ld c,l
	call TileMap_GetChunkIndex
	ld l,c
	ret

; c = x LSB
; e = y LSB
; l <- tile index within chunk
; Modifies: af
TileMap_GetTileIndex:
	ld a,c
	and 0F0H
	rrca
	rrca
	rrca
	rrca
	ld l,a
	ld a,e
	and 0F0H
	or l
	ld l,a
	ret

; b = x MSB
; d = y MSB
; ix = this
; h <- chunk index
; Modifies: af, de, hl
TileMap_GetChunkIndex: PROC
	ld h,(ix + TileMap.size.x + 1)
	ld e,d
	bit 7,d
	jr nz,Negative
	call Math_Multiply8x8
	jr Continue
Negative:
	ld a,e
	neg
	ld e,a
	call Math_Multiply8x8
	ex de,hl
	ld hl,0
	and a
	sbc hl,de
Continue:
	ld a,l
	add a,b
	ld h,a
	ret
	ENDP
