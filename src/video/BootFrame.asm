;
; Frame for gameplay
;
BootFrame_FRAME_LINE: equ 228

BootFrame: MACRO
	super: DisplayFrame
		VDPRegister 16, 0
	palette:
		dw Palette_system
	_size:
	ENDM

BootFrame_SetPalette_M: MACRO ?this, ?palettelow, ?palettehigh
	ld (?this + BootFrame.palette),?palettelow
	ld (?this + BootFrame.palette + 1),?palettehigh
	ENDM
