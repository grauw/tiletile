;
; Split for dialog
;
DialogSplit_LINE: equ 160 - 3
DialogSplit_VERTICAL_OFFSET: equ -160

DialogSplit: MACRO
	super:
		Split
		VDPRegister 15, 2
		VDPRegister 16, 10
	mode1Blank:
		VDPRegister 1
	mode8:
		VDPRegister 8
		VDPRegister 2, 1 * Video_X_BYTE << 5 | 00011111B
	verticalOffset1:
		VDPRegister 23
	color10:
		PaletteColor 2, 3, 5
	mode1Display:
		VDPRegister 1
		VDPRegister 26, 0
		VDPRegister 27, 0
	color11:
		PaletteColor 4, 5, 6
	color12:
		PaletteColor 7, 7, 7
	color13:
		PaletteColor 0, 1, 2
	color14:
		PaletteColor 4, 5, 6
	color15:
		PaletteColor 2, 3, 5
	verticalOffset2:
		VDPRegister 23, DialogSplit_VERTICAL_OFFSET
		VDPRegister 16, 10
	mapColor10:
		PaletteColor 2, 5, 2
	mapColor11:
		PaletteColor 5, 6, 3
	_size:
	ENDM

; ix = this
DialogSplit_Construct:
	ld a,(VDP_MIRROR_0 + 1)
	and 10111111B
	ld (ix + DialogSplit.mode1Blank.value),a
	or 01000000B
	ld (ix + DialogSplit.mode1Display.value),a
	ld a,(VDP_MIRROR_8 + 8)
	or 00000010B
	ld (ix + DialogSplit.mode8.value),a
	push iy
	ld iy,UIImage_palette
	ld a,(iy + Palette.color10)
	ld (ix + DialogSplit.color10),a
	ld a,(iy + Palette.color10 + 1)
	ld (ix + DialogSplit.color10 + 1),a
	ld a,(iy + Palette.color11)
	ld (ix + DialogSplit.color11),a
	ld a,(iy + Palette.color11 + 1)
	ld (ix + DialogSplit.color11 + 1),a
	ld a,(iy + Palette.color12)
	ld (ix + DialogSplit.color12),a
	ld a,(iy + Palette.color12 + 1)
	ld (ix + DialogSplit.color12 + 1),a
	ld a,(iy + Palette.color13)
	ld (ix + DialogSplit.color13),a
	ld a,(iy + Palette.color13 + 1)
	ld (ix + DialogSplit.color13 + 1),a
	ld a,(iy + Palette.color14)
	ld (ix + DialogSplit.color14),a
	ld a,(iy + Palette.color14 + 1)
	ld (ix + DialogSplit.color14 + 1),a
	ld a,(iy + Palette.color15)
	ld (ix + DialogSplit.color15),a
	ld a,(iy + Palette.color15 + 1)
	ld (ix + DialogSplit.color15 + 1),a
	pop iy
	ret

DialogSplit_SetDialogOffset_M: MACRO ?this, ?height
	ld a,DialogSplit_VERTICAL_OFFSET - Dialog_MAX_HEIGHT
	add a,?height
	ld (?this + DialogSplit.verticalOffset1),a
	ENDM

DialogSplit_SetPalette_M: MACRO ?this, ?palettelow, ?palettehigh
	push iy
	ld iyl,?palettelow
	ld iyh,?palettehigh
	ld a,(iy + Palette.color10)
	ld (?this + DialogSplit.mapColor10),a
	ld a,(iy + Palette.color10 + 1)
	ld (?this + DialogSplit.mapColor10 + 1),a
	ld a,(iy + Palette.color11)
	ld (?this + DialogSplit.mapColor11),a
	ld a,(iy + Palette.color11 + 1)
	ld (?this + DialogSplit.mapColor11 + 1),a
	pop iy
	ENDM
