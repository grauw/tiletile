;
; Top-level TileTile program class
;
; Program entry point
;
TileTile_Main:
	call VDP_GetVersion
	cp 2
	ret c

;	call System_EnableTurbo

	call Memory_EnableROMInPage2
	call ROM_Init
	call RAM_Init

	call Memory_UnitTest

	call VDP_InitScreen5
	call VDP_DisableSprites
	call VDP_Enable60Hz
	ld a,0FH
	call VDP_SetColor

	call VDP_EnableBlank
	call TileTile_LoadTileSet
	call VDP_DisableBlank

	call TileTile_EnterMainLoop

	call KILBUF
	ret

;
TileTile_EnterMainLoop:
	call TileTile_MainLoop
	ret

;
TileTile_MainLoop: PROC
	jp TileTile_MainLoop
	ret
	ENDP

;
TileTile_LoadTileSet:
	ld a,0
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
