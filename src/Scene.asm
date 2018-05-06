;
; A scene.
;
Scene: MACRO ?tileset, ?tilemap, ?uiImage
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
	dialog:
		Dialog ?uiImage
	mapView:
		MapView
	player:
		Player
	weather:
		Weather
	paletteFader:
		PaletteFader
	ENDM

; de = engine
; ix = this
Scene_Construct:
	ld (ix + Scene.engine),e
	ld (ix + Scene.engine + 1),d

	push ix
	call Scene_GetDialog
	call Dialog_Construct
	pop ix

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
	call Scene_GetWeather
	call Weather_Construct
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
; ix <- dialog
Scene_GetDialog:
	ld de,Scene.dialog
	add ix,de
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
; ix <- weather
Scene_GetWeather:
	ld de,Scene.weather
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
	push ix
	call Scene_GetTileSet
	call TileSet_Load
	pop ix

	push ix
	call Scene_GetDialog
	call Dialog_Load
	pop ix

	call Scene_GetEngine_IY

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
	ld a,0
	call SpritePatternTable_SetPatternWriteIY
	push ix
	call Scene_GetPlayer
	call Player_InitializeSpritePatterns
	pop ix
	push ix
	call Scene_GetWeather
	call Weather_InitializeSpritePatterns
	pop ix
	call SpritePatternTable_FinishWriteIY
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
	call Engine_WaitDisplayedIY
	ret
	ENDP

; ix = this
; iy = engine
Scene_Update:
	IF DEBUG
	PROFILE_FRAME_BEGIN
	ENDIF

	call Scene_UpdateTriggers
	call Engine_WaitDisplayedIY

	call Scene_UpdateInput
	call Scene_TickPrimary
	call Scene_UpdateGameFrame
	call Scene_UpdatePalette
	call Scene_DrawSpriteAttributes
	call Scene_DrawSpritePatterns
	call Scene_DrawSpriteColors
	call Engine_SubmitPrimaryIY

	call Scene_TickSecondary
	call Scene_DrawBitmap
	call Engine_WaitDisplayedIY  ; avoid having to triple-buffer the SAT
	call Engine_CopySpriteColorToSecondary
	call Scene_UpdateGameFrame
	call Scene_DrawSpriteAttributes
	call Engine_SubmitSecondaryIY

	IF DEBUG
	PROFILE_FRAME_END
	ENDIF
	ret

; ix = this
; iy = engine
Scene_UpdateInput:
	IF DEBUG
	PROFILE_BEGIN 0
	ENDIF
	push iy
	call Engine_GetInputIY

	call Input_UpdateIY

	push ix
	call Scene_GetPlayer
	call Player_UpdateInput
	pop ix

	push ix
	call Scene_GetWeather
	call Weather_UpdateInput
	pop ix

	call Scene_UpdateExit
	call Scene_UpdateDisplayFrequency

	pop iy
	IF DEBUG
	PROFILE_END 0
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
Scene_TickPrimary:
	IF DEBUG
	PROFILE_BEGIN 1
	ENDIF

	push ix
	call Scene_GetPlayer
	call Player_TickPrimary
	pop ix

	push ix
	call Scene_GetWeather
	call Weather_TickPrimary
	pop ix

	call Scene_Tick

	IF DEBUG
	PROFILE_END 1
	ENDIF
	ret

; ix = this
; iy = engine
Scene_TickSecondary:
	IF DEBUG
	PROFILE_BEGIN 1
	ENDIF

	push ix
	call Scene_GetPlayer
	call Player_TickSecondary
	pop ix

	push ix
	call Scene_GetWeather
	call Weather_TickSecondary
	pop ix

	call Scene_Tick

	IF DEBUG
	PROFILE_END 1
	ENDIF
	ret

; ix = this
; iy = engine
Scene_Tick:
	push ix
	call Scene_GetPlayer
	call Player_GetPosition
	pop ix
	push ix
	ex de,hl
	call Scene_GetMapView
	ex de,hl
	call MapView_SetTargetPosition
	pop ix

	push ix
	call Scene_GetDialog
	call Dialog_Tick
	pop ix
	ret

