;
; Split for gameplay
;
BootSplit_LINE: equ 228

BootSplit: MACRO
	super: Split
	palette:
		dw Palette_system
	_size:
	ENDM

; ix = this
BootSplit_Construct:
	ret

BootSplit_SetPalette_M: MACRO ?this, ?palettelow, ?palettehigh
	ld (?this + BootSplit.palette),?palettelow
	ld (?this + BootSplit.palette + 1),?palettehigh
	ENDM
