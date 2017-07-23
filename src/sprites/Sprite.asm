;
;
;
Sprite: MACRO ?pattern, ?color, ?x = 0, ?y = 0
	x:
		dw ?x
	y:
		dw ?y
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
	add a,a
	add a,a
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

; c = VDP write port
; iy = this
; ix = sprite system
Sprite_Draw_IY: PROC
	ld a,(iy + Sprite.y)
	ld h,a
	sub (ix + Sprites.y)
	ld a,(iy + Sprite.y + 1)
	sbc a,(ix + Sprites.y + 1)
	jr nz,Hide

	ld a,(iy + Sprite.x)
	sub (ix + Sprites.x)
	ld l,a
	ld a,(iy + Sprite.x + 1)
	sbc a,(ix + Sprites.x + 1)
	jr nz,Hide

	dec h
	out (c),h
	out (c),l
	ld a,(iy + Sprite.patternNumber)
	out (c),a
	out (c),a
	ret
Hide:
	ld a,(ix + Sprites.y)
	add a,232
	out (c),a
	out (c),a
	out (c),a
	out (c),a
	ret
	ENDP

; c = VDP write port
; iy = this
Sprite_DrawColor_IY:
	ld l,(iy + Sprite.color)
	ld h,(iy + Sprite.color + 1)
	REPT 16
	outi
	ENDM
	ret

;
	SECTION RAM

Sprite_unused:
	Sprite 0, SpriteColor_solid0, 0, -100H

Sprite_block:
	Sprite SpritePattern_filled, SpriteColor_solid15

	ENDS
