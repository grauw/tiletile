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
		dw 0
	velocityY:
		dw 0
	direction:
		db 0  ; 0 = down, 5 = left, 10 = up, 15 = right
	moving:
		db 0
	movingStep:
		db 0
	tileMap:
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
		dw x * Player_SPEED
	velocityY:
		dw y * Player_SPEED
	direction:
		db x < 0 ? 15 : x > 0 ? 5 : y < 0 ? 10 : 0
	_size:
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

; ix = this
; ix <- tile
Player_GetTile:
	ld c,(ix + Player.x)
	ld b,(ix + Player.x + 1)
	ld e,(ix + Player.y)
	ld d,(ix + Player.y + 1)
	ex de,hl
	call Player_GetTileMap
	ex de,hl
	call TileMap_PixelToTilePosition
	call TileMap_GetTile
	ret

; ix = this
; iy = input
Player_UpdateInput:
	ld a,(iy + Input.newStick)
	and 0FH
	ld b,a
	add a,a
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
	call Player_TickSecondary
	pop iy
	ret

; ix = this
; iy = engine
Player_TickSecondary:
	ld l,(ix + Player.x)
	ld h,(ix + Player.x + 1)
	ld c,(ix + Player.velocityX)
	ld b,(ix + Player.velocityX + 1)
	add hl,bc
	ld (ix + Player.x),l
	ld (ix + Player.x + 1),h
	ld l,(ix + Player.y)
	ld h,(ix + Player.y + 1)
	ld c,(ix + Player.velocityY)
	ld b,(ix + Player.velocityY + 1)
	add hl,bc
	ld (ix + Player.y),l
	ld (ix + Player.y + 1),h
	ret

; ix = this
; iy = control
Player_TickVelocity:
	ld c,(iy + PlayerControl.velocityX)
	ld b,(iy + PlayerControl.velocityX + 1)
	ld e,(iy + PlayerControl.velocityY)
	ld d,(iy + PlayerControl.velocityY + 1)
	ld (ix + Player.velocityX),c
	ld (ix + Player.velocityX + 1),b
	ld (ix + Player.velocityY),e
	ld (ix + Player.velocityY + 1),d
	ld l,(ix + Player.x)
	ld h,(ix + Player.x + 1)
	add hl,bc
	add hl,bc
	ld c,l
	ld b,h
	ld l,(ix + Player.y)
	ld h,(ix + Player.y + 1)
	add hl,de
	add hl,de
	ex de,hl
	call Player_CanMove16x16
	ret c
	ld (ix + Player.velocityX),0
	ld (ix + Player.velocityX + 1),0
	ld (ix + Player.velocityY),0
	ld (ix + Player.velocityY + 1),0
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

; bc = x
; de = y
; ix = this
; f <- c: can
Player_CanMove16x16:
	ld hl,-Player_COLLIDER_WIDTH / 2
	add hl,bc
	ld c,l
	ld b,h
	ld hl,-Player_COLLIDER_HEIGHT / 2
	add hl,de
	ex de,hl
	call Player_CanMove
	ret nc
	ld hl,Player_COLLIDER_HEIGHT - 1
	add hl,de
	ex de,hl
	call Player_CanMove
	ret nc
	ld hl,Player_COLLIDER_WIDTH - 1
	add hl,bc
	ld c,l
	ld b,h
	call Player_CanMove
	ret nc
	ld hl,-(Player_COLLIDER_HEIGHT - 1)
	add hl,de
	ex de,hl
	call Player_CanMove
	ret nc
	ld hl,-(Player_COLLIDER_WIDTH / 2 - 1)
	add hl,bc
	ld c,l
	ld b,h
	ld hl,Player_COLLIDER_HEIGHT / 2
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
	ex de,hl
	call Player_GetTileMap
	ex de,hl
	call TileMap_PixelToTilePosition
	call TileMap_GetTile
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
	ld l,(ix + Player.patternBase)
	REPT 4
	SpriteAttributeTable_WriteAttribute_M h, a, l
	inc l
	inc l
	inc l
	inc l
	ENDM
	add a,16
	REPT 3
	SpriteAttributeTable_WriteAttribute_M h, a, l
	inc l
	inc l
	inc l
	inc l
	ENDM
	SpriteAttributeTable_WriteAttribute_M h, a, l
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
