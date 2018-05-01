;
; A set of splits for the frame of the gameplay
;
GameFrame_LINE: equ 224

GameFrame: MACRO
	super: Split
	dialogActive:
		db 0
	dialogStartLine:
		db 0
	dialogEndLine:
		db 0
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

; b = x
; c = y
; iy = this
GameFrame_SetMapPositionIY:
	ld a,b
	neg
	and 07H
	dec b
	srl b
	srl b
	srl b
	MapSplit_SetDisplayOffset_M (iy + GameFrame.mapSplit), a, b, c
	DialogEndSplit_SetDisplayOffset_M (iy + GameFrame.dialogEndSplit), a, b, c
	ret

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

GameFrame_SetDialogOffset_M: MACRO ?this, ?height
	ld a,?height
	add a,255
	sbc a,a
	ld (?this + GameFrame.dialogActive),a
	ld a,DialogSplit_LINE + Dialog_MAX_HEIGHT
	sub ?height
	ld (?this + GameFrame.dialogStartLine),a
	ld a,DialogEndSplit_LINE - Dialog_MAX_HEIGHT
	add a,?height
	ld (?this + GameFrame.dialogEndLine),a
	ENDM
