;
;
;
TileAnimation: MACRO
	position:
		Vector2W 144, 160
	index:
		db 0
	ENDM

TileAnimation_Tick:
	inc (ix + TileAnimation.index)
	ret

; ix = this
; iy = map view
TileAnimation_DrawBitmap:
	ld c,(ix + TileAnimation.position.x)
	ld b,(ix + TileAnimation.position.x + 1)
	ld e,(ix + TileAnimation.position.y)
	ld d,(ix + TileAnimation.position.y + 1)
	ld a,(ix + TileAnimation.index)
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
