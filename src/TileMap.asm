;
; A tile map
;
TileMap: MACRO ?width, ?height, ?palette, ?data
	size:
		Vector2W ?width, ?height
	widthStride:
		dw ?width * Tile._size
	palette:
		dw ?palette
	data:
		ROMAddress ?data, 8000H
	ENDM

; ix = this
TileMap_GetPalette:
	ld e,(ix + TileMap.palette)
	ld d,(ix + TileMap.palette + 1)
	ld ixl,e
	ld ixh,d
	ret

; ix = this
TileMap_Select:
	ld a,(ix + TileMap.data.bank)
	ld h,(ix + TileMap.data.address + 1)
	jp ROMMapper_SetBank

; bc = x (pixels)
; de = y (pixels)
; bc <- x (tiles)
; de <- y (tiles)
TileMap_PixelToTilePosition:
	srl b
	rr c
	srl b
	rr c
	srl b
	rr c
	srl b
	rr c
	srl d
	rr e
	srl d
	rr e
	srl d
	rr e
	srl d
	rr e
	ret

; bc = x
; de = y
; ix = this
; ix <- tile
; Modifies: af, bc, de, hl
TileMap_GetTile_IX:
	call TileMap_GetTile
	push hl
	pop ix
	ret

; bc = x
; de = y
; ix = this
; hl <- tile
; Modifies: af, bc, de
TileMap_GetTile: PROC
	bit 7,d
	jr nz,Negative
	ld h,(ix + TileMap.size.x)
	call Math_Multiply8x8
	jr Continue
Negative:
	ld a,e
	neg
	ld e,a
	ld h,(ix + TileMap.size.x)
	call Math_Multiply8x8
	ex de,hl
	ld hl,0
	and a
	sbc hl,de
Continue:
	add hl,bc
	add hl,hl
	add hl,hl
	ld e,(ix + TileMap.data.address)
	ld d,(ix + TileMap.data.address + 1)
	add hl,de
	ret
	ENDP

; c = x offset
; e = y offset
; hl = tile
; ix = this
; hl <- tile
TileMap_OffsetTile: PROC
	ld a,c
	add a,a
	sbc a,a  ; sign extend
	ld b,a
	add hl,bc
	add hl,bc
	add hl,bc
	add hl,bc
	ld a,e
	and a
	ret z
	ld e,(ix + TileMap.widthStride)
	ld d,(ix + TileMap.widthStride + 1)
	jp p,Increase
Decrease:
	neg
	ld b,a
DecreaseLoop:
	sbc hl,de
	djnz DecreaseLoop
	ret
Increase:
	ld b,a
IncreaseLoop:
	add hl,de
	djnz IncreaseLoop
	ret
	ENDP
