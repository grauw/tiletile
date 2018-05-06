;
; A palette
;
; Colour components specified as #rgb
;
Palette_COLORS: equ 16

Palette: MACRO ?0 = 0, ?1 = 0, ?2 = 0, ?3 = 0, ?4 = 0, ?5 = 0, ?6 = 0, ?7 = 0,
               ?8 = 0, ?9 = 0, ?10 = 0, ?11 = 0, ?12 = 0, ?13 = 0, ?14 = 0, ?15 = 0
	colors:
	color0: PaletteColor ?0 >> 8, ?0 >> 4 & 7, ?0 & 7
	color1: PaletteColor ?1 >> 8, ?1 >> 4 & 7, ?1 & 7
	color2: PaletteColor ?2 >> 8, ?2 >> 4 & 7, ?2 & 7
	color3: PaletteColor ?3 >> 8, ?3 >> 4 & 7, ?3 & 7
	color4: PaletteColor ?4 >> 8, ?4 >> 4 & 7, ?4 & 7
	color5: PaletteColor ?5 >> 8, ?5 >> 4 & 7, ?5 & 7
	color6: PaletteColor ?6 >> 8, ?6 >> 4 & 7, ?6 & 7
	color7: PaletteColor ?7 >> 8, ?7 >> 4 & 7, ?7 & 7
	color8: PaletteColor ?8 >> 8, ?8 >> 4 & 7, ?8 & 7
	color9: PaletteColor ?9 >> 8, ?9 >> 4 & 7, ?9 & 7
	color10: PaletteColor ?10 >> 8, ?10 >> 4 & 7, ?10 & 7
	color11: PaletteColor ?11 >> 8, ?11 >> 4 & 7, ?11 & 7
	color12: PaletteColor ?12 >> 8, ?12 >> 4 & 7, ?12 & 7
	color13: PaletteColor ?13 >> 8, ?13 >> 4 & 7, ?13 & 7
	color14: PaletteColor ?14 >> 8, ?14 >> 4 & 7, ?14 & 7
	color15: PaletteColor ?15 >> 8, ?15 >> 4 & 7, ?15 & 7
	_size:
	ENDM

; de = palette reference
; hl = palette reference
; ix = result palette reference (this)
; hl <- incremented
; ix <- incremented
Palette_Add: PROC
	ld b,Palette_COLORS
Loop:
	call PaletteColor_Add
	djnz Loop
	ret
	ENDP

; bc = color (#grb)
; de = palette reference
; ix = result palette reference (this)
; hl <- incremented
; ix <- incremented
Palette_AddConstant:
	REPT Palette_COLORS
	call PaletteColor_AddConstant
	ENDM
	ret

; de = minuend palette reference
; hl = subtrahend palette reference
; ix = result palette reference (this)
; hl <- incremented
; ix <- incremented
Palette_Subtract: PROC
	ld b,Palette_COLORS
Loop:
	call PaletteColor_Subtract
	djnz Loop
	ret
	ENDP

; bc = subtrahend color (#grb)
; de = minuend palette reference
; ix = result palette reference (this)
; hl <- incremented
; ix <- incremented
Palette_SubtractConstant:
	REPT Palette_COLORS
	call PaletteColor_SubtractConstant
	ENDM
	ret

; bc = colour step (000H...777H)
; de = end palette
; hl = start palette
; ix = result palette
; bc <- incremented
; de <- incremented
; ix <- incremented
Palette_Interpolate:
	REPT Palette_COLORS
	call PaletteColor_Interpolate
	ENDM
	ret

;
Palette_black:
	Palette 000H, 000H, 000H, 000H, 000H, 000H, 000H, 000H,
	        000H, 000H, 000H, 000H, 000H, 000H, 000H, 000H

Palette_white:
	Palette 777H, 777H, 777H, 777H, 777H, 777H, 777H, 777H,
	        777H, 777H, 777H, 777H, 777H, 777H, 777H, 777H

Palette_system:
	Palette 000H, 000H, 161H, 373H, 117H, 237H, 511H, 267H,
	        711H, 733H, 661H, 664H, 141H, 625H, 555H, 777H
