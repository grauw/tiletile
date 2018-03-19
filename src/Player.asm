;
;
;
Player_PATTERN: equ 0
Player_TILE_TOP: equ FieldSet_may0_run0
Player_TILE_BOTTOM: equ FieldSet_may1_run0

Player: MACRO
	x:
		dw 124
	y:
		dw 106
	patterns:
		SpritePattern
		SpritePattern
		SpritePattern
		SpritePattern
		SpritePattern
		SpritePattern
		SpritePattern
		SpritePattern
	ENDM

; ix = this
Player_Construct:
	push ix
	ld e,ixl
	ld d,ixh
	ld iy,Player.patterns
	add iy,de
	ld ix,Player_TILE_TOP
	call Tile_LoadToSpritePatterns
	ld ix,Player_TILE_BOTTOM
	call Tile_LoadToSpritePatterns
	pop ix
	ret

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

; c = write port
; ix = this
; iy = sprite attribute table
Player_DrawSpriteAttributes:
	ld a,(ix + Player.x)
	add a,(iy + SpriteAttributeTable.worldOffsetX)
	add a,-8
	ld h,a
	ld a,(ix + Player.y)
	add a,(iy + SpriteAttributeTable.worldOffsetY)
	add a,-24
	ld l,a
	ld b,Player_PATTERN + 0 << 2
	call SpriteAttributeTable_WriteAttributeIY
	ld b,Player_PATTERN + 1 << 2
	call SpriteAttributeTable_WriteAttributeIY
	ld b,Player_PATTERN + 2 << 2
	call SpriteAttributeTable_WriteAttributeIY
	ld b,Player_PATTERN + 3 << 2
	call SpriteAttributeTable_WriteAttributeIY
	add a,16
	ld l,a
	ld b,Player_PATTERN + 4 << 2
	call SpriteAttributeTable_WriteAttributeIY
	ld b,Player_PATTERN + 5 << 2
	call SpriteAttributeTable_WriteAttributeIY
	ld b,Player_PATTERN + 6 << 2
	call SpriteAttributeTable_WriteAttributeIY
	ld b,Player_PATTERN + 7 << 2
	call SpriteAttributeTable_WriteAttributeIY
	ret

; c = write port
; ix = this
; iy = sprite color table
Player_DrawSpriteColors:
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

; ix = this
; iy = sprite pattern table
Player_DrawSpritePatterns:
	ld a,Player_PATTERN
	call SpritePatternTable_SetPatternWriteIY
	ld e,ixl
	ld d,ixh
	ld hl,Player.patterns
	add hl,de
	call SpritePatternTable_WritePatternIY
	call SpritePatternTable_WritePatternIY
	call SpritePatternTable_WritePatternIY
	call SpritePatternTable_WritePatternIY
	call SpritePatternTable_WritePatternIY
	call SpritePatternTable_WritePatternIY
	call SpritePatternTable_WritePatternIY
	call SpritePatternTable_WritePatternIY
	ret
