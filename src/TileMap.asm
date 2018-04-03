;
; A tile map
;
TileMap: MACRO ?width, ?height, ?data, ?dataRows
	width:
		dw ?width
	height:
		dw ?height
	data:
		dw ?data
	dataRows:
		dw ?dataRows
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
; Modifies: f, bc, de
TileMap_GetTile: PROC
	ld l,(ix + TileMap.height)
	ld h,(ix + TileMap.height + 1)
	scf
	sbc hl,de
	jr nc,NoClip
	ld de,0
NoClip:
	ld l,(ix + TileMap.dataRows)
	ld h,(ix + TileMap.dataRows + 1)
	add hl,de
	add hl,de
	ld e,(hl)
	inc hl
	ld h,(hl)
	ld l,e
	add hl,bc
	add hl,bc
	ld e,(hl)
	inc hl
	ld d,(hl)
	ld ixl,e
	ld ixh,d
	ret
	ENDP

; bc = x
; de = y
; ix = this
; hl <- tile data pointer
; Modifies: af, bc, de
TileMap_GetTileDataPointer: PROC
	bit 7,d
	jr nz,Negative
	call Multiply
	jr Continue
Negative:
	ld a,e
	neg
	ld e,a
	call Multiply
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
Multiply:
	ld h,(ix + TileMap.width)
	ld d,0
	ld l,d
	REPT 8
	add hl,hl
	jr nc,NoAdd
	add hl,de
NoAdd:
	ENDM
	ret
	ENDP
