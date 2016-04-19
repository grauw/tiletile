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
; ix = sprite system
Sprite_Register_IY:
	push iy
	ld e,(iy + Sprite.pattern)
	ld d,(iy + Sprite.pattern + 1)
	ld iyl,e
	ld iyh,d
	call SpritePattern_IncreaseReferenceCount_IY
	call SpritePattern_HasNumber_IY
	call z,Sprites_AddPattern
	call SpritePattern_GetNumber_IY
	pop iy
	ld (iy + Sprite.patternNumber),a
	ret

; iy = this
; ix = sprite system
Sprite_Unregister_IY:
	ld e,(iy + Sprite.pattern)
	ld d,(iy + Sprite.pattern + 1)
	ld iyl,e
	ld iyh,d
	call SpritePattern_DecreaseReferenceCount_IY
	ret

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
	SECTION RAM

Sprite_unused:
	Sprite 0, SpriteColor_solid0

Sprite_block:
	Sprite SpritePattern_filled, SpriteColor_solid15

	ENDS
