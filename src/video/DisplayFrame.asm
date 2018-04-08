;
; VDP registers to set on VBlank
;
DisplayFrame_FRAME_LINE: equ 228

DisplayFrame: MACRO
	Entry:
		jp Apply
	horizontalOffsetCharacters:
		db 0
		db 26 | VDP_REGISTER
	horizontalOffsetDots:
		db 0
		db 27 | VDP_REGISTER
	verticalOffset:
		db 0
		db 23 | VDP_REGISTER
	interruptLine:
		db 0
		db 19 | VDP_REGISTER
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

	Apply:
		push bc
		push hl
		ld hl,horizontalOffsetCharacters
		ld c,VDP_PORT_1
		REPT 9 * 2
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
		pop hl
		pop bc
		ret
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
	add a,DisplayFrame_FRAME_LINE
	ld (iy + DisplayFrame.interruptLine),a
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

DisplayFrame_SetDisplayOffset_M: MACRO ?this, ?displayOffset
	ld a,(?displayOffset + DisplayOffset.horizontalOffsetCharacters)
	ld (?this + DisplayFrame.horizontalOffsetCharacters),a
	ld a,(?displayOffset + DisplayOffset.horizontalOffsetDots)
	ld (?this + DisplayFrame.horizontalOffsetDots),a
	ld a,(?displayOffset + DisplayOffset.verticalOffset)
	ld (?this + DisplayFrame.verticalOffset),a
	add a,DisplayFrame_FRAME_LINE
	ld (?this + DisplayFrame.interruptLine),a
	ENDM

DisplayFrame_SetPatternNameTable_M: MACRO ?this, ?patternNameTable
	ld a,(?patternNameTable + PatternNameTable.baseRegister2)
	ld (?this + DisplayFrame.patternName),a
	ENDM

DisplayFrame_SetSpriteAttributeTable_M: MACRO ?this, ?spriteAttributeTable
	ld a,(?spriteAttributeTable + SpriteAttributeTable.baseRegister5)
	ld (?this + DisplayFrame.spriteAttributeLSB),a
	ld a,(?spriteAttributeTable + SpriteAttributeTable.baseRegister11)
	ld (?this + DisplayFrame.spriteAttributeMSB),a
	ENDM

DisplayFrame_SetSpriteColorTable_M: MACRO ?this, ?spriteColorTable
	ld a,(?spriteColorTable + SpriteColorTable.baseRegister5)
	ld (?this + SpriteColorTable.spriteAttributeLSB),a
	ld a,(?spriteColorTable + SpriteColorTable.baseRegister11)
	ld (?this + SpriteColorTable.spriteAttributeMSB),a
	ENDM

DisplayFrame_SetSpritePatternTable_M: MACRO ?this, ?spritePatternTable
	ld a,(?spritePatternTable + SpritePatternTable.baseRegister6)
	ld (?this + DisplayFrame.spritePattern),a
	ENDM

DisplayFrame_SetPalette_M: MACRO ?this, ?palettelow, ?palettehigh
	ld (?this + DisplayFrame.palette),?palettelow
	ld (?this + DisplayFrame.palette + 1),?palettehigh
	ENDM
