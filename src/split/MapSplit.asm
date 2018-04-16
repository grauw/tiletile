;
; Split for gameplay
;
MapSplit_FRAME_LINE: equ 228

MapSplit: MACRO
	super: Split
	horizontalOffsetCharacters:
		VDPRegister 26, 0
	horizontalOffsetDots:
		VDPRegister 27, 0
	verticalOffset:
		VDPRegister 23, 0
	patternName:
		VDPRegister 2
	spriteAttributeLSB:
		VDPRegister 5
	spriteAttributeMSB:
		VDPRegister 11
	spritePattern:
		VDPRegister 6
	mode9:
		VDPRegister 9
	palette:
		dw Palette_black
	_size:
	ENDM

; ix = this
MapSplit_Construct:
	ld a,(VDP_MIRROR_0 + 2)
	ld (ix + MapSplit.patternName + VDPRegister.value),a
	ld a,(VDP_MIRROR_0 + 5)
	ld (ix + MapSplit.spriteAttributeLSB + VDPRegister.value),a
	ld a,(VDP_MIRROR_8 + 11)
	ld (ix + MapSplit.spriteAttributeMSB + VDPRegister.value),a
	ld a,(VDP_MIRROR_0 + 6)
	ld (ix + MapSplit.spritePattern + VDPRegister.value),a
	ld a,(VDP_MIRROR_8 + 9)
	or 10000000B
	ld (ix + MapSplit.mode9 + VDPRegister.value),a
	ret

MapSplit_SetDisplayOffset_M: MACRO ?this, ?displayOffset
	ld a,(?displayOffset + DisplayOffset.horizontalOffsetCharacters)
	ld (?this + MapSplit.horizontalOffsetCharacters + VDPRegister.value),a
	ld a,(?displayOffset + DisplayOffset.horizontalOffsetDots)
	ld (?this + MapSplit.horizontalOffsetDots + VDPRegister.value),a
	ld a,(?displayOffset + DisplayOffset.verticalOffset)
	ld (?this + MapSplit.verticalOffset + VDPRegister.value),a
	ENDM

MapSplit_SetPatternNameTable_M: MACRO ?this, ?patternNameTable
	ld a,(?patternNameTable + PatternNameTable.baseRegister2)
	ld (?this + MapSplit.patternName + VDPRegister.value),a
	ENDM

MapSplit_SetSpriteAttributeTable_M: MACRO ?this, ?spriteAttributeTable
	ld a,(?spriteAttributeTable + SpriteAttributeTable.baseRegister5)
	ld (?this + MapSplit.spriteAttributeLSB + VDPRegister.value),a
	ld a,(?spriteAttributeTable + SpriteAttributeTable.baseRegister11)
	ld (?this + MapSplit.spriteAttributeMSB + VDPRegister.value),a
	ENDM

MapSplit_SetSpriteColorTable_M: MACRO ?this, ?spriteColorTable
	ld a,(?spriteColorTable + SpriteColorTable.baseRegister5)
	ld (?this + SpriteColorTable.spriteAttributeLSB + VDPRegister.value),a
	ld a,(?spriteColorTable + SpriteColorTable.baseRegister11)
	ld (?this + SpriteColorTable.spriteAttributeMSB + VDPRegister.value),a
	ENDM

MapSplit_SetSpritePatternTable_M: MACRO ?this, ?spritePatternTable
	ld a,(?spritePatternTable + SpritePatternTable.baseRegister6)
	ld (?this + MapSplit.spritePattern + VDPRegister.value),a
	ENDM

MapSplit_SetPalette_M: MACRO ?this, ?palettelow, ?palettehigh
	ld (?this + MapSplit.palette),?palettelow
	ld (?this + MapSplit.palette + 1),?palettehigh
	ENDM
