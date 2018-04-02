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
	exiting:
		db 0
	exit:
		db 0
	mapView:
		MapView
	player:
		Player
	rain:
		Rain
	paletteFader:
		PaletteFader
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

	push ix
	call Scene_GetTileSet
	call TileSet_GetPalette
	pop ix
	push ix
	push de
	call Scene_GetPaletteFader
	pop de
	ld hl,Palette_black
	call PaletteFader_Construct
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
; ix <- palette fader
Scene_GetPaletteFader:
	ld de,Scene.paletteFader
	add ix,de
	ret

; ix = this
Scene_Start:
	call Scene_GetEngine_IY

	push ix
	call Scene_GetTileSet
	call TileSet_Load
	pop ix

	push iy
	call Engine_GetSpritePatternTableEvenIY
	call Scene_InitializeSpritePatterns
	pop iy

	push iy
	call Engine_GetSpritePatternTableOddIY
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
Scene_Run: PROC
	call Scene_GetEngine_IY
Loop:
	call Scene_Update
	bit 0,(ix + Scene.exit)
	jr z,Loop
	call Video_WaitDisplayedIY
	ret
	ENDP

; ix = this
; iy = engine
Scene_Update:
	IF DEBUG
	PROFILE_FRAME_BEGIN
	ENDIF

	call Scene_UpdateInput
	call Scene_UpdatePalette
	call Scene_UpdatePlayerPosition
	call Scene_UpdateMapViewPosition
	call Scene_UpdateSpritePatterns
	call Scene_UpdateSpriteColors
	call Scene_UpdateSpriteAttributes
	call Engine_SubmitPrimaryIY

	call Scene_UpdatePlayerPosition
	call Scene_UpdateMapViewPosition
	call Scene_UpdateMapViewPixels
	push iy
	call Engine_GetVideoIY
	call Video_WaitDisplayedIY  ; avoid having to triple-buffer the SAT
	pop iy
	call Engine_CopySpriteColorToSecondary
	call Scene_UpdateSpriteAttributes

	IF DEBUG
	PROFILE_FRAME_END
	ENDIF

	call Engine_SubmitSecondaryIY
	ret

; ix = this
; iy = engine
Scene_UpdateInput:
	IF DEBUG
	PROFILE_BEGIN 8
	ENDIF
	push iy
	call Engine_GetInputIY

	call Input_UpdateIY

	call Scene_UpdateExit
	call Scene_UpdateDisplayFrequency

	pop iy
	IF DEBUG
	PROFILE_END 8
	ENDIF
	ret

; ix = this
; iy = input
Scene_UpdateExit:
	bit 2,(iy + Input.newKey + 7)  ; ESC
	ret nz
	ld (ix + Scene.exiting),1
	ret

; ix = this
; iy = input
Scene_UpdateDisplayFrequency:
	bit 6,(iy + Input.newKey + 7)  ; SELECT
	ret nz
	bit 6,(iy + Input.oldKey + 7)  ; key down
	ret z
	push iy
	call Scene_GetEngine_IY
	call Engine_GetVideoIY
	call Video_ToggleFrequencyIY
	pop iy
	ret

; ix = this
; iy = engine
Scene_UpdatePlayerPosition:
	IF DEBUG
	PROFILE_BEGIN 0
	ENDIF
	push iy
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
	PROFILE_END 0
	ENDIF
	ret

; ix = this
; iy = engine
Scene_UpdatePalette: PROC
	bit 0,(ix + Scene.exiting)
	jr nz,Exiting
	push ix
	call Scene_GetPaletteFader
	call PaletteFader_GetNextPalette
	ld e,ixl
	ld d,ixh
	call Engine_SetPaletteIY
	pop ix
	ret
Exiting:
	push ix
	call Scene_GetPaletteFader
	call PaletteFader_GetPreviousPalette
	ld e,ixl
	ld d,ixh
	call Engine_SetPaletteIY
	pop ix
	and a
	ret nz
	ld (ix + Scene.exit),1
	ret
	ENDP

; ix = this
; iy = engine
Scene_UpdateMapViewPosition:
	IF DEBUG
	PROFILE_BEGIN 1
	ENDIF
	push iy
	call Engine_GetDisplayOffsetIY

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
	PROFILE_END 1
	ENDIF
	ret

; ix = this
; iy = engine
Scene_UpdateSpriteAttributes:
	IF DEBUG
	PROFILE_BEGIN 2
	ENDIF
	push iy
	call Engine_GetSpriteAttributeTableIY

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
	PROFILE_END 2
	ENDIF
	ret

; ix = this
; iy = engine
Scene_UpdateSpriteColors:
	IF DEBUG
	PROFILE_BEGIN 3
	ENDIF
	push iy
	call Engine_GetSpriteColorTableIY

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
	PROFILE_END 3
	ENDIF
	ret

; ix = this
; iy = engine
Scene_UpdateSpritePatterns:
	IF DEBUG
	PROFILE_BEGIN 7
	ENDIF
	push iy
	call Engine_GetSpritePatternTableIY

	push ix
	call Scene_GetPlayer
	call Player_DrawSpritePatterns
	pop ix

	pop iy
	IF DEBUG
	PROFILE_END 7
	ENDIF
	ret

; ix = this
; iy = engine
Scene_UpdateMapViewPixels:
	IF DEBUG
	PROFILE_BEGIN 4
	ENDIF

	push iy
	push ix
	call Scene_GetMapView
	call MapView_Move
	pop ix
	pop iy

	IF DEBUG
	PROFILE_END 4
	ENDIF
	ret
