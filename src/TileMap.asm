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
