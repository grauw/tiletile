;
; VDP registers to set on VBlank
;
DisplayFrame: MACRO
	horizontalOffsetCharacters:
		db 0
		db 26 | VDP_REGISTER
	horizontalOffsetDots:
		db 0
		db 27 | VDP_REGISTER
	verticalOffset:
		db 0
		db 23 | VDP_REGISTER
	patternName:
		db 0
		db 2 | VDP_REGISTER
	spriteAttributeLSB:
		db 0
		db 5 | VDP_REGISTER
	spriteAttributeMSB:
		db 0
		db 11 | VDP_REGISTER
	spritePattern:
		db 0
		db 6 | VDP_REGISTER
	paletteNumber:
		db 0
		db 16 | VDP_REGISTER
	palette:
		dw Palette_system
	_size:
	ENDM

; iy = this
DisplayFrame_InitializeFromSystemVariablesIY:
	ld a,(VDP_MIRROR_25 + 26)
	ld (iy + DisplayFrame.horizontalOffsetCharacters),a
	ld a,(VDP_MIRROR_25 + 27)
	ld (iy + DisplayFrame.horizontalOffsetDots),a
	ld a,(VDP_MIRROR_8 + 23)
	ld (iy + DisplayFrame.verticalOffset),a
	ld a,(VDP_MIRROR_0 + 2)
	ld (iy + DisplayFrame.patternName),a
	ld a,(VDP_MIRROR_0 + 5)
	ld (iy + DisplayFrame.spriteAttributeLSB),a
	ld a,(VDP_MIRROR_8 + 11)
	ld (iy + DisplayFrame.spriteAttributeMSB),a
	ld a,(VDP_MIRROR_0 + 6)
	ld (iy + DisplayFrame.spritePattern),a
	ld (iy + DisplayFrame.palette),Palette_system
	ld (iy + DisplayFrame.palette + 1),Palette_system >> 8
	ret

; hl = this
DisplayFrame_ApplyHL:
	ld c,VDP_PORT_1
	REPT 4
	outi
	ENDM
	ld a,(hl)
	REPT 12
	outi
	ENDM
	inc c
	ld b,(hl)
	inc hl
	ld h,(hl)
	ld l,b
	REPT 32
	outi
	ENDM
	ld (VDP_MIRROR_8 + 23),a
	ret
