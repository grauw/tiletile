;
; Palette color
;
PaletteColor: MACRO ?r, ?g, ?b
	dw ?g << 8 | ?r << 4 | ?b
	ENDM
