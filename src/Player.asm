;
;
;
Player_SPRITE_COUNT: equ 8
Player_TILE_TOP: equ FieldSet_ben0
Player_TILE_BOTTOM: equ FieldSet_ben1
Player_MOVE_SPEED: equ 2

Player: MACRO
	x:
		dw 124
	y:
		dw 106
	sprites:
		Sprite Player_pattern0, SpriteColor_solid1, -8, -24
		Sprite Player_pattern1, SpriteColor_solid2CC, -8, -24
		Sprite Player_pattern2, SpriteColor_solid4CC, -8, -24
		Sprite Player_pattern3, SpriteColor_solid8CC, -8, -24
		Sprite Player_pattern4, SpriteColor_solid1, -8, -8
		Sprite Player_pattern5, SpriteColor_solid2CC, -8, -8
		Sprite Player_pattern6, SpriteColor_solid4CC, -8, -8
		Sprite Player_pattern7, SpriteColor_solid8CC, -8, -8
	ENDM

; iy = sprite system
; ix = this
Player_Construct: PROC
	push ix
	push ix
	push iy
	ld iy,Player_pattern0
	ld ix,Player_TILE_TOP
	call Tile_LoadToSpritePatterns
	ld ix,Player_TILE_BOTTOM
	call Tile_LoadToSpritePatterns
	pop ix
	pop de
	ld hl,Player.sprites
	add hl,de
	ex de,hl
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
	ld e,(ix + Player.x)
	ld d,(ix + Player.x + 1)
	ld l,(ix + Player.y)
	ld h,(ix + Player.y + 1)
	push ix
	ld b,Player_SPRITE_COUNT
Loop:
	push bc
	ld a,(ix + Player.sprites + Sprite.x)
	add a,e
	ld (ix + Player.sprites + Sprite.x),a
	ld a,(ix + Player.sprites + Sprite.x + 1)
	adc a,d
	ld (ix + Player.sprites + Sprite.x + 1),a
	ld a,(ix + Player.sprites + Sprite.y)
	add a,l
	ld (ix + Player.sprites + Sprite.y),a
	ld a,(ix + Player.sprites + Sprite.y + 1)
	adc a,h
	ld (ix + Player.sprites + Sprite.y + 1),a
	ld bc,Sprite._size
	add ix,bc
	pop bc
	djnz Loop
	pop ix
	ret
	ENDP

; ix = this
Player_Update:
	ret

; ix = this
Player_MoveLeft: PROC
	ld a,(ix + Player.x)
	sub Player_MOVE_SPEED
	ld (ix + Player.x),a
	ld a,(ix + Player.x + 1)
	sbc a,Player_MOVE_SPEED >> 8
	ld (ix + Player.x + 1),a
	push ix
	ld b,Player_SPRITE_COUNT
Loop:
	ld a,(ix + Player.sprites + Sprite.x)
	sub Player_MOVE_SPEED
	ld (ix + Player.sprites + Sprite.x),a
	ld a,(ix + Player.sprites + Sprite.x + 1)
	sbc a,Player_MOVE_SPEED >> 8
	ld (ix + Player.sprites + Sprite.x + 1),a
	ld de,Sprite._size
	add ix,de
	djnz Loop
	pop ix
	ret
	ENDP

; ix = this
Player_MoveRight: PROC
	ld a,(ix + Player.x)
	add a,Player_MOVE_SPEED
	ld (ix + Player.x),a
	ld a,(ix + Player.x + 1)
	adc a,Player_MOVE_SPEED >> 8
	ld (ix + Player.x + 1),a
	push ix
	ld b,Player_SPRITE_COUNT
Loop:
	ld a,(ix + Player.sprites + Sprite.x)
	add a,Player_MOVE_SPEED
	ld (ix + Player.sprites + Sprite.x),a
	ld a,(ix + Player.sprites + Sprite.x + 1)
	adc a,Player_MOVE_SPEED >> 8
	ld (ix + Player.sprites + Sprite.x + 1),a
	ld de,Sprite._size
	add ix,de
	djnz Loop
	pop ix
	ret
	ENDP

; ix = this
Player_MoveUp: PROC
	ld a,(ix + Player.y)
	sub Player_MOVE_SPEED
	ld (ix + Player.y),a
	ld a,(ix + Player.y + 1)
	sbc a,Player_MOVE_SPEED >> 8
	ld (ix + Player.y + 1),a
	push ix
	ld b,Player_SPRITE_COUNT
Loop:
	ld a,(ix + Player.sprites + Sprite.y)
	sub Player_MOVE_SPEED
	ld (ix + Player.sprites + Sprite.y),a
	ld a,(ix + Player.sprites + Sprite.y + 1)
	sbc a,Player_MOVE_SPEED >> 8
	ld (ix + Player.sprites + Sprite.y + 1),a
	ld de,Sprite._size
	add ix,de
	djnz Loop
	pop ix
	ret
	ENDP

; ix = this
Player_MoveDown: PROC
	ld a,(ix + Player.y)
	add a,Player_MOVE_SPEED
	ld (ix + Player.y),a
	ld a,(ix + Player.y + 1)
	adc a,Player_MOVE_SPEED >> 8
	ld (ix + Player.y + 1),a
	push ix
	ld b,Player_SPRITE_COUNT
Loop:
	ld a,(ix + Player.sprites + Sprite.y)
	add a,Player_MOVE_SPEED
	ld (ix + Player.sprites + Sprite.y),a
	ld a,(ix + Player.sprites + Sprite.y + 1)
	adc a,Player_MOVE_SPEED >> 8
	ld (ix + Player.sprites + Sprite.y + 1),a
	ld de,Sprite._size
	add ix,de
	djnz Loop
	pop ix
	ret
	ENDP

;
	SECTION RAM

Player_pattern0: SpritePattern
Player_pattern1: SpritePattern 255,255
Player_pattern2: SpritePattern
Player_pattern3: SpritePattern
Player_pattern4: SpritePattern
Player_pattern5: SpritePattern
Player_pattern6: SpritePattern
Player_pattern7: SpritePattern

	ENDS
