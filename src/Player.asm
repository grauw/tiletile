;
;
;
Player_SPRITE_COUNT: equ 8

Player: MACRO
	x:
		dw 112
	y:
		dw 80
	sprites:
		Sprite SpritePattern_filled, SpriteColor_solid1, 0, 0
		Sprite SpritePattern_filled, SpriteColor_solid2CC, 0, 0
		Sprite SpritePattern_filled, SpriteColor_solid4CC, 0, 0
		Sprite SpritePattern_filled, SpriteColor_solid8CC, 0, 0
		Sprite SpritePattern_filled, SpriteColor_solid1, 0, 16
		Sprite SpritePattern_filled, SpriteColor_solid2CC, 0, 16
		Sprite SpritePattern_filled, SpriteColor_solid4CC, 0, 16
		Sprite SpritePattern_filled, SpriteColor_solid8CC, 0, 16
	ENDM

; iy = sprite system
; ix = this
Player_Construct: PROC
	push ix
	ld e,ixl
	ld d,ixh
	ld hl,Player.sprites
	add hl,de
	ex de,hl
	push iy
	pop ix
	ld b,Player_SPRITE_COUNT
Loop:
	push bc
	push de
	call Sprites_AddSprite
	pop de
	pop bc
	ld hl,Sprite._size
	add hl,de
	ex de,hl
	djnz Loop
	pop ix
	ret
	ENDP

; ix = this
Player_Start: PROC
	ld l,(ix + Player.x)
	ld h,(ix + Player.y)
	push ix
	ld b,Player_SPRITE_COUNT
Loop:
	ld a,(ix + Player.sprites + Sprite.x)
	add a,l
	ld (ix + Player.sprites + Sprite.x),a
	ld a,(ix + Player.sprites + Sprite.y)
	add a,h
	ld (ix + Player.sprites + Sprite.y),a
	ld de,Sprite._size
	add ix,de
	djnz Loop
	pop ix
	ret
	ENDP

; ix = this
Player_PreUpdate:
	ret

; ix = this
Player_Update:
	call Player_MoveRight
	ret

; ix = this
Player_MoveRight: PROC
	push ix
	ld b,Player_SPRITE_COUNT
Loop:
	ld a,(ix + Player.sprites + Sprite.x)
	add a,2
	ld (ix + Player.sprites + Sprite.x),a
	ld de,Sprite._size
	add ix,de
	djnz Loop
	pop ix
	ret
	ENDP
