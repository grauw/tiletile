;
; Frame for gameplay
;
GameFrame_FRAME_LINE: equ 228

GameFrame: MACRO
	super: DisplayFrame Apply

	registers:
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

	; c = VDP port 1
	; Modifies: af, bc, hl
	Apply:
		ld hl,registers
		REPT 9 * 2
		outi
		ENDM
		inc c
		ld hl,(palette)
		REPT 32
		outi
		ENDM
		ret
	_size:
	ENDM

GameFrame_SetDisplayOffset_M: MACRO ?this, ?displayOffset
	ld a,(?displayOffset + DisplayOffset.horizontalOffsetCharacters)
	ld (?this + GameFrame.horizontalOffsetCharacters),a
	ld a,(?displayOffset + DisplayOffset.horizontalOffsetDots)
	ld (?this + GameFrame.horizontalOffsetDots),a
	ld a,(?displayOffset + DisplayOffset.verticalOffset)
	ld (?this + GameFrame.verticalOffset),a
	add a,GameFrame_FRAME_LINE
	ld (?this + GameFrame.interruptLine),a
	ENDM

GameFrame_SetPatternNameTable_M: MACRO ?this, ?patternNameTable
	ld a,(?patternNameTable + PatternNameTable.baseRegister2)
	ld (?this + GameFrame.patternName),a
	ENDM

GameFrame_SetSpriteAttributeTable_M: MACRO ?this, ?spriteAttributeTable
	ld a,(?spriteAttributeTable + SpriteAttributeTable.baseRegister5)
	ld (?this + GameFrame.spriteAttributeLSB),a
	ld a,(?spriteAttributeTable + SpriteAttributeTable.baseRegister11)
	ld (?this + GameFrame.spriteAttributeMSB),a
	ENDM

GameFrame_SetSpriteColorTable_M: MACRO ?this, ?spriteColorTable
	ld a,(?spriteColorTable + SpriteColorTable.baseRegister5)
	ld (?this + SpriteColorTable.spriteAttributeLSB),a
	ld a,(?spriteColorTable + SpriteColorTable.baseRegister11)
	ld (?this + SpriteColorTable.spriteAttributeMSB),a
	ENDM

GameFrame_SetSpritePatternTable_M: MACRO ?this, ?spritePatternTable
	ld a,(?spritePatternTable + SpritePatternTable.baseRegister6)
	ld (?this + GameFrame.spritePattern),a
	ENDM

GameFrame_SetPalette_M: MACRO ?this, ?palettelow, ?palettehigh
	ld (?this + GameFrame.palette),?palettelow
	ld (?this + GameFrame.palette + 1),?palettehigh
	ENDM
