;
; Frame for gameplay
;
MapFrame_FRAME_LINE: equ 228

MapFrame: MACRO
	super: Frame
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
	mode8:
		VDPRegister 8
	mode9:
		VDPRegister 9
	palette:
		dw Palette_black
	_size:
	ENDM

; ix = this
MapFrame_Construct:
	ld a,(VDP_MIRROR_0 + 2)
	ld (ix + MapFrame.patternName + VDPRegister.value),a
	ld a,(VDP_MIRROR_0 + 5)
	ld (ix + MapFrame.spriteAttributeLSB + VDPRegister.value),a
	ld a,(VDP_MIRROR_8 + 11)
	ld (ix + MapFrame.spriteAttributeMSB + VDPRegister.value),a
	ld a,(VDP_MIRROR_0 + 6)
	ld (ix + MapFrame.spritePattern + VDPRegister.value),a
	ld a,(VDP_MIRROR_8 + 8)
	and 11111101B
	ld (ix + MapFrame.mode8 + VDPRegister.value),a
	ld a,(VDP_MIRROR_8 + 9)
	or 10000000B
	ld (ix + MapFrame.mode9 + VDPRegister.value),a
	ret

MapFrame_SetDisplayOffset_M: MACRO ?this, ?displayOffset
	ld a,(?displayOffset + DisplayOffset.horizontalOffsetCharacters)
	ld (?this + MapFrame.horizontalOffsetCharacters + VDPRegister.value),a
	ld a,(?displayOffset + DisplayOffset.horizontalOffsetDots)
	ld (?this + MapFrame.horizontalOffsetDots + VDPRegister.value),a
	ld a,(?displayOffset + DisplayOffset.verticalOffset)
	ld (?this + MapFrame.verticalOffset + VDPRegister.value),a
	ENDM

MapFrame_SetPatternNameTable_M: MACRO ?this, ?patternNameTable
	ld a,(?patternNameTable + PatternNameTable.baseRegister2)
	ld (?this + MapFrame.patternName + VDPRegister.value),a
	ENDM

MapFrame_SetSpriteAttributeTable_M: MACRO ?this, ?spriteAttributeTable
	ld a,(?spriteAttributeTable + SpriteAttributeTable.baseRegister5)
	ld (?this + MapFrame.spriteAttributeLSB + VDPRegister.value),a
	ld a,(?spriteAttributeTable + SpriteAttributeTable.baseRegister11)
	ld (?this + MapFrame.spriteAttributeMSB + VDPRegister.value),a
	ENDM

MapFrame_SetSpriteColorTable_M: MACRO ?this, ?spriteColorTable
	ld a,(?spriteColorTable + SpriteColorTable.baseRegister5)
	ld (?this + SpriteColorTable.spriteAttributeLSB + VDPRegister.value),a
	ld a,(?spriteColorTable + SpriteColorTable.baseRegister11)
	ld (?this + SpriteColorTable.spriteAttributeMSB + VDPRegister.value),a
	ENDM

MapFrame_SetSpritePatternTable_M: MACRO ?this, ?spritePatternTable
	ld a,(?spritePatternTable + SpritePatternTable.baseRegister6)
	ld (?this + MapFrame.spritePattern + VDPRegister.value),a
	ENDM

MapFrame_SetPalette_M: MACRO ?this, ?palettelow, ?palettehigh
	ld (?this + MapFrame.palette),?palettelow
	ld (?this + MapFrame.palette + 1),?palettehigh
	ENDM
