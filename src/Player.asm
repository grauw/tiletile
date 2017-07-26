;
;
;
Player_SPRITE_COUNT: equ 8
Player_TILE_TOP: equ 0EDH
Player_TILE_BOTTOM: equ 0FDH

Player: MACRO
	x:
		dw 112
	y:
		dw 80
	sprites:
		Sprite Player_pattern0, SpriteColor_solid1, 0, 0
		Sprite Player_pattern1, SpriteColor_solid2CC, 0, 0
		Sprite Player_pattern2, SpriteColor_solid4CC, 0, 0
		Sprite Player_pattern3, SpriteColor_solid8CC, 0, 0
		Sprite Player_pattern4, SpriteColor_solid1, 0, 16
		Sprite Player_pattern5, SpriteColor_solid2CC, 0, 16
		Sprite Player_pattern6, SpriteColor_solid4CC, 0, 16
		Sprite Player_pattern7, SpriteColor_solid8CC, 0, 16
	ENDM

; de = tile set
; iy = sprite system
; ix = this
Player_Construct: PROC
	push ix
	push ix
	push iy
	ld ixl,e
	ld ixh,d
	ld iy,Player_pattern0
	ld b,Player_TILE_TOP
	call TileSet_LoadTileToSpritePatterns
	ld b,Player_TILE_BOTTOM
	call TileSet_LoadTileToSpritePatterns
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
