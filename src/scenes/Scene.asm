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
	call Scene_GetTileSet
	pop ix
	push ix
	push de
	call Scene_GetSpritesIY
	call Scene_GetPlayer
	pop de
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

; ix = this
Scene_Update:
	push ix
	call Scene_GetMapView
	call MapView_Update
	pop ix

	push ix
	call Scene_GetSprites
	call Sprites_SwapTables
	pop ix

	push ix
	call Scene_GetPlayer
	call Player_Update
	pop ix

	call Scene_UpdatePosition

	push ix
	push ix
	call Scene_GetMapView
	call MapView_GetPosition
	pop ix
	push de
	call Scene_GetSprites
	pop de
	call Sprites_SetPosition
	call Sprites_Draw
	pop ix
	ret

; ix = this
Scene_UpdatePosition:
	call Scene_GetInput_IY
	push ix
	call Scene_GetMapView
	bit 4,(iy + Input.newKey + 8)
	push iy
	call z,MapView_MoveLeft
	pop iy
	bit 7,(iy + Input.newKey + 8)
	push iy
	call z,MapView_MoveRight
	pop iy
	bit 5,(iy + Input.newKey + 8)
	push iy
	call z,MapView_MoveUp
	pop iy
	bit 6,(iy + Input.newKey + 8)
	call z,MapView_MoveDown
	pop ix
	ret
