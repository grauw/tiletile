;
; VDP registers to set on VBlank
;
DisplaySettings: MACRO
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
		dw DisplaySettings_defaultPalette
	_size:
	ENDM

; hl = this
DisplaySettings_ApplyHL:
	ld c,VDP_PORT_1
	REPT 4
	outi
	ENDM
	ld a,(hl)
	ld (VDP_MIRROR_8 + 23),a
	REPT 12
	outi
	ENDM
	inc c
	ld a,(hl)
	inc hl
	ld h,(hl)
	ld l,a
	REPT 32
	outi
	ENDM
	ret

;
DisplaySettings_defaultPalette:
	Palette #000, #000, #611, #733, #077, #327, #151, #627,
	        #171, #373, #661, #664, #411, #265, #555, #777
