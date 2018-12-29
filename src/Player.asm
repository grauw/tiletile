;
;
;
Player_SPEED: equ 2
Player_PATTERNS: equ 8
Player_COLLIDER_WIDTH: equ 16
Player_COLLIDER_HEIGHT: equ 8

Player: MACRO
	x:
		dw 124
	y:
		dw 120
	control:
		dw Player_controlLUT + 15 * PlayerControl._size
	velocityX:
		db 0
	velocityY:
		db 0
	direction:
		db 0  ; 0 = down, 5 = left, 10 = up, 15 = right
	moving:
		db 0
	movingStep:
		db 0
	tileMap:
		dw 0
	tileMapWidthStride:
		dw 0
	currentTile:
		dw 0
	patternBase:
		db 0
	sourcePatterns:
		SpritePatternTable 1C000H
	patternCopy:
		VRAMTableCopy 0, 0, 8 * SpritePattern._size
	ENDM

PlayerControl: MACRO ?rldu
	x: equ (?rldu >> 3 & 1) - (?rldu >> 2 & 1)
	y: equ (?rldu >> 1 & 1) - (?rldu >> 0 & 1)
	velocityX:
		db x * Player_SPEED
	velocityY:
		db y * Player_SPEED
	direction:
		db x < 0 ? 15 : x > 0 ? 5 : y < 0 ? 10 : 0
	_size:
	ENDM

; de = tile map
; ix = this
Player_Construct:
	ld (ix + Player.tileMap),e
	ld (ix + Player.tileMap + 1),d
	push ix
	call Player_GetTileMap
	ld l,(ix + TileMap.widthStride)
	ld h,(ix + TileMap.widthStride + 1)
	pop ix
	ld (ix + Player.tileMapWidthStride),l
	ld (ix + Player.tileMapWidthStride + 1),h
	call Player_LoadSourceSpritePatterns
	ld bc,124
	ld de,120
	call Player_SetPosition
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

; bc <- x
; de <- y
; ix = this
Player_SetPosition:
	ld (ix + Player.x),c
	ld (ix + Player.x + 1),b
	ld (ix + Player.y),e
	ld (ix + Player.y + 1),d
	push ix
	ex de,hl
	call Player_GetTileMap
	ex de,hl
	call TileMap_PixelToTilePosition
	call TileMap_GetTileDataPointer
	pop ix
	ld (ix + Player.currentTile),l
	ld (ix + Player.currentTile + 1),h
	ret

; ix = this
; ix <- tile
Player_GetTile:
	ld l,(ix + Player.currentTile)
	ld h,(ix + Player.currentTile + 1)
	ld a,(hl)
	ld ixl,a
	inc l
	ld a,(hl)
	ld ixh,a
	ret

; c = x offset (range: -16 .. 16)
; e = y offset (range: -16 .. 16)
; ix = this
; ix <- tile
Player_GetTileWithOffset:
	call Player_GetTileDataPointerWithOffset
	ld a,(hl)
	ld ixl,a
	inc l
	ld a,(hl)
	ld ixh,a
	ret

; c = x offset (range: -16 .. 16)
; e = y offset (range: -16 .. 16)
; ix = this
; hl <- tile pointer
Player_GetTileDataPointerWithOffset: PROC
	ld l,(ix + Player.currentTile)
	ld h,(ix + Player.currentTile + 1)
	ld a,(ix + Player.x)
	and 0FH
	add a,c
	and 0F0H
	jr z,ContinueX
	jp p,IncreaseX
DecreaseX:
	dec hl
	dec hl
	jr ContinueX
IncreaseX:
	inc hl
	inc hl
ContinueX:
	ld a,(ix + Player.y)
	and 0FH
	add a,e
	and 0F0H
	ret z
	ld e,(ix + Player.tileMapWidthStride)
	ld d,(ix + Player.tileMapWidthStride + 1)
	jp p,IncreaseY
DecreaseY:
	sbc hl,de
	ret
IncreaseY:
	add hl,de
	ret
	ENDP

; ix = this
; iy = input
Player_UpdateInput:
	ld a,(iy + Input.newStick)
	and 0FH
	ld b,a
	add a,a
	add a,b
	add a,Player_controlLUT & 0FFH
	ld (ix + Player.control),a
	ld a,0
	adc a,Player_controlLUT >> 8
	ld (ix + Player.control + 1),a
	ret

; ix = this
; iy = engine
Player_TickPrimary:
	push iy
	ld e,(ix + Player.control)
	ld d,(ix + Player.control + 1)
	ld iyl,e
	ld iyh,d
	call Player_TickVelocity
	call Player_TickMovingDirection
	call Player_TickPosition
	pop iy
	call Player_TickSecondary
	ret

; ix = this
; iy = engine
Player_TickSecondary:
	ld l,(ix + Player.x)
	ld h,(ix + Player.x + 1)
	ld c,(ix + Player.velocityX)
	ld a,c
	add a,a
	sbc a,a  ; sign extend
	ld b,a
	add hl,bc
	ld (ix + Player.x),l
	ld (ix + Player.x + 1),h
	ld l,(ix + Player.y)
	ld h,(ix + Player.y + 1)
	ld c,(ix + Player.velocityY)
	ld a,c
	add a,a
	sbc a,a  ; sign extend
	ld b,a
	add hl,bc
	ld (ix + Player.y),l
	ld (ix + Player.y + 1),h
	ret

