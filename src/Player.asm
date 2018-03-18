;
;
;
Player_TILE_TOP: equ FieldSet_may0_run0
Player_TILE_BOTTOM: equ FieldSet_may1_run0

Player: MACRO
	x:
		dw 124
	y:
		dw 106
	ENDM

; ix = this
Player_Construct:
	push ix
	ld iy,Player_pattern0
	ld ix,Player_TILE_TOP
	call Tile_LoadToSpritePatterns
	ld ix,Player_TILE_BOTTOM
	call Tile_LoadToSpritePatterns
	pop ix
	ret

; ix = this
; iy = sprite pattern table
Player_DrawPatterns:
	ld a,0
	call SpritePatternTable_SetPatternWriteIY
	ld hl,Player_pattern0 + SpritePattern.data
	call SpritePatternTable_WritePatternIY
	ld hl,Player_pattern1 + SpritePattern.data
	call SpritePatternTable_WritePatternIY
	ld hl,Player_pattern2 + SpritePattern.data
	call SpritePatternTable_WritePatternIY
	ld hl,Player_pattern3 + SpritePattern.data
	call SpritePatternTable_WritePatternIY
	ld hl,Player_pattern4 + SpritePattern.data
	call SpritePatternTable_WritePatternIY
	ld hl,Player_pattern5 + SpritePattern.data
	call SpritePatternTable_WritePatternIY
	ld hl,Player_pattern6 + SpritePattern.data
	call SpritePatternTable_WritePatternIY
	ld hl,Player_pattern7 + SpritePattern.data
	call SpritePatternTable_WritePatternIY
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
