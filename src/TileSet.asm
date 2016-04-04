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
	tileLoadCommand: VDPCommand 0, 0, 0, 200H, 16, 16, 0, 0, VDPCommand_HMMC
	ENDM

; ix = this
TileSet_Construct:
	ret

; ix = this
TileSet_GetTileLoadCommand_IY:
	ld e,ixl
	ld d,ixh
	ld iy,TileSet.tileLoadCommand
	add iy,de
	ret

; ix = this
TileSet_Load:
	call TileSet_LoadTiles
	call TileSet_LoadPalette
	ret

; ix = this
TileSet_LoadTiles: PROC
	call TileSet_GetTileLoadCommand_IY
	ld b,0
Loop:
	push bc
	call TileSet_LoadTile
	pop bc
	djnz Loop
	ret
	ENDP

; b = tile nr
; ix = this
; iy = tile load command
TileSet_LoadTile:
	ld a,b
	and 0FH
	add a,a
	add a,a
	add a,a
	add a,a
	ld (iy + VDPCommand.dx),a
	ld a,b
	and 0F0H
	ld (iy + VDPCommand.dy),a
	ld a,b
	and 11000000B
	rlca
	rlca
	add a,(ix + TileSet.tilesBank)
	ld hl,(ROM_bank6000)
	push hl
	ld (hl),a
	ld a,b
	and 00111111B
	rra
	ld l,0
	ld h,a
	rr l
	ld e,(ix + TileSet.baseAddress)
	ld d,(ix + TileSet.baseAddress + 1)
	add hl,de
	ld a,(hl)
	inc hl
	ld (iy + VDPCommand.color),a
	push hl
	call VDPCommand_Execute_IY
	pop hl
	ld bc,127
	call VDPCommand_Transfer_IY
	pop hl
	ld (hl),l
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
