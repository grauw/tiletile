;
; A scene.
;
Scene: MACRO ?tileset, ?tilemap
	engine:
		dw 0
	tileSet:
		dw ?tileset
	tileMap:
		dw ?tilemap
	mapView:
		MapView
	player:
		Player
	rain:
		Rain
	ENDM

; de = engine
; ix = this
Scene_Construct:
	ld (ix + Scene.engine),e
	ld (ix + Scene.engine + 1),d

	push ix
	call Scene_GetTileMap_DE
	push de
	call Scene_GetMapView
	pop de
	call MapView_Construct
	pop ix

	push ix
	call Scene_GetTileMap_DE
	push de
	call Scene_GetPlayer
	pop de
	call Player_Construct
	pop ix

	push ix
	call Scene_GetRain
	call Rain_Construct
	pop ix
	ret

; ix = this
; iy <- engine
Scene_GetEngine_IY:
	ld e,(ix + Scene.engine)
	ld d,(ix + Scene.engine + 1)
	ld iyl,e
	ld iyh,d
	ret

; ix = this
; ix <- tile set
Scene_GetTileSet:
	ld e,(ix + Scene.tileSet)
	ld d,(ix + Scene.tileSet + 1)
	ld ixl,e
	ld ixh,d
	ret

; ix = this
; ix <- tile map
Scene_GetTileMap:
	ld e,(ix + Scene.tileMap)
	ld d,(ix + Scene.tileMap + 1)
	ld ixl,e
	ld ixh,d
	ret

; ix = this
; de <- tile map
Scene_GetTileMap_DE:
	ld e,(ix + Scene.tileMap)
	ld d,(ix + Scene.tileMap + 1)
	ret

; ix = this
; ix <- map view
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
; ix <- rain
Scene_GetRain:
	ld de,Scene.rain
	add ix,de
	ret

; ix = this
Scene_Start:
	call Scene_GetEngine_IY
	call Engine_GetVideoIY

	push ix
	call Scene_GetTileSet
	call TileSet_Load
	pop ix

	push iy
	call Video_GetDrawContextEvenIY
	call DrawContext_GetSpritePatternTableIY
	call Scene_InitializeSpritePatterns
	pop iy

	push iy
	call Video_GetDrawContextOddIY
	call DrawContext_GetSpritePatternTableIY
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
	call Scene_GetRain
	call Rain_DrawSpritePatterns
	pop ix
	ret

; ix = this
Scene_Stop:
	ret

; ix = this
Scene_Run:
	call Scene_GetEngine_IY
	call Engine_GetVideoIY
	call Video_GetDrawContextEvenIY
	push iy
	call Scene_Update
	call Scene_GetEngine_IY
	call Engine_GetVideoIY
	pop de
	call Video_SubmitDrawContextIY

	call Scene_GetEngine_IY
	call Engine_GetVideoIY
	call Video_GetDrawContextOddIY
	push iy
	call Scene_Update
	call Scene_GetEngine_IY
	call Engine_GetVideoIY
	pop de
	call Video_SubmitDrawContextIY

	jr Scene_Run

; ix = this
; iy = draw context
Scene_Update:
	IF DEBUG
	in a,(2dh)
	ENDIF

	push iy
	call Scene_GetEngine_IY
	call Engine_GetInputIY
	call Input_UpdateIY
	pop iy

	call Scene_UpdatePlayerPosition
	call Scene_UpdateMapViewPosition
	call Scene_UpdateSpritePatterns
	call Scene_UpdateSpriteAttributes
	call Scene_UpdateSpriteColors
	call Scene_UpdateMapViewPixels

	IF DEBUG
	out (2dh),a
	ENDIF
	ret

; ix = this
Scene_UpdatePlayerPosition:
	IF DEBUG
	ld a,0
	in a,(2ch)
	ENDIF

	push iy
	call Scene_GetEngine_IY
	call Engine_GetInputIY

	push ix
	call Scene_GetPlayer
	call Input_GetDirectionIY
	call Player_Move
	pop ix

	push ix
	call Scene_GetRain
	call Rain_Tick
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
	call DrawContext_GetDisplayOffsetIY
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
	call DrawContext_GetDisplayOffsetIY
	ld h,(iy + DisplayOffset.horizontalOffset)
	ld l,(iy + DisplayOffset.verticalOffset)
	pop iy
	push iy
	call DrawContext_GetSpriteAttributeTableIY
	call SpriteAttributeTable_SetDisplayPositionIY
	ld a,0
	call SpriteAttributeTable_SetAttributeWriteIY
	push ix
	call Scene_GetRain
	call Rain_DrawSpriteAttributes
	pop ix
	push ix
	call Scene_GetPlayer
	call Player_DrawSpriteAttributes
	call Player_DrawSpriteAttributes
	call Player_DrawSpriteAttributes
	pop ix
	call SpriteAttributeTable_FinishWriteIY
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
	call DrawContext_GetSpriteColorTableIY
	ld a,0
	call SpriteColorTable_SetColorWriteIY
	push ix
	call Scene_GetRain
	call Rain_DrawSpriteColors
	pop ix
	push ix
	call Scene_GetPlayer
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
Scene_UpdateSpritePatterns:
	IF DEBUG
	ld a,7
	in a,(2ch)
	ENDIF

	push iy
	call DrawContext_GetSpritePatternTableIY
	push ix
	call Scene_GetPlayer
	call Player_DrawSpritePatterns
	pop ix
	pop iy

	IF DEBUG
	ld a,7
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
