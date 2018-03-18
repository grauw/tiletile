;
;
;
Player_SPRITE_COUNT: equ 8
Player_TILE_TOP: equ FieldSet_may0_run0
Player_TILE_BOTTOM: equ FieldSet_may1_run0

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

; bc = x (-1 left, 1 right)
; de = y (-1 up, 1 down)
Player_Move: PROC
	sla c  ; speed x2
	rl b
	sla e
	rl d
	ld l,(ix + Player.x)
	ld h,(ix + Player.x + 1)
	add hl,bc
	ld (ix + Player.x),l
	ld (ix + Player.x + 1),h
	ld l,(ix + Player.y)
	ld h,(ix + Player.y + 1)
	add hl,de
	ld (ix + Player.y),l
	ld (ix + Player.y + 1),h
	ret
	ENDP

; c = transfer port
; ix = this
; iy = sprite attribute table
Player_DrawSpriteAttributes:
	ld a,(ix + Player.x)
	add a,(iy + SpriteAttributeTable.worldOffsetX)
	add a,-8
	ld d,a
	ld a,(ix + Player.y)
	add a,(iy + SpriteAttributeTable.worldOffsetY)
	add a,-24
	ld e,a
	ld b,0 << 2
	call SpriteAttributeTable_WriteAttributeIY
	ld b,1 << 2
	call SpriteAttributeTable_WriteAttributeIY
	ld b,2 << 2
	call SpriteAttributeTable_WriteAttributeIY
	ld b,3 << 2
	call SpriteAttributeTable_WriteAttributeIY
	add a,16
	ld e,a
	ld b,4 << 2
	call SpriteAttributeTable_WriteAttributeIY
	ld b,5 << 2
	call SpriteAttributeTable_WriteAttributeIY
	ld b,6 << 2
	call SpriteAttributeTable_WriteAttributeIY
	ld b,7 << 2
	call SpriteAttributeTable_WriteAttributeIY
	ret

; c = transfer port
; ix = this
; iy = sprite color table
Player_DrawSpriteColor:
	ld hl,SpriteColor_solid1
	call SpriteColorTable_DrawIY
	ld hl,SpriteColor_solid2CC
	call SpriteColorTable_DrawIY
	ld hl,SpriteColor_solid4CC
	call SpriteColorTable_DrawIY
	ld hl,SpriteColor_solid8CC
	call SpriteColorTable_DrawIY
	ld hl,SpriteColor_solid1
	call SpriteColorTable_DrawIY
	ld hl,SpriteColor_solid2CC
	call SpriteColorTable_DrawIY
	ld hl,SpriteColor_solid4CC
	call SpriteColorTable_DrawIY
	ld hl,SpriteColor_solid8CC
	call SpriteColorTable_DrawIY
	ret

;
	SECTION RAM

Player_pattern0: SpritePattern
Player_pattern1: SpritePattern
Player_pattern2: SpritePattern
Player_pattern3: SpritePattern
Player_pattern4: SpritePattern
Player_pattern5: SpritePattern
Player_pattern6: SpritePattern
Player_pattern7: SpritePattern

	ENDS
