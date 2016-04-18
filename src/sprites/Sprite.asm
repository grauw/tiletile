;
;
;
Sprite: MACRO ?pattern, ?color
	x:
		dw 0
	y:
		dw 216
	patternNumber:
		db 0
	pattern:
		dw ?pattern
	color:
		dw ?color
	ENDM

; iy = this
Sprite_Draw_IY:
	ld a,(iy + Sprite.y)
	out (VDP_PORT_0),a
	ld a,(iy + Sprite.x)
	out (VDP_PORT_0),a
	ld a,(iy + Sprite.patternNumber)
	out (VDP_PORT_0),a
	xor a
	out (VDP_PORT_0),a
	ret

; iy = this
Sprite_DrawColor_IY:
	ld e,(iy + Sprite.color)
	ld d,(iy + Sprite.color + 1)
	ld iyl,e
	ld iyh,d
	call SpriteColor_Draw_IY
	ret

;
Sprite_empty:
	Sprite SpritePattern_blank, SpriteColor_solid0
