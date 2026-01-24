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
TileMap_GetIndex: PROC
	REPT 4
	sra b
	rr c
	ENDM
	REPT 4
	sra d
	rr e
	ENDM
	ld a,(ix + TileMap.size.x + 1)
	add a,a
	add a,a
	add a,a
	add a,a
	ld h,a
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
	add hl,bc
	ret
	ENDP
