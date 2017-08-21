;
; A tile
;
Tile_PAGE: equ 2

Tile: MACRO ?index, ?tilesbank
	image:
		dw 0A000H + (?index << 7 & 1FFFH)
	imageBank:
		db ?tilesbank + (?index >> 6)
	x:
		db (?index & 0FH) << 4
	y:
		db ?index & 0F0H
	_size:
	ENDM

; ix = this
Tile_Load:
	ld a,(ix + Tile.imageBank)
	ld hl,(ROM_bankA000)
	push hl
	ld (hl),a
	ld l,(ix + Tile.image)
	ld h,(ix + Tile.image + 1)
	ld de,16
	ld a,4
	call VDPCommand_PrepareCommand
	ld a,(ix + Tile.x)
	out (c),a
	out (c),d
	ld a,(ix + Tile.y)
	out (c),a
	ld a,Tile_PAGE
	out (c),a
	out (c),e
	out (c),d
	out (c),e
	out (c),d
	ld a,(hl)
	inc hl
	out (c),a
	out (c),d
	ld a,VDPCommand_HMMC
	out (c),a
	call VDPCommand_PrepareTransfer
	ld b,16 * 16 / 2 - 1
	otir
	pop hl
	ld (hl),l
	ret
