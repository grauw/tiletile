;
; A tile map
;
TileMap: MACRO ?width, ?height, ?data
	width:
		dw ?width
	height:
		dw ?height
	widthStride:
		dw ?width * 2
	data:
		dw ?data
	ENDM

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
TileMap_GetTile:
	call TileMap_GetTileDataPointer
	ld a,(hl)
	ld ixl,a
	inc l
	ld a,(hl)
	ld ixh,a
	ret

; bc = x
; de = y
; ix = this
; hl <- tile data pointer
; Modifies: af, bc, de
TileMap_GetTileDataPointer: PROC
	bit 7,d
	jr nz,Negative
	ld h,(ix + TileMap.width)
	call Math_Multiply8x8
	jr Continue
Negative:
	ld a,e
	neg
	ld e,a
	ld h,(ix + TileMap.width)
	call Math_Multiply8x8
	ex de,hl
	ld hl,0
	and a
	sbc hl,de
Continue:
	add hl,bc
	add hl,hl
	ld e,(ix + TileMap.data)
	ld d,(ix + TileMap.data + 1)
	add hl,de
	ret
	ENDP

; c = x offset
; e = y offset
; hl = tile data pointer
; ix = this
; hl <- tile data pointer
TileMap_OffsetTileDataPointer: PROC
	ld a,c
	add a,a
	sbc a,a  ; sign extend
	ld b,a
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
