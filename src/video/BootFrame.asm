;
; Frame for boot
;
BootFrame: MACRO
	super: DisplayFrame Apply

	registers:
	paletteNumber:
		db 0
		db 16 | VDP_REGISTER
	palette:
		dw Palette_system

	; c = VDP port 1
	; Modifies: af, bc, hl
	Apply:
		ld hl,registers
		outi
		outi
		inc c
		ld hl,(palette)
		REPT 32
		outi
		ENDM
		ret
	ENDM

BootFrame_SetPalette_M: MACRO ?this, ?palettelow, ?palettehigh
	di
	ld (?this + BootFrame.palette),?palettelow
	ei
	ld (?this + BootFrame.palette + 1),?palettehigh
	ENDM
