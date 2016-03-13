;
; Top-level program class
;
TileTile: MACRO
	map:
		Map
	ENDM

TileTile_Main:
	call VDP_GetVersion
	cp 2
	ret c

;	call System_EnableTurbo

	call Memory_EnableROMInPage2
	call ROM_Init
	call RAM_Init

	call Memory_UnitTest

	ld ix,TileTile_instance
	call TileTile_Construct
	call TileTile_EnterMainLoop

	call KILBUF
	ret

; ix = this
TileTile_Construct:
	ld a,(TileMap_dimensions)
	ld c,a
	ld b,0
	ld a,(TileMap_dimensions + 1)
	ld e,a
	ld d,0
	ld hl,TileMap_data
	push ix
	push de
	call TileTile_GetMap
	pop de
	call Map_Construct
	pop ix
	ret

; ix = this
TileTile_GetMap:
	ld de,TileTile.map
	add ix,de
	ret

; ix = this
TileTile_EnterMainLoop:
	call VDP_InitScreen5
	call VDP_DisableSprites
	call VDP_Enable60Hz
	ld a,0FH
	call VDP_SetColor

	call VDP_EnableBlank

	call TileTile_LoadTileSet
	call TileTile_DrawTileMap

	call VDP_DisableBlank

	call TileTile_MainLoop
	ret

; ix = this
TileTile_MainLoop:
	jp TileTile_MainLoop
	ret

; ix = this
TileTile_DrawTileMap:
	push ix
	call TileTile_GetMap
	call Map_Draw
	pop ix
	ret

; ix = this
TileTile_LoadTileSet:
	ld a,1
	ld hl,0
	call VDP_SetWriteAddress
	ld hl,(ROM_bank6000)
	push hl
	ld (hl),ROM_TileSetBank1
	ld bc,2000H
	ld hl,ROM_TILESET
	call VDP_Write
	ld hl,(ROM_bank6000)
	ld (hl),ROM_TileSetBank2
	ld bc,2000H
	ld hl,ROM_TILESET
	call VDP_Write
	ld hl,(ROM_bank6000)
	ld (hl),ROM_TileSetBank3
	ld bc,2000H
	ld hl,ROM_TILESET
	call VDP_Write
	ld hl,(ROM_bank6000)
	ld (hl),ROM_TileSetBank4
	ld bc,2000H
	ld hl,ROM_TILESET
	call VDP_Write
	ld hl,(ROM_bank6000)
	ld (hl),ROM_TileSetPaletteBank
	ld hl,ROM_TILESET
	call VDP_SetPalette
	pop hl
	ld (hl),l
	ret

;
	SECTION RAM

TileTile_instance: TileTile

	ENDS
