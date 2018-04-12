;
; Frame for gameplay
;
GameFrame_FRAME_LINE: equ 228

GameFrame: MACRO
	super: DisplayFrame Apply

	registers:
	horizontalOffsetCharacters:
		VDPRegister 26
	horizontalOffsetDots:
		VDPRegister 27
	verticalOffset:
		VDPRegister 23
	patternName:
		VDPRegister 2
	spriteAttributeLSB:
		VDPRegister 5
	spriteAttributeMSB:
		VDPRegister 11
	spritePattern:
		VDPRegister 6
	interruptLine:
		VDPRegister 19
		VDPRegister 15, 1
		VDPRegister 15, 2
		VDPRegister 16, 0
	palette:
		dw Palette_system

	; c = VDP port 1
	; Modifies: af, bc, hl
	Apply:
		ld hl,registers
		VDPRegister_OUTI_DI_M  ; horizontal offset (characters)
		VDPRegister_OUTI_DI_M  ; horizontal offset (dots)
		VDPRegister_OUTI_DI_M  ; vertical offset
		VDPRegister_OUTI_DI_M  ; pattern name base
		VDPRegister_OUTI_DI_M  ; sprite attribute base LSB
		VDPRegister_OUTI_DI_M  ; sprite attribute base MSB
		VDPRegister_OUTI_DI_M  ; sprite pattern base
		VDPRegister_OUTI_DI_M  ; interrupt line
		VDPRegister_OUTI_DI_M  ; status register 1
		in a,(c)               ; clear FH
		VDPRegister_OUTI_DI_M  ; status register 2
		VDPRegister_OUTI_DI_M  ; palette number
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
	ld (?this + GameFrame.horizontalOffsetCharacters + VDPRegister.value),a
	ld a,(?displayOffset + DisplayOffset.horizontalOffsetDots)
	ld (?this + GameFrame.horizontalOffsetDots + VDPRegister.value),a
	ld a,(?displayOffset + DisplayOffset.verticalOffset)
	ld (?this + GameFrame.verticalOffset + VDPRegister.value),a
	add a,GameFrame_FRAME_LINE
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
