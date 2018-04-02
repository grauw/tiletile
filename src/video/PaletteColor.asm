;
; Palette color
;
PaletteColor: MACRO ?r, ?g, ?b
	dw ?g << 8 | ?r << 4 | ?b
	ENDM

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
