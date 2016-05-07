;
; A scene.
;
Scene: MACRO
	map:
		dw FieldMap_instance
	input:
		dw 0
	sprites:
		Sprites
	tileSet:
		TileSet
	mapView:
		MapView
	softsprite:
		Softsprite
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
	call Scene_GetMap
	call Map_Construct
	ld e,ixl
	ld d,ixh
	pop ix
	push ix
	push de
	call Scene_GetMapView
	pop de
	call MapView_Construct
	pop ix
	ret

; ix = this
Scene_GetInput_IY:
	ld e,(ix + Scene.input)
	ld d,(ix + Scene.input + 1)
	ld iyl,e
	ld iyh,d
	ret

; ix = this
Scene_GetSprites:
	ld de,Scene.sprites
	add ix,de
	ret

; ix = this
Scene_GetTileSet:
	ld de,Scene.tileSet
	add ix,de
	ret

; ix = this
Scene_GetMap:
	ld e,(ix + Scene.map)
	ld d,(ix + Scene.map + 1)
	ld ixl,e
	ld ixh,d
	ret

; ix = this
Scene_GetMapView:
	ld de,Scene.mapView
	add ix,de
	ret

; ix = this
Scene_GetSoftsprite:
	ld de,Scene.softsprite
	add ix,de
	ret

; ix = this
Scene_Start:
	call VDP_EnableBlank

	call Scene_LoadTileSet

	push ix
	call Scene_GetSprites
	call Sprites_InitializeTableAddresses
	ld de,Sprite_block
	call Sprites_AddSprite
	call Sprites_Draw
	pop ix

	call VDP_DisableBlank

	push ix
	call Scene_GetMapView
	call MapView_Update
	call MapView_Draw
	pop ix
	ret

; ix = this
Scene_Update:
	push ix
	call Scene_GetMapView
	call MapView_Update
	pop ix
	push ix
	call Scene_GetSoftsprite
	call Softsprite_Clear
	pop ix
	call Scene_UpdatePosition
	push ix
	call Scene_GetSoftsprite
	call Softsprite_MoveRight
	call Softsprite_Draw
	pop ix

	ld iy,Sprite_block
	ld (iy + Sprite.x),100
	inc (iy + Sprite.y)
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

; ix = this
Scene_LoadTileSet:
	push ix
	call Scene_GetTileSet
	call TileSet_Construct
	call TileSet_Load
	pop ix
	ret
