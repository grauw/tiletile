;
; Palette color
;
PaletteColor: MACRO ?r, ?g, ?b
	dw ?g << 8 | ?r << 4 | ?b
	ENDM

; c = VDP port 2
; hl = this
; hl <- updated
; Modifies: f, b
PaletteColor_SetDI_M: MACRO
	outi
	outi
	ENDM

; de = color reference
; hl = color reference
; ix = result color reference (this)
; hl <- incremented
; ix <- incremented
PaletteColor_Add:
	ld c,(hl)
	inc hl
	ld b,(hl)
	inc hl
	jr PaletteColor_AddConstant

; bc = color (#grb)
; de = color reference
; ix = result color reference (this)
; hl <- incremented
; ix <- incremented
PaletteColor_AddConstant: PROC
	ld a,(de)
	inc de
	add a,c
	jp p,NoSaturateRed
	or 70H
NoSaturateRed:
	bit 3,a
	jr z,NoSaturateBlue
	or 07H
NoSaturateBlue:
	and 77H
	ld (ix),a
	inc ix
	ld a,(de)
	inc de
	add a,b
	bit 3,a
	jr z,NoSaturateGreen
	or 07H
NoSaturateGreen:
	and 07H
	ld (ix),a
	inc ix
	ret
	ENDP

; de = minuend color reference
; hl = subtrahend color reference
; ix = result color reference (this)
; hl <- incremented
; ix <- incremented
PaletteColor_Subtract:
	ld c,(hl)
	inc hl
	ld b,(hl)
	inc hl
	jr PaletteColor_SubtractConstant

; bc = subtrahend color (#grb)
; de = minuend color reference
; ix = result color reference (this)
; hl <- incremented
; ix <- incremented
PaletteColor_SubtractConstant: PROC
	ld a,(de)
	inc de
	or 88H
	sub c
	jp m,NoSaturateRed
	and 0FH
NoSaturateRed:
	bit 3,a
	jr nz,NoSaturateBlue
	and 0F0H
NoSaturateBlue:
	and 77H
	ld (ix),a
	inc ix
	ld a,(de)
	inc de
	or 88H
	sub b
	bit 3,a
	jr nz,NoSaturateGreen
	xor a
NoSaturateGreen:
	and 07H
	ld (ix),a
	inc ix
	ret
	ENDP

; bc = colour step (000H..777H)
; de = end color reference
; hl = start color reference
; ix = result color reference (this)
; bc <- incremented
; de <- incremented
; ix <- incremented
PaletteColor_Interpolate:
	push bc
	ld a,c
	and 07H
	ld c,a
	ld a,(de)
	and 07H
	ld b,a
	ex af,af'
	ld a,(hl)
	and 07H
	call PaletteColor_InterpolateValue
	pop bc
	push bc
	push af
	ld a,c
	rrca
	rrca
	rrca
	rrca
	and 07H
	ld c,a
	ld a,(de)
	rrca
	rrca
	rrca
	rrca
	and 07H
	ld b,a
	ex af,af'
	ld a,(hl)
	rrca
	rrca
	rrca
	rrca
	and 07H
	call PaletteColor_InterpolateValue
	rlca
	rlca
	rlca
	rlca
	pop bc
	or b
	pop bc
	ld (ix),a
	inc de
	inc hl
	inc ix
	push bc
	ld a,b
	and 07H
	ld c,a
	ld a,(de)
	and 07H
	ld b,a
	ex af,af'
	ld a,(hl)
	and 07H
	call PaletteColor_InterpolateValue
	pop bc
	ld (ix),a
	inc de
	inc hl
	inc ix
	ret

; a = start value
; a' = end value
; b = end value
; c = step
; a <- new colour
PaletteColor_InterpolateValue: PROC
	cp b
	ret z
	jr nc,Decrease
Increase:
	ld b,a
	ld a,c
	xor 07H
	ld c,a
	ex af,af'
	sub c
	jr c,IncreaseNegative
	cp b
	ret nc
IncreaseNegative:
	ld a,b
	ret
Decrease:
	sub c
	jr c,DecreaseNegative
	cp b
	ret nc
DecreaseNegative:
	ld a,b
	ret
	ENDP
