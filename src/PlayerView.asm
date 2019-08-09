;
;
;
PlayerView_PATTERNS: equ 8

PlayerView: MACRO
	player:
		dw 0
	x:
		db 0
	y:
		db 0
	frame:
		db 0
	direction:
		db 0  ; 0 = down, 5 = left, 10 = up, 15 = right
	moving:
		db 0
	movingStep:
		db 0
	patternBase:
		db 0
	sourcePatterns:
		SpritePatternTable 1C000H
	patternCopy:
		VRAMTableCopy 0, 0, 8 * SpritePattern._size
	ENDM

; de = player
; ix = this
PlayerView_Construct:
	ld (ix + PlayerView.player),e
	ld (ix + PlayerView.player + 1),d
	push iy
	call PlayerView_GetPlayer_IY
	ld a,(iy + Player.x)
	ld (ix + PlayerView.x),a
	ld a,(iy + Player.y)
	ld (ix + PlayerView.y),a
	pop iy
	call PlayerView_LoadSourceSpritePatterns
	ret

; ix = this
; iy <- player
PlayerView_GetPlayer_IY:
	ld e,(ix + PlayerView.player)
	ld d,(ix + PlayerView.player + 1)
	ld iyl,e
	ld iyh,d
	ret

; ix = this
; iy = engine
PlayerView_TickPrimary:
	push iy
	call PlayerView_GetPlayer_IY
	call PlayerView_TickInterpolatePosition
	call PlayerView_TickMovingDirection
	pop iy
	inc (ix + PlayerView.frame)
	ret

; ix = this
; iy = player
PlayerView_TickInterpolatePosition:
	ld b,(ix + PlayerView.x)
	ld a,(iy + Player.x)
	sub b
	sra a
	add a,b
	ld (ix + PlayerView.x),a
	ld b,(ix + PlayerView.y)
	ld a,(iy + Player.y)
	sub b
	sra a
	add a,b
	ld (ix + PlayerView.y),a
	ret

; ix = this
; iy = player
PlayerView_TickMovingDirection:
	ld a,(iy + Player.velocityX)
	or (iy + Player.velocityY)
	add a,-1
	sbc a,a
	ld (ix + PlayerView.moving),a
	ld e,(iy + Player.control)
	ld d,(iy + Player.control + 1)
	ld iyl,e
	ld iyh,d
	ld a,(iy + PlayerControl.direction)
	and a
	ret m
	ld (ix + PlayerView.direction),a
	ret

; ix = this
; iy = engine
PlayerView_TickSecondary:
	push iy
	call PlayerView_GetPlayer_IY
	ld a,(iy + Player.x)
	ld (ix + PlayerView.x),a
	ld a,(iy + Player.y)
	ld (ix + PlayerView.y),a
	pop iy
	inc (ix + PlayerView.frame)
	ret

; b = sprites remaining
; c = write port
; ix = this
; iy = sprite attribute table
; b <- sprites remaining
; c <- write port
PlayerView_DrawSpriteAttributes: PROC
	ld a,b
	cp PlayerView_PATTERNS + 1
	ret c
	ld a,(ix + PlayerView.x)
	add a,(iy + SpriteAttributeTable.worldOffsetX)
	add a,-8
	ld h,a
	ld a,(ix + PlayerView.y)
	add a,(iy + SpriteAttributeTable.worldOffsetY)
	add a,-30
	ld l,a
	add a,16
	ld e,a
	ld a,(ix + PlayerView.patternBase)
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
	inc e
	inc e
	inc e
	inc e
	add a,d
	bit 0,(ix + PlayerView.frame)
	jr nz,ShadowContinue
	add a,d
ShadowContinue:
	SpriteAttributeTable_WriteAttribute_M h, e, a
	ret
	ENDP

; b = sprites remaining
; c = write port
; ix = this
; iy = sprite color table
; b <- sprites remaining
; c <- write port
PlayerView_DrawSpriteColors:
	ld a,b
	cp PlayerView_PATTERNS + 1
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
	call SpriteColorTable_WriteColorIY
	ld hl,SpriteColor_solid1
	jp SpriteColorTable_WriteColorIY

; ix = this
PlayerView_LoadSourceSpritePatterns:
	ld e,ixl
	ld d,ixh
	ld iy,PlayerView.sourcePatterns
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
PlayerView_InitializeSpritePatterns:
	ld a,b
	and 15  ; alignment for copy
	call nz,System_ThrowException
	ld a,SpritePatternTable_COUNT
	sub b
	ld (ix + PlayerView.patternBase),a
	REPT PlayerView_PATTERNS
	ld hl,SpritePattern_blank
	call SpritePatternTable_WritePatternIY
	ENDM
	ld hl,PlayerView_shadowPattern
	call SpritePatternTable_WritePatternIY
	ld hl,SpritePattern_blank
	call SpritePatternTable_WritePatternIY
	ret

; ix = this
; iy = sprite pattern table
PlayerView_DrawSpritePatterns:
	push iy
	ld e,ixl
	ld d,ixh
	ld iy,PlayerView.patternCopy
	add iy,de
	call PlayerView_GetSourcePatternOffset
	ld de,PlayerView.sourcePatterns
	add ix,de
	call VRAMTableCopy_SetSourceIY
	ld de,-PlayerView.sourcePatterns
	add ix,de
	ld l,(ix + PlayerView.patternBase)
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
PlayerView_GetSourcePatternOffset: PROC
	bit 0,(ix + PlayerView.moving)
	jr nz,Moving
NotMoving:
	xor a
	ld (ix + PlayerView.movingStep),a
	jr Continue
Moving:
	ld a,(ix + PlayerView.movingStep)
	inc (ix + PlayerView.movingStep)
	rra
	rra
	and 00000011B
	inc a
Continue:
	add a,(ix + PlayerView.direction)
	ld l,0
	ld h,a
	ret
	ENDP

;
PlayerView_shadowPattern:
	SpritePattern 0, 0, 0, 0, 0, 0, 0, 0,
	              0, 7, 31, 63, 63, 31, 7, 0,
	              0, 0, 0, 0, 0, 0, 0, 0,
	              0, 224, 248, 252, 252, 248, 224, 0
