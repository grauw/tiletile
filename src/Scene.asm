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
	sprites:
		Sprites
	player:
		Player
	ENDM

; de = input
; ix = this
Scene_Construct:
	ld (ix + Scene.input),e
	ld (ix + Scene.input + 1),d

	push ix
	call Scene_GetSprites
	call Sprites_Construct
	pop ix
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
	call Scene_GetSpritesIY
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
; ix <- sprites
Scene_GetSprites:
	ld de,Scene.sprites
	add ix,de
	ret

; ix = this
; iy <- sprites
Scene_GetSpritesIY:
	ld e,ixl
	ld d,ixh
	ld iy,Scene.sprites
	add iy,de
	ret

; ix = this
; ix <- player
Scene_GetPlayer:
	ld de,Scene.player
	add ix,de
	ret

; ix = this
Scene_Start:
	push ix
	call Scene_GetTileSet
	call TileSet_Load
	pop ix

	push ix
	call Scene_GetSprites
	call Sprites_InitializeTables
	pop ix

	push ix
	call Scene_GetMapView
	call MapView_Start
	pop ix

	push ix
	call Scene_GetPlayer
	call Player_Start
	pop ix
	ret

; iy = draw context
; ix = this
Scene_Update:
	push iy

	IF DEBUG
	ld a,0
	in a,(2ch)
	ENDIF

	call Scene_UpdatePlayerPosition
	call Scene_UpdateMapViewPosition

	pop iy
	push iy
	call DrawContext_GetDisplayOffsetIY_IY
	push ix
	call Scene_GetMapView
	call MapView_Update
	pop ix

	IF DEBUG
	ld a,0
	out (2ch),a
	ENDIF

	IF DEBUG
	ld a,1
	in a,(2ch)
	ENDIF

	push ix
	push ix
	call Scene_GetMapView
	call MapView_GetTargetPosition
	pop ix
	push de
	call Scene_GetSprites
	pop de
	call Sprites_SetPosition
	pop ix

	pop iy
	push iy
	push ix
	call Scene_GetSprites
	push iy
	call DrawContext_GetSpriteAttributeTableIY_IY
	call Sprites_DrawAttributes
	pop iy
	push iy
	call DrawContext_GetSpriteColorTableIY_IY
	call Sprites_DrawColors
	pop iy
	pop ix

	IF DEBUG
	ld a,1
	out (2ch),a
	ENDIF

	IF DEBUG
	ld a,2
	in a,(2ch)
	ENDIF

	push ix
	call Scene_GetMapView
	call MapView_Move
	pop ix

	IF DEBUG
	ld a,2
	out (2ch),a
	ENDIF

	IF DEBUG
	ld a,3
	in a,(2ch)
	ENDIF

	ex (sp),ix
	call DrawContext_Submit
	ex (sp),ix

	IF DEBUG
	ld a,3
	out (2ch),a
	ENDIF

	pop iy
	ret

; ix = this
Scene_UpdatePlayerPosition:
	call Scene_GetInput_IY
	push ix
	call Scene_GetPlayer
	call Input_GetDirectionIY
	call Player_Move
	pop ix
	ret

; ix = this
Scene_UpdateMapViewPosition:
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
	pop ix
	ret
