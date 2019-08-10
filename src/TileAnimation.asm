;
;
;
TileAnimation: MACRO
	x:
		dw 256
	y:
		dw 80
	index:
		db 0
	ENDM

TileAnimation_Tick:
	inc (ix + TileAnimation.index)
	ret

; ix = this
; iy = map view
TileAnimation_DrawBitmap:
	ld c,(ix + TileAnimation.x)
	ld b,(ix + TileAnimation.x + 1)
	ld e,(ix + TileAnimation.y)
	ld d,(ix + TileAnimation.y + 1)
	ld a,(ix + TileAnimation.index)
	rrca
	rrca
	rrca
	and 3
	cp 0
	ld ix,FieldSet_24
	jp z,MapView_DrawTileIY
	cp 2
	ld ix,FieldSet_26
	jp z,MapView_DrawTileIY
	ld ix,FieldSet_25
	jp MapView_DrawTileIY
