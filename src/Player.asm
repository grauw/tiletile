;
;
;
Player_PATTERN: equ 0

Player: MACRO
	x:
		dw 124
	y:
		dw 106
	direction:
		db 0  ; 0 = down, 5 = left, 10 = up, 15 = right
	moving:
		db 0
	movingStep:
		db 0
	sourcePatterns:
		SpritePatternTable 1D000H
	ENDM

; ix = this
Player_Construct:
	ld e,ixl
	ld d,ixh
	ld iy,Player.sourcePatterns
	add iy,de
	ld a,0
	call SpritePatternTable_SetPatternWriteIY
	push ix
	ld ix,FieldSet_may0_standDown
	call Tile_LoadToSpritePatternTable
	ld ix,FieldSet_may1_standDown
	call Tile_LoadToSpritePatternTable
	ld ix,FieldSet_may0_runDown0
	call Tile_LoadToSpritePatternTable
	ld ix,FieldSet_may1_runDown0
	call Tile_LoadToSpritePatternTable
	ld ix,FieldSet_may0_runDown1
	call Tile_LoadToSpritePatternTable
	ld ix,FieldSet_may1_runDown1
	call Tile_LoadToSpritePatternTable
	ld ix,FieldSet_may0_runDown2
	call Tile_LoadToSpritePatternTable
	ld ix,FieldSet_may1_runDown2
	call Tile_LoadToSpritePatternTable
	ld ix,FieldSet_may0_runDown3
	call Tile_LoadToSpritePatternTable
	ld ix,FieldSet_may1_runDown3
	call Tile_LoadToSpritePatternTable
	ld ix,FieldSet_may0_standRight
	call Tile_LoadToSpritePatternTable
	ld ix,FieldSet_may1_standRight
	call Tile_LoadToSpritePatternTable
	ld ix,FieldSet_may0_runRight0
	call Tile_LoadToSpritePatternTable
	ld ix,FieldSet_may1_runRight0
	call Tile_LoadToSpritePatternTable
	ld ix,FieldSet_may0_runRight1
	call Tile_LoadToSpritePatternTable
	ld ix,FieldSet_may1_runRight1
	call Tile_LoadToSpritePatternTable
	ld ix,FieldSet_may0_runRight2
	call Tile_LoadToSpritePatternTable
	ld ix,FieldSet_may1_runRight2
	call Tile_LoadToSpritePatternTable
	ld ix,FieldSet_may0_runRight3
	call Tile_LoadToSpritePatternTable
	ld ix,FieldSet_may1_runRight3
	call Tile_LoadToSpritePatternTable
	ld ix,FieldSet_may0_standUp
	call Tile_LoadToSpritePatternTable
	ld ix,FieldSet_may1_standUp
	call Tile_LoadToSpritePatternTable
	ld ix,FieldSet_may0_runUp0
	call Tile_LoadToSpritePatternTable
	ld ix,FieldSet_may1_runUp0
	call Tile_LoadToSpritePatternTable
	ld ix,FieldSet_may0_runUp1
	call Tile_LoadToSpritePatternTable
	ld ix,FieldSet_may1_runUp1
	call Tile_LoadToSpritePatternTable
	ld ix,FieldSet_may0_runUp2
	call Tile_LoadToSpritePatternTable
	ld ix,FieldSet_may1_runUp2
	call Tile_LoadToSpritePatternTable
	ld ix,FieldSet_may0_runUp3
	call Tile_LoadToSpritePatternTable
	ld ix,FieldSet_may1_runUp3
	call Tile_LoadToSpritePatternTable
	ld ix,FieldSet_may0_standLeft
	call Tile_LoadToSpritePatternTable
	ld ix,FieldSet_may1_standLeft
	call Tile_LoadToSpritePatternTable
	ld ix,FieldSet_may0_runLeft0
	call Tile_LoadToSpritePatternTable
	ld ix,FieldSet_may1_runLeft0
	call Tile_LoadToSpritePatternTable
	ld ix,FieldSet_may0_runLeft1
	call Tile_LoadToSpritePatternTable
	ld ix,FieldSet_may1_runLeft1
	call Tile_LoadToSpritePatternTable
	ld ix,FieldSet_may0_runLeft2
	call Tile_LoadToSpritePatternTable
	ld ix,FieldSet_may1_runLeft2
	call Tile_LoadToSpritePatternTable
	ld ix,FieldSet_may0_runLeft3
	call Tile_LoadToSpritePatternTable
	ld ix,FieldSet_may1_runLeft3
	call Tile_LoadToSpritePatternTable
	pop ix
	ret

; bc = dx (-1 left, 1 right)
; de = dy (-1 up, 1 down)
; ix = this
Player_Move: PROC
	sla c  ; speed x2
	rl b
	sla e
	rl d
	ld a,c
	and a
	jp m,Left
	jr nz,Right
	ld a,e
	and a
	jp m,Up
	jr nz,Down
	ld (ix + Player.moving),0
	jr Continue
Left:
	ld (ix + Player.direction),15
	ld (ix + Player.moving),1
	jr Continue
Right:
	ld (ix + Player.direction),5
	ld (ix + Player.moving),1
	jr Continue
Up:
	ld (ix + Player.direction),10
	ld (ix + Player.moving),1
	jr Continue
Down:
	ld (ix + Player.direction),0
	ld (ix + Player.moving),1
	jr Continue
Continue:
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
	call Player_GetSourcePatternOffset
	ld de,Player.sourcePatterns
	add ix,de
	ld de,Player_PATTERN * SpritePattern._size
	ld bc,8 * SpritePattern._size
	call VRAMTable_Copy
	ld de,-Player.sourcePatterns
	add ix,de
	ret

; ix = this
; hl <- pattern offset
Player_GetSourcePatternOffset: PROC
	bit 0,(ix + Player.moving)
	jr nz,Moving
NotMoving:
	xor a
	ld (ix + Player.movingStep),a
	jr Continue
Moving:
	ld a,(ix + Player.movingStep)
	inc a
	ld (ix + Player.movingStep),a
	srl a
	srl a
	srl a
	and 00000011B
	inc a
Continue:
	add a,(ix + Player.direction)
	ld l,0
	ld h,a
	ret
	ENDP