; ix = this
; iy = engine
Scene_UpdatePalette: PROC
	IF DEBUG
	PROFILE_BEGIN 6
	ENDIF

	ld de,Palette_black
	call Scene_UpdatePaletteFade
	push ix
	push de
	call Scene_GetWeather
	pop de
	call Weather_UpdatePalette
	pop ix
	call Engine_SetPaletteIY

	IF DEBUG
	PROFILE_END 6
	ENDIF
	ret
	ENDP

; de = palette
; ix = this
; de <- palette
Scene_UpdatePaletteFade: PROC
	bit 0,(ix + Scene.exiting)
	jr nz,Exiting
	push ix
	call Scene_GetPaletteFader
	call PaletteFader_GetNextPalette
	ld e,ixl
	ld d,ixh
	pop ix
	ret
Exiting:
	push ix
	call Scene_GetPaletteFader
	call PaletteFader_GetPreviousPalette
	ld e,ixl
	ld d,ixh
	pop ix
	and a
	ret nz
	ld (ix + Scene.exit),1
	ret
	ENDP

; ix = this
; iy = engine
Scene_UpdateGameFrame:
	IF DEBUG
	PROFILE_BEGIN 2
	ENDIF
	push iy
	call Engine_GetGameFrameIY

	push ix
	call Scene_GetMapView
	call MapView_UpdateGameFrame
	pop ix

	push ix
	call Scene_GetDialog
	call Dialog_UpdateGameFrame
	pop ix

	pop iy
	IF DEBUG
	PROFILE_END 2
	ENDIF
	ret

; ix = this
; iy = engine
Scene_DrawSpriteAttributes:
	IF DEBUG
	PROFILE_BEGIN 5
	ENDIF
	push iy
	call Engine_GetSpriteAttributeTableIY

	push ix
	call Scene_GetMapView
	call MapView_UpdateSpriteAttributTable
	pop ix

	ld a,0
	call SpriteAttributeTable_SetAttributeWriteIY
	push ix
	call Scene_GetWeather
	call Weather_DrawSpriteAttributes
	pop ix
	push ix
	call Scene_GetPlayer
	call Player_DrawSpriteAttributes
	pop ix
	call SpriteAttributeTable_FinishWriteIY

	pop iy
	IF DEBUG
	PROFILE_END 5
	ENDIF
	ret

; ix = this
; iy = engine
Scene_DrawSpriteColors:
	IF DEBUG
	PROFILE_BEGIN 4
	ENDIF
	push iy
	call Engine_GetSpriteColorTableIY

	ld a,0
	call SpriteColorTable_SetColorWriteIY
	push ix
	call Scene_GetWeather
	call Weather_DrawSpriteColors
	pop ix
	push ix
	call Scene_GetPlayer
	call Player_DrawSpriteColors
	pop ix
	call SpriteColorTable_FinishWriteIY

	pop iy
	IF DEBUG
	PROFILE_END 4
	ENDIF
	ret

; ix = this
; iy = engine
Scene_DrawSpritePatterns:
	IF DEBUG
	PROFILE_BEGIN 3
	ENDIF
	push iy
	call Engine_GetSpritePatternTableIY

	push ix
	call Scene_GetPlayer
	call Player_DrawSpritePatterns
	pop ix

	pop iy
	IF DEBUG
	PROFILE_END 3
	ENDIF
	ret

; ix = this
; iy = engine
Scene_DrawBitmap:
	IF DEBUG
	PROFILE_BEGIN 7
	ENDIF

	push iy
	push ix
	call Scene_GetMapView
	call MapView_DrawBitmap
	pop ix
	pop iy

	push iy
	push ix
	call Scene_GetDialog
	call Dialog_DrawBitmap
	pop ix
	pop iy

	IF DEBUG
	PROFILE_END 7
	ENDIF
	ret

; ix = this
; iy = engine
Scene_UpdateTriggers:
	IF DEBUG
	PROFILE_BEGIN 8
	ENDIF

	push ix
	call Scene_GetPlayer
	call Player_GetTile
	Tile_GetCollision_M ix, a
	pop ix

	push ix
	call Scene_GetWeather
	call Weather_UpdateTriggers
	pop ix

	push ix
	call Scene_GetDialog
	call Dialog_UpdateTriggers
	pop ix

	IF DEBUG
	PROFILE_END 8
	ENDIF
	ret
