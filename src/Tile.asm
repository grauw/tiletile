;
; A tile
;
Tile_PAGE: equ 2

Tile: MACRO ?pixelData, ?collision
	image:
		ROMAddress ?pixelData, 0A000H
	collision:
		db ?collision
	_size:
	ENDM

; ix = this
Tile_GetCollision_M: MACRO ?this, ?register
	ld ?register,(?this + Tile.collision)
	ENDM

; ix = this
; f <- nz: solid
Tile_IsSolid_M: MACRO ?this
	bit 7,(?this + Tile.collision)
	ENDM
