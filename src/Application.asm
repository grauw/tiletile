;
; Top-level program class
;
Application: MACRO
	timiHook:
		TIMIHook
	input:
		Input
	sprites:
		Sprites
	tileSet:
		TileSet
	map:
		Map
	mapView:
		MapView
	softsprite:
		Softsprite
	ENDM

Application_Main:
	call VDP_GetVersion
	cp 2
	ret c

;	call System_EnableTurbo

	call Memory_EnableROMInPage2
	call ROM_Init
	call RAM_Init

	call Memory_UnitTest

	ld ix,Application_instance
	call Application_Construct
	call Application_EnterMainLoop

	call KILBUF
	ret

; ix = this
Application_Construct:
	push ix
	call Application_GetSprites
	call Sprites_Construct
	pop ix
	ld a,(FieldMap_dimensions)
	ld c,a
	ld b,0
	ld a,(FieldMap_dimensions + 1)
	ld e,a
	ld d,0
	ld hl,FieldMap_data
	push ix
	push de
	call Application_GetMap
	pop de
	call Map_Construct
	ld e,ixl
	ld d,ixh
	pop ix
	push ix
	push de
	call Application_GetMapView
	pop de
	call MapView_Construct
	pop ix
	ld e,ixl
	ld d,ixh
	ld hl,Application_TIMIInterruptEntry
	push ix
	push de
	call Application_GetTIMIHook
	pop de
	call TIMIHook_Construct
	pop ix
	ret

; ix = this
Application_GetInput_IY:
	ld e,ixl
	ld d,ixh
	ld iy,Application.input
	add iy,de
	ret

; ix = this
Application_GetTIMIHook:
	ld de,Application.timiHook
	add ix,de
	ret

; ix = this
Application_GetSprites:
	ld de,Application.sprites
	add ix,de
	ret

; ix = this
Application_GetTileSet:
	ld de,Application.tileSet
	add ix,de
	ret

; ix = this
Application_GetMap:
	ld de,Application.map
	add ix,de
	ret

; ix = this
Application_GetMapView:
	ld de,Application.mapView
	add ix,de
	ret

; ix = this
Application_GetSoftsprite:
	ld de,Application.softsprite
	add ix,de
	ret

; ix = this
Application_EnterMainLoop:
	ld a,0
	ld (CLIKSW),a  ; disable key click
	call VDP_InitScreen5
	call VDP_Enable212Lines
	call VDP_EnableSprites
	call VDP_Enable60Hz
	ld a,0F1H
	call VDP_SetColor

	call VDP_EnableBlank

	call Application_LoadTileSet

	push ix
	call Application_GetSprites
	call Sprites_Initialize
	pop ix

	call VDP_DisableBlank

	push ix
	call Application_GetTIMIHook
	call Hook_Install
	pop ix

	call Application_MainLoop

	push ix
	call Application_GetTIMIHook
	call Hook_Uninstall
	pop ix
	ret

; ix = this
Application_MainLoop:
	jp Application_MainLoop
	ret

; ix = this
Application_TIMIInterruptEntry:
	ld a,0FFH
	ld (SCNCNT),a
	call Application_GetInput_IY
	call Input_Update_IY
	call Application_UpdatePosition
	push ix
	call Application_GetSoftsprite
	call Softsprite_Clear
	call Softsprite_MoveRight
	pop ix
	call Application_DrawMapView
	call Application_DrawSoftsprites
	ret

; ix = this
Application_UpdatePosition:
	call Application_GetInput_IY
	push ix
	call Application_GetMapView
	bit 4,(iy + Input.newKey + 8)
	call z,MapView_MoveLeft
	bit 7,(iy + Input.newKey + 8)
	call z,MapView_MoveRight
	bit 5,(iy + Input.newKey + 8)
	call z,MapView_MoveUp
	bit 6,(iy + Input.newKey + 8)
	call z,MapView_MoveDown
	pop ix
	ret

; ix = this
Application_DrawMapView:
	push ix
	call Application_GetMapView
	call MapView_Update
	pop ix
	ret

; ix = this
Application_DrawSoftsprites:
	push ix
	call Application_GetSoftsprite
	call Softsprite_Draw
	pop ix
	ret

; ix = this
Application_LoadTileSet:
	push ix
	call Application_GetTileSet
	call TileSet_Construct
	call TileSet_Load
	pop ix
	ret

;
	SECTION RAM

Application_instance: Application

	ENDS
