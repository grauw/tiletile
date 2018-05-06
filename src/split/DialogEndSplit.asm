;
; Split for dialog
;
DialogEndSplit_LINE: equ 208 - 6
DialogEndSplit_VERTICAL_OFFSET: equ -160

DialogEndSplit: MACRO
	super: Split
		VDPRegister 15, 2
	verticalOffset1:
		VDPRegister 23
		VDPRegister 16, 12
	mapColor12:
		PaletteColor 4, 2, 1
	mapColor13:
		PaletteColor 5, 3, 2
	mapColor14:
		PaletteColor 6, 5, 3
	horizontalOffsetCharacters:
		VDPRegister 26
	horizontalOffsetDots:
		VDPRegister 27
	mode1Blank:
		VDPRegister 1
	mode8:
		VDPRegister 8
	mode1Display:
		VDPRegister 1
		VDPRegister 2, 0 << 5 | 00011111B
	mapColor15:
		PaletteColor 7, 7, 6
	verticalOffset2:
		VDPRegister 23
	_size:
	ENDM

; ix = this
DialogEndSplit_Construct:
	ld a,(VDP_MIRROR_0 + 1)
	and 10111111B
	ld (ix + DialogEndSplit.mode1Blank + VDPRegister.value),a
	or 01000000B
	ld (ix + DialogEndSplit.mode1Display + VDPRegister.value),a
	ld a,(VDP_MIRROR_8 + 8)
	and 11111101B
	ld (ix + DialogEndSplit.mode8 + VDPRegister.value),a
	ret

DialogEndSplit_SetDisplayOffset_M: MACRO ?this, ?horizontalDots, ?horizontalCharacters, ?vertical
	ld (?this + DialogEndSplit.horizontalOffsetDots + VDPRegister.value),?horizontalDots
	ld (?this + DialogEndSplit.horizontalOffsetCharacters + VDPRegister.value),?horizontalCharacters
	ld (?this + DialogEndSplit.verticalOffset2 + VDPRegister.value),?vertical
	ENDM

DialogEndSplit_SetDialogOffset_M: MACRO ?this, ?height
	ld a,DialogEndSplit_VERTICAL_OFFSET + Dialog_MAX_HEIGHT
	sub ?height
	ld (?this + DialogEndSplit.verticalOffset1),a
	ENDM

DialogEndSplit_SetPalette_M: MACRO ?this, ?palettelow, ?palettehigh
	push iy
	ld iyl,?palettelow
	ld iyh,?palettehigh
	ld a,(iy + Palette.color12)
	ld (?this + DialogEndSplit.mapColor12),a
	ld a,(iy + Palette.color12 + 1)
	ld (?this + DialogEndSplit.mapColor12 + 1),a
	ld a,(iy + Palette.color13)
	ld (?this + DialogEndSplit.mapColor13),a
	ld a,(iy + Palette.color13 + 1)
	ld (?this + DialogEndSplit.mapColor13 + 1),a
	ld a,(iy + Palette.color14)
	ld (?this + DialogEndSplit.mapColor14),a
	ld a,(iy + Palette.color14 + 1)
	ld (?this + DialogEndSplit.mapColor14 + 1),a
	ld a,(iy + Palette.color15)
	ld (?this + DialogEndSplit.mapColor15),a
	ld a,(iy + Palette.color15 + 1)
	ld (?this + DialogEndSplit.mapColor15 + 1),a
	pop iy
	ENDM
