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

; bc = x
; de = y
; ix = this
; hl <- tile
; Modifies: af, bc, de
TileMap_GetTile: PROC
	REPT 4
	sra b
	rr c
	ENDM
	REPT 4
	sra d
	rr e
	ENDM
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
