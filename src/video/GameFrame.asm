;
; Frame for gameplay
;
GameFrame_FRAME_LINE: equ 228

GameFrame: MACRO
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
	interruptLine:
		VDPRegister 19, GameFrame_FRAME_LINE
		VDPRegister 15, 1
		VDPRegister 15, 2
		VDPRegister 16, 0
	palette:
		dw Palette_black
	_size:
	ENDM

; ix = this
GameFrame_Construct:
	ld a,(VDP_MIRROR_0 + 2)
	ld (ix + GameFrame.patternName + VDPRegister.value),a
	ld a,(VDP_MIRROR_0 + 5)
	ld (ix + GameFrame.spriteAttributeLSB + VDPRegister.value),a
	ld a,(VDP_MIRROR_8 + 11)
	ld (ix + GameFrame.spriteAttributeMSB + VDPRegister.value),a
	ld a,(VDP_MIRROR_0 + 6)
	ld (ix + GameFrame.spritePattern + VDPRegister.value),a
	ld a,(VDP_MIRROR_8 + 8)
	and 11111101B
	ld (ix + GameFrame.mode8 + VDPRegister.value),a
	ret

GameFrame_SetDisplayOffset_M: MACRO ?this, ?displayOffset
	ld a,(?displayOffset + DisplayOffset.horizontalOffsetCharacters)
	ld (?this + GameFrame.horizontalOffsetCharacters + VDPRegister.value),a
	ld a,(?displayOffset + DisplayOffset.horizontalOffsetDots)
	ld (?this + GameFrame.horizontalOffsetDots + VDPRegister.value),a
	ld a,(?displayOffset + DisplayOffset.verticalOffset)
	ld (?this + GameFrame.verticalOffset + VDPRegister.value),a
	add a,DialogFrame_FRAME_LINE - 2
	ld (?this + GameFrame.interruptLine + VDPRegister.value),a
	ENDM

GameFrame_SetPatternNameTable_M: MACRO ?this, ?patternNameTable
	ld a,(?patternNameTable + PatternNameTable.baseRegister2)
	ld (?this + GameFrame.patternName + VDPRegister.value),a
	ENDM

GameFrame_SetSpriteAttributeTable_M: MACRO ?this, ?spriteAttributeTable
	ld a,(?spriteAttributeTable + SpriteAttributeTable.baseRegister5)
	ld (?this + GameFrame.spriteAttributeLSB + VDPRegister.value),a
	ld a,(?spriteAttributeTable + SpriteAttributeTable.baseRegister11)
	ld (?this + GameFrame.spriteAttributeMSB + VDPRegister.value),a
	ENDM

GameFrame_SetSpriteColorTable_M: MACRO ?this, ?spriteColorTable
	ld a,(?spriteColorTable + SpriteColorTable.baseRegister5)
	ld (?this + SpriteColorTable.spriteAttributeLSB + VDPRegister.value),a
	ld a,(?spriteColorTable + SpriteColorTable.baseRegister11)
	ld (?this + SpriteColorTable.spriteAttributeMSB + VDPRegister.value),a
	ENDM

GameFrame_SetSpritePatternTable_M: MACRO ?this, ?spritePatternTable
	ld a,(?spritePatternTable + SpritePatternTable.baseRegister6)
	ld (?this + GameFrame.spritePattern + VDPRegister.value),a
	ENDM

GameFrame_SetPalette_M: MACRO ?this, ?palettelow, ?palettehigh
	ld (?this + GameFrame.palette),?palettelow
	ld (?this + GameFrame.palette + 1),?palettehigh
	ENDM
