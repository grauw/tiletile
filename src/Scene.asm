;
; A scene.
;
Scene: MACRO ?tileset, ?tilemap
	tileSet:
		dw ?tileset
	tileMap:
		dw ?tilemap
	input:
		dw 0
	mapView:
		MapView
	player:
		Player
	ENDM

; de = input
; ix = this
Scene_Construct:
	ld (ix + Scene.input),e
	ld (ix + Scene.input + 1),d

	push ix
	call Scene_GetTileMap
	ld e,ixl
	ld d,ixh
	pop ix
	push ix
	push de
	call Scene_GetMapView
	pop de
	call MapView_Construct
	pop ix

	push ix
	call Scene_GetPlayer
	call Player_Construct
	pop ix
	ret

; ix = this
Scene_GetTileSet:
	ld e,(ix + Scene.tileSet)
	ld d,(ix + Scene.tileSet + 1)
	ld ixl,e
	ld ixh,d
	ret

; ix = this
Scene_GetTileMap:
	ld e,(ix + Scene.tileMap)
	ld d,(ix + Scene.tileMap + 1)
	ld ixl,e
	ld ixh,d
	ret

; ix = this
Scene_GetInput_IY:
	ld e,(ix + Scene.input)
	ld d,(ix + Scene.input + 1)
	ld iyl,e
	ld iyh,d
	ret

; ix = this
Scene_GetMapView:
	ld de,Scene.mapView
	add ix,de
	ret

; ix = this
; ix <- player
Scene_GetPlayer:
	ld de,Scene.player
	add ix,de
	ret

; ix = this
; iy = video
Scene_Start:
	push ix
	call Scene_GetTileSet
	call TileSet_Load
	pop ix

	push iy
	call Video_GetDrawContextEvenIY_IY
	call DrawContext_GetSpritePatternTableIY_IY
	call Scene_InitializeSpritePatterns
	pop iy

	push iy
	call Video_GetDrawContextOddIY_IY
	call DrawContext_GetSpritePatternTableIY_IY
	call Scene_InitializeSpritePatterns
	pop iy

	push ix
	call Scene_GetMapView
	call MapView_Start
	pop ix
	ret

; ix = this
; iy = sprite pattern table
Scene_InitializeSpritePatterns:
	push ix
	call Scene_GetPlayer
	call Player_DrawSpritePatterns
	pop ix
	ret

; ix = this
; iy = draw context
Scene_Update:
	call Scene_UpdatePlayerPosition
	call Scene_UpdateMapViewPosition
	call Scene_UpdateSpriteAttributes
	call Scene_UpdateSpriteColors
	call Scene_SubmitDrawContext
	call Scene_UpdateMapViewPixels
	ret

; ix = this
Scene_UpdatePlayerPosition:
	IF DEBUG
	ld a,0
	in a,(2ch)
	ENDIF

	push iy
	call Scene_GetInput_IY
	push ix
	call Scene_GetPlayer
	call Input_GetDirectionIY
	call Player_Move
	pop ix
	pop iy

	IF DEBUG
	ld a,0
	out (2ch),a
	ENDIF
	ret

; ix = this
; iy = draw context
Scene_UpdateMapViewPosition:
	IF DEBUG
	ld a,1
	in a,(2ch)
	ENDIF

	push iy
	call DrawContext_GetDisplayOffsetIY_IY
	push ix
	call Scene_GetPlayer
	ld l,(ix + Player.x)
	ld h,(ix + Player.x + 1)
	ld e,(ix + Player.y)
	ld d,(ix + Player.y + 1)
	pop ix
	push ix
	push de
	call Scene_GetMapView
	call MapView_SetTargetX
	pop hl
	call MapView_SetTargetY
	call MapView_Update
	pop ix
	pop iy

	IF DEBUG
	ld a,1
	out (2ch),a
	ENDIF
	ret

; ix = this
; iy = draw context
Scene_UpdateSpriteAttributes:
	IF DEBUG
	ld a,2
	in a,(2ch)
	ENDIF

	push iy
	call DrawContext_GetDisplayOffsetIY_IY
	ld h,(iy + DisplayOffset.horizontalOffset)
	ld l,(iy + DisplayOffset.verticalOffset)
	pop iy
	push iy
	call DrawContext_GetSpriteAttributeTableIY_IY
	call SpriteAttributeTable_SetDisplayPositionIY
	ld a,0
	call SpriteAttributeTable_SetAttributeWriteIY
	push ix
	call Scene_GetPlayer
	call Player_DrawSpriteAttributes
	call Player_DrawSpriteAttributes
	call Player_DrawSpriteAttributes
	call Player_DrawSpriteAttributes
	pop ix
	pop iy

	IF DEBUG
	ld a,2
	out (2ch),a
	ENDIF
	ret

; ix = this
; iy = draw context
Scene_UpdateSpriteColors:
	IF DEBUG
	ld a,3
	in a,(2ch)
	ENDIF

	push iy
	call DrawContext_GetSpriteColorTableIY_IY
	ld a,0
	call SpriteColorTable_SetColorWriteIY
	push ix
	call Scene_GetPlayer
	call Player_DrawSpriteColors
	call Player_DrawSpriteColors
	call Player_DrawSpriteColors
	call Player_DrawSpriteColors
	pop ix
	pop iy

	IF DEBUG
	ld a,3
	out (2ch),a
	ENDIF
	ret

; ix = this
; iy = draw context
Scene_UpdateMapViewPixels:
	IF DEBUG
	ld a,4
	in a,(2ch)
	ENDIF

	push iy
	push ix
	call Scene_GetMapView
	call MapView_Move
	pop ix
	pop iy

	IF DEBUG
	ld a,4
	out (2ch),a
	ENDIF
	ret

; ix = this
; iy = draw context
Scene_SubmitDrawContext:
	IF DEBUG
	ld a,5
	in a,(2ch)
	ENDIF

	call DrawContext_SubmitIY

	IF DEBUG
	ld a,5
	out (2ch),a
	ENDIF
	ret
