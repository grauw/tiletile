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
; hl <- data position
; Modifies: af, bc, de
TileMap_GetDataPosition: PROC
	ld l,(ix + TileMap.height)
	ld h,(ix + TileMap.height + 1)
	scf
	sbc hl,de
	jr nc,NoClip
	ld de,0
NoClip:
	ex de,hl
	ld e,(ix + TileMap.dataRows)
	ld d,(ix + TileMap.dataRows + 1)
	add hl,hl
	add hl,de
	ld a,(hl)
	inc hl
	ld h,(hl)
	ld l,a
	add hl,bc
	ret
	ENDP
