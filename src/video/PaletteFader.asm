;
; An array of palettes with fade steps
;
PaletteFader: MACRO
	currentStep:
		db 0
	steps:
		REPT 8
		Palette
		ENDM
	ENDM

; de = destination palette
; hl = source palette
; ix = this
PaletteFader_Construct: PROC
	push ix
	xor a
	ld b,8
Loop:
	push af
	push bc
	push de
	push hl
	ld b,a
	ld c,a
	call Palette_Interpolate
	pop hl
	pop de
	pop bc
	pop af
	add a,11H
	djnz Loop
	pop ix
	ret
	ENDP

; a = step (0..7)
; ix = this
; ix <- palette
PaletteFader_GetPalette:
	add a,a
	add a,a
	add a,a
	add a,a
	add a,a
	ld e,a
	ld d,0
	add ix,de
	ret

; ix = this
; ix <- palette
PaletteFader_GetCurrentPalette: PROC
	ld e,(ix + PaletteFader.currentStep)
	ld d,0
	add ix,de
	ret
	ENDP

; ix = this
; ix <- palette
; a <- E0H: done
PaletteFader_GetNextPalette: PROC
	ld a,(ix + PaletteFader.currentStep)
	add a,Palette._size
	jp nc,NoCarry
	ld a,0E0H
NoCarry:
	ld (ix + PaletteFader.currentStep),a
	ld e,a
	ld d,0
	add ix,de
	ret
	ENDP

; ix = this
; ix <- palette
; a <- 00H: done
PaletteFader_GetPreviousPalette: PROC
	ld a,(ix + PaletteFader.currentStep)
	sub Palette._size
	jp nc,NoCarry
	ld a,00H
NoCarry:
	ld (ix + PaletteFader.currentStep),a
	ld e,a
	ld d,0
	add ix,de
	ret
	ENDP
