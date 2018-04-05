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
	tileMap:
		dw 0
	sourcePatterns:
		SpritePatternTable 18000H
	patternCopy:
		VRAMTableCopy 0, 0, 8 * SpritePattern._size
	ENDM

; de = tile map
; ix = this
Player_Construct:
	ld (ix + Player.tileMap),e
	ld (ix + Player.tileMap + 1),d
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

; ix = this
; ix <- tile map
Player_GetTileMap:
	ld e,(ix + Player.tileMap)
	ld d,(ix + Player.tileMap + 1)
	ld ixl,e
	ld ixh,d
	ret

; ix = this
; bc <- x
; de <- y
Player_GetPosition:
	ld c,(ix + Player.x)
	ld b,(ix + Player.x + 1)
	ld e,(ix + Player.y)
	ld d,(ix + Player.y + 1)
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
	ld c,l
	ld b,h
	ld l,(ix + Player.y)
	ld h,(ix + Player.y + 1)
	add hl,de
	ex de,hl
	call Player_CanMove16x16
	jr nc,Blocked
	ld (ix + Player.x),c
	ld (ix + Player.x + 1),b
	ld (ix + Player.y),e
	ld (ix + Player.y + 1),d
	ret
Blocked:
	ld (ix + Player.moving),0
	ret
	ENDP

; bc = x
; de = y
; ix = this
; f <- c: can
Player_CanMove16x16:
	ld hl,-8
	add hl,bc
	ld c,l
	ld b,h
	ld hl,-8
	add hl,de
	ex de,hl
	call Player_CanMove
	ret nc
	ld hl,15
	add hl,de
	ex de,hl
	call Player_CanMove
	ret nc
	ld hl,15
	add hl,bc
	ld c,l
	ld b,h
	call Player_CanMove
	ret nc
	ld hl,-15
	add hl,de
	ex de,hl
	call Player_CanMove
	ret nc
	ld hl,-7
	add hl,bc
	ld c,l
	ld b,h
	ld hl,8
	add hl,de
	ex de,hl
	scf
	ret

; bc = x
; de = y
; ix = this
; f <- c: can
Player_CanMove:
	push bc
	push de
	push ix
	push de
	call Player_GetTileMap
	pop de
	call TileMap_PixelToTilePosition
	call TileMap_GetTile
	call Tile_GetCollision
	cp 128
	pop ix
	pop de
	pop bc
	ret

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
	add a,-30
	ld b,Player_PATTERN + 0 << 2
	SpriteAttributeTable_WriteAttribute_M h, a, b
	ld b,Player_PATTERN + 1 << 2
	SpriteAttributeTable_WriteAttribute_M h, a, b
	ld b,Player_PATTERN + 2 << 2
	SpriteAttributeTable_WriteAttribute_M h, a, b
	ld b,Player_PATTERN + 3 << 2
	SpriteAttributeTable_WriteAttribute_M h, a, b
	add a,16
	ld b,Player_PATTERN + 4 << 2
	SpriteAttributeTable_WriteAttribute_M h, a, b
	ld b,Player_PATTERN + 5 << 2
	SpriteAttributeTable_WriteAttribute_M h, a, b
	ld b,Player_PATTERN + 6 << 2
	SpriteAttributeTable_WriteAttribute_M h, a, b
	ld b,Player_PATTERN + 7 << 2
	SpriteAttributeTable_WriteAttribute_M h, a, b
	ret

; c = write port
; ix = this
; iy = sprite color table
Player_DrawSpriteColors:
	ld hl,SpriteColor_solid1
	call SpriteColorTable_WriteColorIY
	ld hl,SpriteColor_solid2CC
	call SpriteColorTable_WriteColorIY
	ld hl,SpriteColor_solid4CC
	call SpriteColorTable_WriteColorIY
	ld hl,SpriteColor_solid8CC
	call SpriteColorTable_WriteColorIY
	ld hl,SpriteColor_solid1
	call SpriteColorTable_WriteColorIY
	ld hl,SpriteColor_solid2CC
	call SpriteColorTable_WriteColorIY
	ld hl,SpriteColor_solid4CC
	call SpriteColorTable_WriteColorIY
	ld hl,SpriteColor_solid8CC
	jp SpriteColorTable_WriteColorIY

; ix = this
; iy = sprite pattern table
Player_DrawSpritePatterns:
	push iy
	ld e,ixl
	ld d,ixh
	ld iy,Player.patternCopy
	add iy,de
	call Player_GetSourcePatternOffset
	ld de,Player.sourcePatterns
	add ix,de
	call VRAMTableCopy_SetSourceIY
	ld de,-Player.sourcePatterns
	add ix,de
	ex (sp),ix
	ld hl,Player_PATTERN * SpritePattern._size
	call VRAMTableCopy_SetDestinationIY
	ex (sp),ix
	call VRAMTableCopy_ExecuteIY
	pop iy
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
	inc (ix + Player.movingStep)
	rra
	rra
	and 00000011B
	inc a
Continue:
	add a,(ix + Player.direction)
	ld l,0
	ld h,a
	ret
	ENDP