; ix = this
; iy = control
Player_TickMovingDirection:
	ld a,(ix + Player.velocityX)
	or (ix + Player.velocityY)
	add a,-1
	sbc a,a
	ld (ix + Player.moving),a
	and a
	ret z
	ld a,(iy + PlayerControl.direction)
	ld (ix + Player.direction),a
	ret

; ix = this
Player_TickPosition:
	ld c,(ix + Player.velocityX)
	ld e,(ix + Player.velocityY)
	sla c
	sla e
	call Player_GetTileDataPointerWithOffset
	ld (ix + Player.currentTile),l
	ld (ix + Player.currentTile + 1),h
	ret

; ix = this
; iy = control
Player_TickVelocity:
	ld c,(iy + PlayerControl.velocityX)
	ld e,(iy + PlayerControl.velocityY)
	ld (ix + Player.velocityX),c
	ld (ix + Player.velocityY),e
	sla c
	sla e
	call Player_CanMove16x16
	ret c
	ld (ix + Player.velocityX),0
	ld (ix + Player.velocityY),0
	ret

; c = x
; e = y
; ix = this
; f <- c: can
Player_CanMove16x16:
	ld a,c
	add a,-Player_COLLIDER_WIDTH / 2
	ld c,a
	ld a,e
	add a,-Player_COLLIDER_HEIGHT / 2
	ld e,a
	call Player_CanMove
	ret nc
	ld a,e
	add a,Player_COLLIDER_HEIGHT - 1
	ld e,a
	call Player_CanMove
	ret nc
	ld a,c
	add a,Player_COLLIDER_WIDTH - 1
	ld c,a
	call Player_CanMove
	ret nc
	ld a,e
	add a,-(Player_COLLIDER_HEIGHT - 1)
	ld e,a
	call Player_CanMove
	ret nc
	ld a,c
	add a,-(Player_COLLIDER_WIDTH / 2 - 1)
	ld c,a
	ld a,e
	add a,Player_COLLIDER_HEIGHT / 2
	ld e,a
	scf
	ret

; c = x
; e = y
; ix = this
; f <- c: can
Player_CanMove:
	push bc
	push de
	push ix
	call Player_GetTileWithOffset
	Tile_IsSolid_M ix
	pop ix
	pop de
	pop bc
	scf
	ret z
	ccf
	ret

; b = sprites remaining
; c = write port
; ix = this
; iy = sprite attribute table
; b <- sprites remaining
; c <- write port
Player_DrawSpriteAttributes:
	ld a,b
	cp 8
	ret c
	ld a,(ix + Player.x)
	add a,(iy + SpriteAttributeTable.worldOffsetX)
	add a,-8
	ld h,a
	ld a,(ix + Player.y)
	add a,(iy + SpriteAttributeTable.worldOffsetY)
	add a,-30
	ld l,a
	add a,16
	ld e,a
	ld a,(ix + Player.patternBase)
	ld d,4
	SpriteAttributeTable_WriteAttribute_M h, l, a
	add a,d
	SpriteAttributeTable_WriteAttribute_M h, l, a
	add a,d
	SpriteAttributeTable_WriteAttribute_M h, l, a
	add a,d
	SpriteAttributeTable_WriteAttribute_M h, l, a
	add a,d
	SpriteAttributeTable_WriteAttribute_M h, e, a
	add a,d
	SpriteAttributeTable_WriteAttribute_M h, e, a
	add a,d
	SpriteAttributeTable_WriteAttribute_M h, e, a
	add a,d
	SpriteAttributeTable_WriteAttribute_M h, e, a
	ret

; b = sprites remaining
; c = write port
; ix = this
; iy = sprite color table
; b <- sprites remaining
; c <- write port
Player_DrawSpriteColors:
	ld a,b
	cp 8
	ret c
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

; b = patterns remaining (x4)
; c = write port
; ix = this
; iy = sprite pattern table
; b <- patterns remaining (x4)
; c <- write port
Player_LoadSourceSpritePatterns:
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

; b = patterns remaining (x4)
; c = write port
; ix = this
; iy = sprite pattern table
; b <- patterns remaining (x4)
; c <- write port
Player_InitializeSpritePatterns:
	ld a,b
	and 3
	call nz,System_ThrowException
	ld a,SpritePatternTable_COUNT
	sub b
	ld (ix + Player.patternBase),a
	REPT Player_PATTERNS
	ld hl,SpritePattern_blank
	call SpritePatternTable_WritePatternIY
	ENDM
	ret

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
	ld l,(ix + Player.patternBase)
	ld h,0
	add hl,hl
	add hl,hl
	add hl,hl
	ex (sp),ix
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

;
Player_controlLUT:
	REPT 16, ?value
	PlayerControl ?value ^ 15
	ENDM
