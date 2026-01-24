;
; A tile
;
Tile_PAGE: equ 2

Tile: MACRO ?pixelData
	image:
		ROMAddress ?pixelData, 0A000H
	reserved:
		db 0
	_size:
	ENDM
