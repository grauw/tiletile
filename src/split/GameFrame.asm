;
; A set of splits for the frame of the gameplay
;
GameFrame: MACRO
	mapSplit:
		MapSplit
	dialogSplit:
		DialogSplit
	dialogEndSplit:
		DialogEndSplit
	overscanSplit:
		OverscanSplit
	ENDM

; ix = this
GameFrame_Construct:
	ld de,GameFrame.mapSplit
	add ix,de
	call MapSplit_Construct
	ld de,GameFrame.dialogSplit - GameFrame.mapSplit
	add ix,de
	call DialogSplit_Construct
	ld de,GameFrame.dialogEndSplit - GameFrame.dialogSplit
	add ix,de
	call DialogEndSplit_Construct
	ld de,GameFrame.overscanSplit - GameFrame.dialogEndSplit
	add ix,de
	call OverscanSplit_Construct
	ld de,-GameFrame.overscanSplit
	add ix,de
	ret

GameFrame_SetDisplayOffset_M: MACRO ?this, ?displayOffset
	MapSplit_SetDisplayOffset_M ?this + GameFrame.mapSplit, ?displayOffset
	DialogEndSplit_SetDisplayOffset_M ?this + GameFrame.dialogEndSplit, ?displayOffset
	ENDM

GameFrame_SetPatternNameTable_M: MACRO ?this, ?patternNameTable
	MapSplit_SetPatternNameTable_M ?this + GameFrame.mapSplit, ?patternNameTable
	ENDM

GameFrame_SetSpriteAttributeTable_M: MACRO ?this, ?spriteAttributeTable
	MapSplit_SetSpriteAttributeTable_M ?this + GameFrame.mapSplit, ?spriteAttributeTable
	ENDM

GameFrame_SetSpriteColorTable_M: MACRO ?this, ?spriteColorTable
	MapSplit_SetSpriteColorTable_M ?this + GameFrame.mapSplit, ?spriteColorTable
	ENDM

GameFrame_SetSpritePatternTable_M: MACRO ?this, ?spritePatternTable
	MapSplit_SetSpritePatternTable_M ?this + GameFrame.mapSplit, ?spritePatternTable
	ENDM

GameFrame_SetPalette_M: MACRO ?this, ?palettelow, ?palettehigh
	MapSplit_SetPalette_M ?this + GameFrame.mapSplit, ?palettelow, ?palettehigh
	ENDM
