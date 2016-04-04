;
; A tile set
;
TileSet: MACRO
	tilesBank:
		db 3
	paletteBank:
		db 7
	baseAddress:
		dw ROM_TILESET
	ENDM

; ix = this
TileSet_Construct:
	ret

; ix = this
TileSet_Load:
	call TileSet_LoadTiles
	call TileSet_LoadPalette
	ret

; ix = this
TileSet_LoadTiles:
	ld a,1
	ld hl,0
	call VDP_SetWriteAddress
	ld a,(ix + TileSet.tilesBank)
	call TileSet_LoadTileBank
	inc a
	call TileSet_LoadTileBank
	inc a
	call TileSet_LoadTileBank
	inc a
	call TileSet_LoadTileBank
	ret

; a = bank
; hl = bank register
; ix = this
TileSet_LoadTileBank:
	push af
	ld hl,(ROM_bank6000)
	push hl
	ld (hl),a
	ld bc,2000H
	ld l,(ix + TileSet.baseAddress)
	ld h,(ix + TileSet.baseAddress + 1)
	call VDP_Write
	pop hl
	ld (hl),l
	pop af
	ret

; ix = this
TileSet_LoadPalette:
	ld hl,(ROM_bank6000)
	push hl
	ld a,(ix + TileSet.paletteBank)
	ld (hl),a
	ld l,(ix + TileSet.baseAddress)
	ld h,(ix + TileSet.baseAddress + 1)
	call VDP_SetPalette
	pop hl
	ld (hl),l
	ret
